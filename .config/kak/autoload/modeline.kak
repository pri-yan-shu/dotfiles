declare-option str modeline_window_info
declare-option int modeline_int

hook global WinDisplay .*(?!modeline).* mod
hook global WinClose .*(?!modeline).* mod
# hook global WinDisplay .* modeline
# hook global WinClose .* modeline
# hook global WinResize .* modeline
hook global BufWritePost .* modeline
hook global FocusIn .* %{ set-face window StatusLineMode PrimarySelection }
hook global FocusOut .* %{ set-face window StatusLineMode StatusLine }

define-command mod %{
    evaluate-commands -save-regs am %{
        try %{
            strcmp %val{modified} true
            set-register m '+u'
        }

    	evaluate-commands -draft -save-regs '"' %{
            set-register a "\A\Q%val{bufname}\E\z"
            set-register dquote %val{buflist}

            edit -scratch modeline

            evaluate-commands -buffer modeline %{
                execute-keys <a-P>

                try %{ execute-keys -draft "<a-k>\A\*debug\*\z<ret>d" }
                try %{ execute-keys -draft "s%reg{a}<ret>i{%reg{m}@PrimarySelection}<esc>a{StatusLine}<esc>" }
                try %{ execute-keys -draft s\A.*/<ret>d }

                execute-keys 'i <esc>a <esc>x_'

                set-register a %val{selection}
            }

            delete-buffer modeline
    	}

        set-option window modelinefmt "%reg{a} {StatusLineMode} %opt{modeline_window_info}%val{session}"
    }
}

define-command -hidden modkak %{
    set-register dquote %val{buflist}
    set-register slash "\A\Q%val{bufname}\E\z"
    strlen "%opt{modeline_window_info} %val{session}" a
    div %val{window_width} 2 b
    sub %reg{b} %reg{a} b

    edit -scratch *modeline*
    execute-keys <a-P>
    execute-keys -draft '<a-k><ret>i<ret><esc>a<ret>'
    execute-keys -draft '<a-k>\A\*debug\*\z<ret>d'
    execute-keys -draft 'a  <esc>s.*/<ret>d'

    execute-keys '3gx_s^.{,%reg{b}<a-!>}<ret>'
    set-register c %val{selection}
    add %reg{a} %val{selection_length} a
    execute-keys '2gxH'
    set-register b %val{selection}
    sub %val{window_width} %reg{a} a
    sub %reg{a} %val{selection_length} a
    execute-keys '1gxHs.{,%reg{a}<a-!>}\z<ret>'
    set-register a %val{selection}

    try %{
        strcmp %val{modified} true
        set-register m '+u'
    }
    delete-buffer *modeline*
    set-option buffer modelinefmt "%reg{a}{%reg{m}@PrimarySelection} %reg{b} {StatusLine}%reg{c}{StatusLineMode}%opt{modeline_window_info} %val{session}"
}

define-command reset-debug %{
    echo -debug ''
    arrange-buffers *debug*
}

define-command -hidden -params ..1 modeline %{
    set-option window modelinefmt %sh{
    	[ $kak_modified = "true" ] && modified='+u'
    	[ -n "$1" ] && hop="true"

    	stripped_bef=${kak_quoted_buflist%%"$kak_quoted_bufname"*}
        eval set -- "$stripped_bef"
        [ "$1" = '*debug*' ] && shift || printf 'reset-debug\n' > $kak_command_fifo
        for buffer in "$@"; do
        	before_mod="$before_mod ${buffer##*/} "
        done

        before_len=$(($kak_window_width / 2))
        [ ${#before_mod} -lt $before_len ] && before_len=${#before_mod}

        bufname=${kak_bufname##*/}

        after_len=$(($kak_window_width - $before_len - ${#kak_session} - ${#bufname} - ${#kak_opt_modeline_window_info}))

    	stripped_aft=${kak_quoted_buflist##*"$kak_quoted_bufname"}
        eval set -- "$stripped_aft"
        for buffer in "$@"; do
        	buf=${buffer##*/}
        	[ $((${#after_mod} + ${#buf})) -gt $after_len ] && break
        	after_mod="$after_mod $buf "
        done

        printf "$before_mod{$modified@PrimarySelection} $bufname {StatusLine}$after_mod{StatusLineMode} %%opt{modeline_window_info}%%val{session}"
    }
}

hook global RawKey <mouse:press:left:0\.(\d+)> %{
    echo -debug x: %val{hook_param_capture_1}
    modeline-click %val{hook_param_capture_1}
}

define-command -hidden -params 1 modeline-click %{
    evaluate-commands -no-hooks -draft -save-regs '"' %{
        set-register dquote %opt{modelinefmt}
        edit -scratch modeline-click
        execute-keys -buffer modeline-click 'Ps \K\{.*?}dx_'
    }
}

define-command -hidden -params 1 modeline-buf %{
    strlen "%opt{modeline_window_info}%val{session}" a
    set-register dquote %val{buflist}
    sub %val{window_width} %arg{1} b
    sub %reg{b} %reg{a} b
    edit -scratch modeline-buf
    execute-keys "<a-P>a  <esc>s.*/<ret>dA<c-r>a<esc><a-h>%reg{1}h<a-i><a-w>"
    set-register a %val{selection}
    delete-buffer modeline-buf
    buffer %reg{a}
    echo %reg{a} %reg{b}
}
