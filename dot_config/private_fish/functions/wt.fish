function wt --description "Create a new git worktree in ../<repo>-<name> on branch <name> and cd into it"
    set repo_root (git rev-parse --show-toplevel 2>/dev/null)
    if test $status -ne 0
        echo "wt: not inside a git repository" >&2
        return 1
    end

    if test (count $argv) -gt 1
        echo "usage: wt [branch-name]" >&2
        return 1
    end

    set repo_name (basename "$repo_root")
    set parent_dir (dirname "$repo_root")

    set words alpha beta gamma delta omega maple cedar ember comet river stone cloud moss pine ash dune iris hazel echo drift

    if test (count $argv) -ge 1
        set branch $argv[1]
    else
        while true
            set branch (random choice $words)-(random 1000 9999)
            set worktree_path "$parent_dir/$repo_name-$branch"

            if not git show-ref --verify --quiet "refs/heads/$branch"
                and not test -e "$worktree_path"
                break
            end
        end
    end

    if test -z "$worktree_path"
        set worktree_path "$parent_dir/$repo_name-$branch"
    end

    if git show-ref --verify --quiet "refs/heads/$branch"
        echo "wt: branch already exists: $branch" >&2
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

    git -C "$worktree_path" config --worktree commit.gpgSign false
    or return 1

    cd "$worktree_path"
    or return 1

    if command -q mise
        mise trust .
    end
end
