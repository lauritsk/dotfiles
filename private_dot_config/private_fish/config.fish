if status is-interactive
    set -g fish_greeting
    set -g fish_key_bindings fish_vi_key_bindings
    fish_add_path /opt/homebrew/bin
    fish_add_path /opt/homebrew/sbin
    fish_add_path ~/go/bin
    mise activate fish | source
    starship init fish | source
    zoxide init fish --cmd cd | source
end
