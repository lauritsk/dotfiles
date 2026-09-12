if status is-interactive
    set -g fish_greeting
    set -g fish_key_bindings fish_vi_key_bindings
    mise activate fish | source
end
