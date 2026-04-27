function wt --description "Create a git worktree, run pi, auto-commit, create PR, clean up, and ask pi to merge"
    set repo_root (git rev-parse --show-toplevel 2>/dev/null)
    or begin
        echo "wt: not inside a git repository" >&2
        return 1
    end

    command -q pi
    or begin
        echo "wt: pi is required" >&2
        return 1
    end

    set common_git_dir (git rev-parse --path-format=absolute --git-common-dir 2>/dev/null)
    or begin
        echo "wt: could not determine common git dir" >&2
        return 1
    end
    set main_wt (dirname "$common_git_dir")

    set main_dirty (git -C "$main_wt" status --porcelain --untracked-files=all)
    or return 1
    if test (count $main_dirty) -ne 0
        echo "wt: main worktree has uncommitted or untracked changes: $main_wt" >&2
        return 1
    end

    set base_rev (git rev-parse HEAD)
    or return 1
    set pi_prompt (string join ' ' -- $argv[2..-1])

    set repo_name (basename "$repo_root")
    set parent_dir (dirname "$repo_root")
    set words alpha beta gamma delta omega maple cedar ember comet river stone cloud moss pine ash dune iris hazel echo drift

    if test (count $argv) -ge 1
        set branch $argv[1]
    else
        for _ in (seq 1 100)
            set branch (random choice $words)-(random 1000 9999)
            set safe_branch (string replace -a / - $branch)
            set worktree_path "$parent_dir/$repo_name-$safe_branch"

            if not git show-ref --verify --quiet "refs/heads/$branch"
                and not git show-ref --verify --quiet "refs/remotes/origin/$branch"
                and not test -e "$worktree_path"
                break
            end

            set -e branch safe_branch worktree_path
        end

        if test -z "$branch"
            echo "wt: could not find an unused branch/worktree name" >&2
            return 1
        end
    end

    git check-ref-format --branch "$branch" >/dev/null 2>/dev/null
    or begin
        echo "wt: invalid branch name: $branch" >&2
        return 1
    end

    set safe_branch (string replace -a / - $branch)
    set worktree_path "$parent_dir/$repo_name-$safe_branch"

    if git show-ref --verify --quiet "refs/heads/$branch"
        echo "wt: branch already exists: $branch" >&2
        return 1
    end

    if git show-ref --verify --quiet "refs/remotes/origin/$branch"
        echo "wt: remote branch already exists: origin/$branch" >&2
        return 1
    end

    if test -e "$worktree_path"
        echo "wt: path already exists: $worktree_path" >&2
        return 1
    end

    git config extensions.worktreeConfig true
    or return 1

    git worktree add "$worktree_path" -b "$branch"
    or return 1

    if not git -C "$worktree_path" config --worktree commit.gpgSign false
        echo "wt: failed to configure worktree; cleaning up $worktree_path" >&2
        git worktree remove --force "$worktree_path" >/dev/null 2>/dev/null
        git branch -D "$branch" >/dev/null 2>/dev/null
        return 1
    end

    cd "$worktree_path"
    or return 1

    echo "Created $worktree_path on branch $branch"

    if command -q mise
        mise trust .
        or return 1
    end

    if set -q pi_prompt[1]
        pi "$pi_prompt"
    else
        pi
    end
    set pi_status $status
    if test $pi_status -ne 0
        echo "wt: pi exited with status $pi_status; stopping before commit/PR" >&2
        return $pi_status
    end

    set commit_count (git rev-list --count "$base_rev..HEAD")
    or return 1
    set dirty (git status --porcelain --untracked-files=all)
    or return 1

    if test "$commit_count" -eq 0
        if test (count $dirty) -eq 0
            echo "wt: no changes or commits after pi; stopping before PR"
            return 0
        end

        set branch_parts (string split -m1 / -- "$branch")
        set raw_type chore
        set subject $branch
        if test (count $branch_parts) -gt 1
            set raw_type $branch_parts[1]
            set subject $branch_parts[2]
        end

        set commit_type (string replace -r '^feature$' feat -- "$raw_type")
        if not string match -qr '^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\(.+\))?!?$' -- "$commit_type"
            set commit_type chore
            set subject $branch
        end

        set subject (string replace -ra '[-_/]+' ' ' -- "$subject" | string trim)
        if test -z "$subject"
            set subject work
        end

        set commit_title "$commit_type: $subject"
        git add -A
        or return 1
        git commit -m "$commit_title"
        or return 1
    else if test (count $dirty) -ne 0
        echo "wt: branch has commits plus uncommitted changes; stopping before PR" >&2
        return 1
    end

    set dirty (git status --porcelain --untracked-files=all)
    or return 1
    if test (count $dirty) -ne 0
        echo "wt: worktree still has uncommitted changes after commit; stopping before PR" >&2
        return 1
    end

    set commit_title (git log -1 --format=%s)
    or return 1

    command -q gh
    or begin
        echo "wt: gh is required for PR creation" >&2
        return 1
    end

    set default_branch (git -C "$main_wt" symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null | string replace -r '^origin/' '')
    if test -z "$default_branch"
        set default_branch (gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name' 2>/dev/null)
    end
    if test -z "$default_branch"
        echo "wt: could not determine default branch" >&2
        return 1
    end

    set main_dirty (git -C "$main_wt" status --porcelain --untracked-files=all)
    or return 1
    if test (count $main_dirty) -ne 0
        echo "wt: main worktree has uncommitted or untracked changes: $main_wt" >&2
        return 1
    end

    if git -C "$main_wt" show-ref --verify --quiet "refs/heads/$default_branch"
        git -C "$main_wt" switch "$default_branch"
        or return 1
    else if git -C "$main_wt" show-ref --verify --quiet "refs/remotes/origin/$default_branch"
        git -C "$main_wt" switch --track "origin/$default_branch"
        or return 1
    else
        echo "wt: default branch not found locally: $default_branch" >&2
        return 1
    end

    git -C "$main_wt" pull --ff-only origin "$default_branch"
    or return 1

    git push -u origin "$branch"
    or return 1

    set pr_create_out (gh pr create --fill | string collect)
    or return 1
    if set -q pr_create_out[1]
        echo "$pr_create_out"
    end

    set pr_title (gh pr view "$branch" --json title --jq '.title')
    or return 1
    set pr_url (gh pr view "$branch" --json url --jq '.url')
    or return 1

    builtin cd -- "$main_wt"
    or begin
        echo "wt: failed to cd to main worktree: $main_wt" >&2
        return 1
    end

    git -C "$main_wt" worktree remove "$worktree_path"
    or return 1

    pi "please merge this pr: $pr_title ($pr_url). commit title: $commit_title"
end
