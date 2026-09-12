if status is-interactive
    set -g fish_greeting
    set -g fish_key_bindings fish_vi_key_bindings
    fish_add_path /home/linuxbrew/.linuxbrew/bin
    fish_add_path /home/linuxbrew/.linuxbrew/sbin
    mise activate fish | source
    zoxide init fish --cmd cd | source
end
