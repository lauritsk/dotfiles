if status is-interactive
    set -gx fish_greeting
    set -gx fish_key_bindings fish_vi_key_bindings

    set -gx XDG_CONFIG_HOME $HOME/.config
    set -gx XDG_CACHE_HOME $HOME/.cache
    set -gx XDG_DATA_HOME $HOME/.local/share
    set -gx XDG_STATE_HOME $HOME/.local/state

    if test -x /opt/homebrew/bin/brew
        eval (/opt/homebrew/bin/brew shellenv)
    else if test -x /home/linuxbrew/.linuxbrew/bin/brew
        eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv)
    end

    if set -q HOMEBREW_PREFIX
        if test -d "$HOMEBREW_PREFIX/opt/ruby"
            fish_add_path "$HOMEBREW_PREFIX/opt/ruby/bin"
            set -gxp LDFLAGS "-L$HOMEBREW_PREFIX/opt/ruby/lib"
            set -gxp CPPFLAGS "-I$HOMEBREW_PREFIX/opt/ruby/include"
            set -gxp PKG_CONFIG_PATH "$HOMEBREW_PREFIX/opt/ruby/lib/pkgconfig"
        end

        if test -d "$HOMEBREW_PREFIX/opt/llvm"
            fish_add_path "$HOMEBREW_PREFIX/opt/llvm/bin"
            set -gxp LDFLAGS "-L$HOMEBREW_PREFIX/opt/llvm/lib"
            set -gxp CPPFLAGS "-I$HOMEBREW_PREFIX/opt/llvm/include"
        end
    end

    if test -d $HOME/.cargo/bin
        fish_add_path $HOME/.cargo/bin
    end

    if test -d $HOME/go/bin
        fish_add_path $HOME/go/bin
    end

    set -gx PAGER bat
    set -gx EDITOR hx
    set -gx VISUAL zed

    type -q mise; and mise activate fish | source
    type -q zoxide; and zoxide init fish --cmd cd | source
    type -q starship; and starship init fish | source
    type -q atuin; and atuin init fish | source
    type -q fnox; and fnox activate fish | source
end

if test -f ~/.orbstack/shell/init2.fish
    source ~/.orbstack/shell/init2.fish
end
