if status is-interactive
    zoxide init fish --cmd cd | source
    starship init fish | source
    atuin init fish | source
end

source ~/.orbstack/shell/init2.fish 2>/dev/null || :
