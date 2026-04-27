function wt --description "Create a git worktree, run pi non-interactively, auto-commit, create PR, merge, repair, and clean up"
    argparse -n wt 'b/branch=' 'a/attempts=' p/prompt h/help -- $argv
    or return 2

    if set -q _flag_help
        echo "usage: wt [--attempts N] [--branch BRANCH] PROMPT..."
        echo "       wt [--attempts N] BRANCH PROMPT...      # legacy"
        echo "       wt [--attempts N] --prompt PROMPT...    # random branch"
        return 0
    end

    set -l branch
    set -l pi_prompt
    set -l max_attempts 3

    if set -q _flag_attempts[1]
        set max_attempts $_flag_attempts[-1]
        if not string match -qr '^[1-9][0-9]*$' -- "$max_attempts"
            echo "wt: --attempts must be a positive integer" >&2
            return 2
        end
    end

    if set -q _flag_branch[1]
        set branch $_flag_branch[-1]
        set pi_prompt (string join ' ' -- $argv)
    else if set -q _flag_prompt
        set pi_prompt (string join ' ' -- $argv)
    else if test (count $argv) -ge 1
        set branch $argv[1]
        set pi_prompt (string join ' ' -- $argv[2..-1])
    end

    if not set -q pi_prompt[1]
        echo "wt: prompt required for non-interactive pi -p flow" >&2
        echo "usage: wt [--branch BRANCH] PROMPT..." >&2
        echo "       wt --prompt PROMPT...    # random branch" >&2
        return 2
    end

    set -l repo_root (git rev-parse --show-toplevel 2>/dev/null)
    or begin
        echo "wt: not inside a git repository" >&2
        return 1
    end

    command -q pi
    or begin
        echo "wt: pi is required" >&2
        return 1
    end

    command -q gh
    or begin
        echo "wt: gh is required for PR creation" >&2
        return 1
    end

    set -l common_git_dir (git rev-parse --path-format=absolute --git-common-dir 2>/dev/null)
    or begin
        echo "wt: could not determine common git dir" >&2
        return 1
    end
    set -l main_wt (path dirname -- "$common_git_dir")

    set -l main_dirty (git -C "$main_wt" status --porcelain --untracked-files=all)
    or return 1
    if test (count $main_dirty) -ne 0
        echo "wt: main worktree has uncommitted or untracked changes: $main_wt" >&2
        return 1
    end

    set -l default_branch (git -C "$main_wt" symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null | string replace -r '^origin/' '')
    if test -z "$default_branch"
        set default_branch (gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name' 2>/dev/null)
    end
    if test -z "$default_branch"
        echo "wt: could not determine default branch" >&2
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

    set -l base_rev (git -C "$main_wt" rev-parse HEAD)
    or return 1

    set -l repo_name (path basename -- "$repo_root")
    set -l parent_dir (path dirname -- "$repo_root")
    set -l words alpha beta gamma delta omega maple cedar ember comet river stone cloud moss pine ash dune iris hazel echo drift
    set -l safe_branch
    set -l worktree_path

    if test -z "$branch"
        for _ in (seq 1 100)
            set branch (random choice $words)-(random 1000 9999)
            set safe_branch (string replace -a / - $branch)
            set worktree_path "$parent_dir/$repo_name-$safe_branch"

            if not git -C "$main_wt" show-ref --verify --quiet "refs/heads/$branch"
                and not git -C "$main_wt" show-ref --verify --quiet "refs/remotes/origin/$branch"
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

    if git -C "$main_wt" show-ref --verify --quiet "refs/heads/$branch"
        echo "wt: branch already exists: $branch" >&2
        return 1
    end

    if git -C "$main_wt" show-ref --verify --quiet "refs/remotes/origin/$branch"
        echo "wt: remote branch already exists: origin/$branch" >&2
        return 1
    end

    if test -e "$worktree_path"
        echo "wt: path already exists: $worktree_path" >&2
        return 1
    end

    git -C "$main_wt" config extensions.worktreeConfig true
    or return 1

    git -C "$main_wt" worktree add "$worktree_path" -b "$branch" "$base_rev"
    or return 1

    if not git -C "$worktree_path" config --worktree commit.gpgSign false
        echo "wt: failed to configure worktree; cleaning up $worktree_path" >&2
        git -C "$main_wt" worktree remove --force "$worktree_path" >/dev/null 2>/dev/null
        git -C "$main_wt" branch -D "$branch" >/dev/null 2>/dev/null
        return 1
    end

    cd "$worktree_path"
    or return 1

    echo "Created $worktree_path on branch $branch"

    if command -q mise
        mise trust .
        or return 1
    end

    pi -p "$pi_prompt"
    set -l pi_status $status
    if test $pi_status -ne 0
        echo "wt: pi exited with status $pi_status; stopping before review/commit/PR" >&2
        return $pi_status
    end

    set -l initial_commit_count (git rev-list --count "$base_rev..HEAD")
    or return 1
    set -l initial_dirty (git status --porcelain --untracked-files=all)
    or return 1

    set -l review_target
    if test "$initial_commit_count" -gt 0
        set review_target "Review the commits in $base_rev..HEAD."
    else if test (count $initial_dirty) -ne 0
        set review_target "Review the uncommitted changes in this worktree."
    else
        set review_target "No commits or uncommitted changes exist yet; verify whether the requested task was already satisfied or make the needed changes."
    end

    pi -p "Review the work for this original request and fix anything incomplete, incorrect, unsafe, or not matching the request. $review_target If fixes are needed, apply them. You may commit fixes yourself or leave them unstaged; wt will commit dirty changes afterward. Keep the worktree clean when possible. Original request: $pi_prompt"
    set pi_status $status
    if test $pi_status -ne 0
        echo "wt: pi review exited with status $pi_status; stopping before commit/PR" >&2
        return $pi_status
    end

    set -l commit_count (git rev-list --count "$base_rev..HEAD")
    or return 1
    set -l dirty (git status --porcelain --untracked-files=all)
    or return 1

    set -l commit_title
    if test "$commit_count" -eq 0
        if test (count $dirty) -eq 0
            echo "wt: no changes or commits after pi; stopping before PR"
            return 0
        end

        set -l branch_parts (string split -m1 / -- "$branch")
        set -l raw_type chore
        set -l subject $branch
        if test (count $branch_parts) -gt 1
            set raw_type $branch_parts[1]
            set subject $branch_parts[2]
        end

        set -l commit_type (string replace -r '^feature$' feat -- "$raw_type")
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
        git add -A
        or return 1
        git commit -m "fix: address follow-up changes"
        or return 1
    end

    set dirty (git status --porcelain --untracked-files=all)
    or return 1
    if test (count $dirty) -ne 0
        echo "wt: worktree still has uncommitted changes after commit; stopping before PR" >&2
        return 1
    end

    set commit_title (git log -1 --format=%s)
    or return 1

    set -l need_force_push 0
    set -l pr_title
    set -l pr_url

    for attempt in (seq 1 $max_attempts)
        echo "wt: PR attempt $attempt/$max_attempts"

        set dirty (git status --porcelain --untracked-files=all)
        or return 1
        if test (count $dirty) -ne 0
            git add -A
            or return 1
            git commit -m "fix: address automated feedback"
            or return 1
            set commit_title (git log -1 --format=%s)
            or return 1
        end

        if test "$need_force_push" -eq 1
            git push --force-with-lease -u origin "$branch"
            or return 1
            set need_force_push 0
        else
            git push -u origin "$branch"
            or return 1
        end

        if not gh pr view "$branch" >/dev/null 2>/dev/null
            set -l pr_create_out (gh pr create --fill | string collect)
            or return 1
            if set -q pr_create_out[1]
                echo "$pr_create_out"
            end
        end

        set pr_title (gh pr view "$branch" --json title --jq '.title')
        or return 1
        set pr_url (gh pr view "$branch" --json url --jq '.url')
        or return 1

        set -l checks_out (gh pr checks "$branch" --watch 2>&1 | string collect)
        set -l checks_status $pipestatus[1]
        if set -q checks_out[1]
            echo "$checks_out"
        end
        if test $checks_status -ne 0
            if string match -qi '*no checks*' -- "$checks_out"
                echo "wt: no CI checks reported; continuing"
            else if test "$attempt" -ge "$max_attempts"
                echo "wt: CI checks failed after $attempt attempts; leaving PR open: $pr_url" >&2
                return $checks_status
            else
                pi -p "CI checks failed or did not finish for this PR: $pr_title ($pr_url). Fix all failures in this worktree. Commit changes if useful; otherwise leave changes unstaged and wt will commit them. Keep the worktree clean when done. Last commit title: $commit_title

Checks output:
$checks_out"
                set pi_status $status
                if test $pi_status -ne 0
                    echo "wt: pi exited with status $pi_status while fixing CI" >&2
                    return $pi_status
                end
                continue
            end
        end

        set -l pr_head_oid (gh pr view "$branch" --json headRefOid --jq '.headRefOid')
        or return 1

        set -l merge_out (gh pr merge "$branch" --squash --delete-branch --match-head-commit "$pr_head_oid" --subject "$pr_title" --body '' 2>&1 | string collect)
        set -l merge_status $pipestatus[1]
        if set -q merge_out[1]
            echo "$merge_out"
        end
        if test $merge_status -eq 0
            builtin cd -- "$main_wt"
            or begin
                echo "wt: failed to cd to main worktree: $main_wt" >&2
                return 1
            end

            git -C "$main_wt" pull --ff-only origin "$default_branch"
            or return 1

            git -C "$main_wt" worktree remove "$worktree_path"
            or return 1
            git -C "$main_wt" branch -D "$branch" >/dev/null 2>/dev/null

            echo "wt: github squash merged $pr_title ($pr_url)"
            return 0
        end

        if test "$attempt" -ge "$max_attempts"
            echo "wt: github squash merge failed after $attempt attempts; leaving PR open: $pr_url" >&2
            return $merge_status
        end

        echo "wt: merge failed; rebasing onto latest origin/$default_branch before retry"

        git fetch origin "$default_branch"
        or return 1

        git rebase "origin/$default_branch"
        set -l rebase_status $status
        if test $rebase_status -ne 0
            pi -p "GitHub squash merge failed for PR: $pr_title ($pr_url), likely because $default_branch moved. A rebase onto origin/$default_branch is now in progress and has conflicts. Resolve conflicts, finish the rebase with git rebase --continue, and leave the worktree clean. Preserve the intended changes. Last commit title: $commit_title

Merge failure output:
$merge_out"
            set pi_status $status
            if test $pi_status -ne 0
                echo "wt: pi exited with status $pi_status while resolving rebase" >&2
                return $pi_status
            end
        end

        set -l git_dir (git rev-parse --path-format=absolute --git-dir)
        or return 1
        if test -d "$git_dir/rebase-merge"; or test -d "$git_dir/rebase-apply"
            echo "wt: rebase still in progress after pi; leaving PR open: $pr_url" >&2
            return 1
        end

        set dirty (git status --porcelain --untracked-files=all)
        or return 1
        if test (count $dirty) -ne 0
            git add -A
            or return 1
            git commit -m "fix: resolve latest base changes"
            or return 1
            set commit_title (git log -1 --format=%s)
            or return 1
        end

        set need_force_push 1
    end

    echo "wt: exhausted $max_attempts attempts; leaving worktree: $worktree_path" >&2
    return 1
end
