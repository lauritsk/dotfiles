if status is-interactive
    eval (/opt/homebrew/bin/brew shellenv)
    fish_add_path /opt/homebrew/opt/llvm/bin
    set -gx LDFLAGS "-L/opt/homebrew/opt/llvm/lib"
    set -gx CPPFLAGS "-I/opt/homebrew/opt/llvm/include"
    fish_add_path /opt/homebrew/opt/rustup/bin
    fish_add_path $HOME/.cargo/bin
    fish_add_path $HOME/go/bin
    fish_add_path /opt/homebrew/opt/ruby/bin
    set -gx LDFLAGS -L/opt/homebrew/opt/ruby/lib
    set -gx CPPFLAGS -I/opt/homebrew/opt/ruby/include
    set -gx PKG_CONFIG_PATH /opt/homebrew/opt/ruby/lib/pkgconfig
    mise activate fish | source
    zoxide init fish --cmd cd | source
    starship init fish | source
    atuin init fish | source
    fnox activate fish | source
end

source ~/.orbstack/shell/init2.fish 2>/dev/null || :
