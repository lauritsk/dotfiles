function wtp --description "Create PR with --fill, return to main worktree, remove current worktree, keep branch"
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

    # Create the PR from the current worktree/branch.
    gh pr create --fill
    or return 1

    # Find the main worktree path.
    set main_wt (git worktree list --porcelain | awk '
        BEGIN { path=""; isbare=0 }
        $1=="worktree" { path=$2; isbare=0 }
        $1=="bare"     { isbare=1 }
        /^$/ {
            if (path != "" && isbare == 0) {
                print path
                exit
            }
            path=""; isbare=0
        }
        END {
            if (path != "" && isbare == 0) print path
        }
    ')

    if test -z "$main_wt"
        echo "wtp: could not find main worktree" >&2
        return 1
    end

    # If we're already in the main worktree, refuse.
    if test "$cur_wt" = "$main_wt"
        echo "wtp: current directory is the main worktree; refusing to remove it" >&2
        return 1
    end

    cd "$main_wt"
    or return 1

    # Go to trunk and update it conservatively.
    if git rev-parse --verify main >/dev/null 2>/dev/null
        git switch main
        and git pull --ff-only
    else if git rev-parse --verify master >/dev/null 2>/dev/null
        git switch master
        and git pull --ff-only
    end

    # Remove the old linked worktree.
    git worktree remove "$cur_wt"
end
