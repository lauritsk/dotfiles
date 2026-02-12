if status is-interactive
    set -gx fish_greeting
    set -gx fish_key_bindings fish_vi_key_bindings
    type -q starship; and starship init fish | source
    type -q zoxide; and zoxide init fish --cmd cd | source
end
