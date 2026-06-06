require-module sh

declare-option str sh_fifo
declare-option str sh_pid

define-command -params 1.. sh-spawn %{
    evaluate-commands %sh{
        export kak_session kak_client TERM=dumb
        export sh_fifo=$(mktemp -d "${TMPDIR:-/tmp}"/sh.XXXX)

        PATH=/usr/local/bin/kakbin:$PATH

        mkfifo $sh_fifo/in $sh_fifo/out

        exec 3<>$sh_fifo/in
        exec 4<>$sh_fifo/out

        setsid $@ >&4 <&3 2>&1 &

        printf %s\\n \
        "edit -fifo $sh_fifo/out -scroll $!" \
        "set-option buffer sh_pid $!" \
        "set-option buffer sh_fifo $sh_fifo" \
        "set-option buffer modeline_window_info '${PWD##*/} '" \
        "set-option buffer path $kak_opt_path"
    }

    hook -once -always buffer BufCloseFifo .* %{
        nop %sh{
            kill -s HUP $kak_opt_sh_pid
            kill -s CONT $kak_opt_sh_pid
            rm -r $kak_opt_sh_fifo
        }
    }

    set-option buffer filetype shell
}

define-command -params 1.. sh-send %{
    echo -end-of-line -to-file "%opt{sh_fifo}/in" %arg{@}
}

define-command -params 2 sh-new-in %{
    edit -scratch "%val{bufname}:"
    set-option buffer sh_fifo "%arg{1}"
    set-option buffer filetype dash
}

define-command -params 2 sh-cd %{
    set-option buffer path %arg{1}
    set-option buffer modeline_window_info "%arg{2}"
}

define-command -params 1 sh-z %{
    sh-send t %arg{1}
}
complete-command -menu sh-z shell-script-candidates %{ zoxide query --list }

define-command -params 1.. sudo -docstring "Write the content of the buffer using sudo" %{
    evaluate-commands %sh{
        # check if the password is cached
        if ! sudo -n true > /dev/null 2>&1; then
            printf sudo-prompt-password
        fi
        sudo -n -- $@ >$kak_opt_sh_fifo/out 2>&1
    }
}

define-command -hidden sudo-prompt-password %{
    prompt -password 'Password:' %{
        eval -save-regs r %{
            eval -draft -save-regs 'atf|"' %{
                # write the password in a buffer in order to pass it through STDIN to sudo
                # somewhat dangerous, but better than passing the password
                # through the shell scope's environment or interpolating it inside the shell string
                # 'exec |' is pretty much the only way to pass data over STDIN
                reg a %opt{sh_fifo}
                edit -scratch '*sudo-password-tmp*'
                reg '"' "%val{text}"
                exec <a-P>
                reg | %{
                    sudo -S -v 1>/dev/null 2>&1
                    if [ $? -ne 0 ]; then
                        printf 'fail "Incorrect password?"'
                    fi
                }
                exec '|<ret>'
                exec -save-regs '' '%"ry'
                delete-buffer! '*sudo-password-tmp*'
            }
            eval %reg{r}
        }
    }
}

define-command sudo-password %{
    prompt -password Password: %{
        sh-send %val{text}
    }
}

map global lsp c ":sh-cd "
map global lsp z ":sh-z "

add-highlighter shared/shell regions
add-highlighter shared/shell/code default-region group

declare-user-mode shell
map global user s ':enter-user-mode shell<ret>'
map global shell d ":sh-spawn env ENV=%val{config}/.shrc sh -i +m<ret>"
map global shell f ":sh-file "
map global shell r ":sh-spawn /usr/lib/plan9/bin/rc -i<ret>:sh-send . %val{config}/.rcrc<ret>"
map global shell p ":sh-spawn pw-cli<ret>:set-option buffer filetype pw-cli<ret>"
map global shell P ":sh-spawn env PYTHONSTARTUP=%val{config}/.pythonrc python -i<ret>"
map global shell <a-P> ":sh-spawn env PYTHONSTARTUP=%val{config}/.pythonrc python -i<ret>:set-option global sh_fifo %opt{sh_fifo}<ret>"
map global shell n ':sh-new-in %opt{sh_fifo} %opt{sh_pid}<ret>'
map global shell c "!kill -- -$kak_opt_sh_pid<ret>"
map global shell C '!kill -s %val{count} -$kak_opt_sh_pid<ret>'
# map global shell c "!pkill --parent $kak_opt_sh_pid >/dev/null 2>&1<ret>"
# map global shell C "!pkill --parent $kak_opt_sh_pid --signal SIGKILL<ret>"
map global shell e 'xS\n<ret>:sh-send printf "e $PWD/%%reg{.}\n" | kak -p $kak_session'


hook global WinSetOption filetype=shell %{
    map window normal <ret> '<c-s>:xifone<ret>:sh-send %reg{.}<ret>'
    map window normal <a-ret> '<c-s>:xifone<ret>:sh-send %reg{.}<ret>jxGedo<esc>'
    map window insert <ret> '<esc><c-s>x:sh-send %reg{.}<ret>o'
    map window insert <a-ret> '<esc><c-s>x:sh-send %reg{.}<ret>jxGedo<esc>'
    map window insert <s-ret> <ret>
    map window normal = '<a-i>w<a-Z>a'
    map window insert <c-space> ' <c-x>f'

    set-option buffer filetype sh
}

