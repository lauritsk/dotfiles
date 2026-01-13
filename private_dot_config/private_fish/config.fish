if status is-interactive
    if test -x /opt/homebrew/bin/brew
        eval (/opt/homebrew/bin/brew shellenv)
    else if test -x /home/linuxbrew/.linuxbrew/bin/brew
        eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv)
    end

    if test -d /opt/homebrew/opt/ruby
        fish_add_path /opt/homebrew/opt/ruby/bin
        set -gxp LDFLAGS -L/opt/homebrew/opt/ruby/lib
        set -gxp CPPFLAGS -I/opt/homebrew/opt/ruby/include
        set -gxp PKG_CONFIG_PATH /opt/homebrew/opt/ruby/lib/pkgconfig
    end

    if test -d /opt/homebrew/opt/llvm
        fish_add_path /opt/homebrew/opt/llvm/bin
        set -gxp LDFLAGS -L/opt/homebrew/opt/llvm/lib
        set -gxp CPPFLAGS -I/opt/homebrew/opt/llvm/include
    end

    if test -d /opt/homebrew/opt/rustup/bin
        fish_add_path /opt/homebrew/opt/rustup/bin
    end

    if test -d $HOME/.cargo/bin
        fish_add_path $HOME/.cargo/bin
    end

    if test -d $HOME/go/bin
        fish_add_path $HOME/go/bin
    end

    type -q mise; and mise activate fish | source
    type -q zoxide; and zoxide init fish --cmd cd | source
    type -q starship; and starship init fish | source
    type -q atuin; and atuin init fish | source
    type -q fnox; and fnox activate fish | source
end

if test -f ~/.orbstack/shell/init2.fish
    source ~/.orbstack/shell/init2.fish
end
