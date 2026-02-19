if status is-interactive
    fish_config theme choose catppuccin-mocha
    set -gx fish_greeting
    set -gx fish_key_bindings fish_vi_key_bindings
    eval (/opt/homebrew/bin/brew shellenv)
    type -q starship; and starship init fish | source
    type -q zoxide; and zoxide init fish --cmd cd | source
end

test -f ~/.orbstack/shell/init.fish; and source ~/.orbstack/shell/init.fish

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init2.fish 2>/dev/null || :
