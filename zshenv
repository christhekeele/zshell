# system-wide environment settings for zsh(1)
if [ -x /usr/libexec/path_helper ]; then
        eval `/usr/libexec/path_helper -s`
fi

zmodload -ap zsh/mapfile mapfile
typeset -U path
path=( $path "${(f@)mapfile[/etc/paths]}" )

# RBENV rehashing
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi
