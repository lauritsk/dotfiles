function wtp --description "Create PR with --fill, jump to main worktree, remove current linked worktree"
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

    # Shared .git dir for all worktrees; its parent is the main worktree path.
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

    # Avoid gh's push prompt by pushing first.
    git push -u origin "$branch"
    or return 1

    gh pr create --fill
    or return 1

    builtin cd -- "$main_wt"
    or begin
        echo "wtp: failed to cd to main worktree: $main_wt" >&2
        return 1
    end

    if git -C "$main_wt" rev-parse --verify main >/dev/null 2>/dev/null
        git -C "$main_wt" switch main
        and git -C "$main_wt" pull --ff-only
    else if git -C "$main_wt" rev-parse --verify master >/dev/null 2>/dev/null
        git -C "$main_wt" switch master
        and git -C "$main_wt" pull --ff-only
    end

    git -C "$main_wt" worktree remove "$cur_wt"
end
