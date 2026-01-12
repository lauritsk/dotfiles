if status is-interactive
    set --global fish_greeting
    set --global fish_key_bindings fish_vi_key_bindings
    set --global --export EDITOR hx
    set --global --export VISUAL zed
    set --global --export PAGER bat
    mise activate fish | source
    zoxide init fish --cmd cd | source
    starship init fish | source
end

source ~/.orbstack/shell/init2.fish 2>/dev/null || :
