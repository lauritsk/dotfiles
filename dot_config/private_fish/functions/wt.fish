function wt --description "Create a new git worktree in ../<repo>-<branch>, cd into it, and launch pi"
    set repo_root (git rev-parse --show-toplevel 2>/dev/null)
    or begin
        echo "wt: not inside a git repository" >&2
        return 1
    end

    set pi_prompt $argv[2..-1]

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

    if command -q pi
        pi $pi_prompt
    end
end
