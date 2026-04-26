function wtp --description "Push current branch, create PR, jump to main worktree, remove current linked worktree"
    command -q gh
    or begin
        echo "wtp: gh is required" >&2
        return 1
    end

    set cur_wt (git rev-parse --show-toplevel 2>/dev/null)
    or begin
        echo "wtp: not inside a git repository" >&2
        return 1
    end

    set branch (git branch --show-current)
    if test -z "$branch"
        echo "wtp: not on a branch" >&2
        return 1
    end

    set dirty (git status --porcelain --untracked-files=all)
    or return 1
    if test (count $dirty) -ne 0
        echo "wtp: worktree has uncommitted or untracked changes" >&2
        return 1
    end

    set common_git_dir (git rev-parse --path-format=absolute --git-common-dir 2>/dev/null)
    or begin
        echo "wtp: could not determine common git dir" >&2
        return 1
    end
    set main_wt (dirname "$common_git_dir")

    if test "$cur_wt" = "$main_wt"
        echo "wtp: refusing to remove the main worktree" >&2
        return 1
    end

    set main_dirty (git -C "$main_wt" status --porcelain --untracked-files=all)
    or return 1
    if test (count $main_dirty) -ne 0
        echo "wtp: main worktree has uncommitted or untracked changes: $main_wt" >&2
        return 1
    end

    set default_branch (git -C "$main_wt" symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null | string replace -r '^origin/' '')
    if test -z "$default_branch"
        set default_branch (gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name' 2>/dev/null)
    end
    if test -z "$default_branch"
        echo "wtp: could not determine default branch" >&2
        return 1
    end

    if git -C "$main_wt" show-ref --verify --quiet "refs/heads/$default_branch"
        git -C "$main_wt" switch "$default_branch"
        or return 1
    else if git -C "$main_wt" show-ref --verify --quiet "refs/remotes/origin/$default_branch"
        git -C "$main_wt" switch --track "origin/$default_branch"
        or return 1
    else
        echo "wtp: default branch not found locally: $default_branch" >&2
        return 1
    end

    git -C "$main_wt" pull --ff-only origin "$default_branch"
    or return 1

    git push -u origin "$branch"
    or return 1

    gh pr create --fill
    or return 1

    builtin cd -- "$main_wt"
    or begin
        echo "wtp: failed to cd to main worktree: $main_wt" >&2
        return 1
    end

    git -C "$main_wt" worktree remove "$cur_wt"
end
