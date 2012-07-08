# Thanks to:
#   aperiodic: http://aperiodic.net/phil/prompt/
#   stevelosh: http://stevelosh.com/blog/2010/02/my-extravagant-zsh-prompt/



function precmd {

    local TERMWIDTH
    (( TERMWIDTH = ${COLUMNS} - 1 ))

    ###
    # Truncate the path if it's too long.
    
    PR_FILLBAR=""
    PR_PWDLEN=""
    
    local promptsize=${#${(%):---(%n@%m)---()--}}
    local pwdsize=${#${(%):-%~}}
    
    if [[ "$promptsize + $pwdsize" -gt $TERMWIDTH ]]; then
        ((PR_PWDLEN=$TERMWIDTH - $promptsize))
    else
    PR_FILLBAR="\${(l.(($TERMWIDTH - ($promptsize + $pwdsize)))..${PR_HBAR}.)}"
    fi

    
    # batt_info="$(python /usr/local/bin/batt_info.py)"
    # # REPO INFO
    autoload -Uz vcs_info
    zstyle ':vcs_info:*' stagedstr '$PR_GREEN●'
    zstyle ':vcs_info:*' unstagedstr '$PR_YELLOW●'
    zstyle ':vcs_info:*' check-for-changes true
    # zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat '$PR_MAGENTA%r'
    zstyle ':vcs_info:*' enable git svn
    if [[ -z $(git ls-files --other --exclude-standard 2> /dev/null) ]] {
        if [[ -n "0" ]] {
            zstyle ':vcs_info:*' formats '[$PR_WHITE%{%}%b%c%u$PR_BLUE]'
        } else {
            zstyle ':vcs_info:*' formats '[$PR_GREEN↑$PR_WHITE%{%}%b%c%u$PR_BLUE]'
        }
    } else {
        if [[ -n "0" ]] {
            zstyle ':vcs_info:*' formats '[$PR_WHITE%{%}%b%c%u$PR_RED●$PR_BLUE]'
        } else {
            zstyle ':vcs_info:*' formats '[$PR_GREEN↑$PR_WHITE%{%}%b%c%u$PR_RED●$PR_BLUE]'
        }
    }
    vcs_info

}

setopt extended_glob
preexec () {
    if [[ "$TERM" == "screen" ]]; then
    local CMD=${1[(wr)^(*=*|sudo|-*)]}
    echo -n "\ek$CMD\e\\"
    fi
}

setprompt () {
    ###
    # Need this so the prompt will work.
    setopt prompt_subst

    ###
    # See if we can use colors.
    autoload colors zsh/terminfo
    if [[ "$terminfo[colors]" -ge 8 ]]; then
    colors
    fi
    for color in RED GREEN YELLOW BLUE MAGENTA CYAN WHITE; do
    eval PR_$color='%{$terminfo[bold]$fg[${(L)color}]%}'
    eval PR_LIGHT_$color='%{$fg[${(L)color}]%}'
    (( count = $count + 1 ))
    done
    PR_NO_COLOUR="%{$terminfo[sgr0]%}"

    ###
    # See if we can use extended characters to look nicer.
    
    typeset -A altchar
    set -A altchar ${(s..)terminfo[acsc]}
    PR_SET_CHARSET="%{$terminfo[enacs]%}"
    PR_SHIFT_IN="%{$terminfo[smacs]%}"
    PR_SHIFT_OUT="%{$terminfo[rmacs]%}"
    PR_HBAR=${altchar[q]:--}
    PR_ULCORNER=${altchar[l]:--}
    PR_LLCORNER=${altchar[m]:--}
    PR_LRCORNER=${altchar[j]:--}
    PR_URCORNER=${altchar[k]:--}

    ###
    # Decide if we need to set titlebar text.
    
    case $TERM in
    xterm*)
        PR_TITLEBAR=$'%{\e]0;%(!.-=*[ROOT]*=- | .)%n@%m:%~ | ${COLUMNS}x${LINES} | %y\a%}'
        ;;
    screen)
        PR_TITLEBAR=$'%{\e_screen \005 (\005t) | %(!.-=[ROOT]=- | .)%n@%m:%~ | ${COLUMNS}x${LINES} | %y\e\\%}'
        ;;
    *)
        PR_TITLEBAR=''
        ;;
    esac
    
    ###
    # Decide whether to set a screen title
    if [[ "$TERM" == "screen" ]]; then
    PR_STITLE=$'%{\ekzsh\e\\%}'
    else
    PR_STITLE=''
    fi
    
    ###
    # Finally, the prompt.
    PROMPT='$PR_SET_CHARSET$PR_STITLE${(e)PR_TITLEBAR}\
$PR_BLUE$PR_SHIFT_IN$PR_ULCORNER$PR_BLUE$PR_HBAR$PR_SHIFT_OUT(\
$PR_CYAN%$PR_PWDLEN<...<%~%<<\
$PR_BLUE)$PR_SHIFT_IN$PR_HBAR$PR_BLUE$PR_HBAR${(e)PR_FILLBAR}$PR_BLUE$PR_HBAR$PR_SHIFT_OUT(\
$PR_GREEN%(!.%SROOT%s.%n)$PR_GREEN@$PR_GREEN%m\
$PR_BLUE)$PR_SHIFT_IN$PR_HBAR$PR_BLUE$PR_URCORNER$PR_SHIFT_OUT\

$PR_BLUE$PR_SHIFT_IN$PR_LLCORNER$PR_BLUE$PR_HBAR($PR_SHIFT_OUT\
${(e)batt_info}$PR_MAGENTA>>$PR_SHIFT_IN$PR_HBAR$PR_SHIFT_OUT\
$PR_NO_COLOUR '

    RPROMPT=' $PR_MAGENTA$PR_SHIFT_IN$PR_HBAR<<$PR_SHIFT_OUT\
$PR_BLUE${(e)vcs_info_msg_0_}$PR_BLUE)$PR_SHIFT_IN$PR_HBAR$PR_BLUE$PR_LRCORNER$PR_SHIFT_OUT$PR_NO_COLOUR'

    PS2='$PR_BLUE$PR_SHIFT_IN$PR_HBAR$PR_SHIFT_OUT\
$PR_BLUE$PR_SHIFT_IN$PR_HBAR$PR_SHIFT_OUT(\
$PR_LIGHT_GREEN%_$PR_BLUE)$PR_SHIFT_IN$PR_HBAR$PR_SHIFT_OUT\
$PR_BLUE$PR_SHIFT_IN$PR_HBAR$PR_SHIFT_OUT$PR_NO_COLOUR '
}

setprompt