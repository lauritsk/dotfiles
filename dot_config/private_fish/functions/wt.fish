function wt --description "Create a new git worktree in ../<repo>-<random> on branch <random> and cd into it"
    set repo_root (git rev-parse --show-toplevel 2>/dev/null)
    if test $status -ne 0
        echo "wt: not inside a git repository" >&2
        return 1
    end

    set repo_name (basename "$repo_root")
    set parent_dir (dirname "$repo_root")

    while true
        set branch (string lower (random choice alpha beta gamma delta omega maple cedar ember comet river stone cloud moss pine ash dune iris hazel echo drift))
        set branch "$branch"-(random 1000 9999)
        set worktree_path "$parent_dir/$repo_name-$branch"

        if not git show-ref --verify --quiet "refs/heads/$branch"
            and not test -e "$worktree_path"
            break
        end
    end

    git worktree add "$worktree_path" -b "$branch"
    or return 1

    cd "$worktree_path"
end
