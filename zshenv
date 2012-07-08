# Put or link this into your /etc folder (admin access required)

# system-wide environment settings for zsh(1)
if [ -x /usr/libexec/path_helper ]; then
        eval `/usr/libexec/path_helper -s`
fi

# Build your $PATH off of Mac's /etc/paths folder like everything else
zmodload -ap zsh/mapfile mapfile
typeset -U path
path=( $path "${(f@)mapfile[/etc/paths]}" )

# auto RBENV rehashing
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi
