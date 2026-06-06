define-command z -params 1 %{ cd %arg{1} }
complete-command z -menu shell-script-candidates %{ zoxide query -l } 

define-command f -params 1.. %{ edit %arg{@} }
complete-command f -menu shell-script-candidates %{ rg --files }

define-command F -params 1.. %{ evaluate-commands %sh{
    for file in "$@"; do
        echo "edit $file"
    done
}}
complete-command F -menu shell-script-candidates %{ rg --files }

define-command E -params 1.. %{ evaluate-commands %sh{
    for file in "$@"; do
        echo "edit $file"
    done
}}
complete-command E -menu file

define-command d -params 1.. %{ evaluate-commands %sh{
    for dir in "$@"; do
        find $dir -type f -maxdepth 1 -exec echo edit {} \; | sort
    done
}}
complete-command d -menu file

define-command html-open %{
	exec "<a-a><a-w>s\b\w+:/(/[^\s(){}\[\]]+)\b<ret>"
	evaluate-commands %sh{ xdg-open $kak_selection }
}

define-command delete-buffers-matching -params 1 %{
    evaluate-commands -buffer * %{
        evaluate-commands %sh{ case "$kak_buffile" in $1) echo "delete-buffer" ;; esac }
    }
}

declare-option -hidden str swap_buffer_target
define-command swap-buffer-with -override -params 1 -client-completion %{
    set-option global swap_buffer_target %val{bufname}
    edit -scratch # release current window for other client
    evaluate-commands -client %arg{1} "
        set-option global swap_buffer_target %%val{bufname}
        buffer %opt{swap_buffer_target}
    "
    delete-buffer # delete the temporary scratch buffer
    buffer %opt{swap_buffer_target}
}

define-command diff-buffers -override -params 2 %{
    evaluate-commands %sh{
        file1=$(mktemp)
        file2=$(mktemp)
        echo "
            evaluate-commands -buffer '$1' write -force $file1
            evaluate-commands -buffer '$2' write -force $file2
            edit! -scratch *diff-buffers*
            set buffer filetype diff
            set-register | 'diff -u $file1 $file2; rm $file1 $file2'
            execute-keys !<ret>gg
        "
}}

complete-command diff-buffers buffer

define-command clang-format-cursor %{
    exec -draft <percent>| "clang-format --lines=%val{cursor_line}:%val{cursor_line}" <ret>
}

# define-command -params 1 rg %{ evaluate-commands %sh{
#     file=${1%%:*}
#     rest=${1#$file:}
#     line=${rest%%:*}
#     rest=${rest#$line:}
#     col=${rest%%:*}

#     echo "edit $file $line $col"
# }}

define-command -params 1 r %{
    set-register slash %arg{1}
    rg slash
}

define-command -params 1 rg %{
    prompt -menu -shell-script-candidates %exp{
        trap - INT QUIT; ${kak_opt_grepcmd} -F -- "$kak_reg_%arg{1}" 2>&1 | tr -d '\r' | tr '\t' '  '; 
    } rg: %{
        edit -scratch *rg*
        set-register dquote %val{text}
        execute-keys 'Ps([^:\s]+):(\d+)(?::(\d+))?<ret>'
        edit %reg{1} %reg{2} %reg{3}
        delete-buffer *rg*
    }
}

define-command -override xifone %{
    evaluate-commands -itersel %{
        try %{ execute-keys s\A.\z<ret>x }
    }
}

define-command -hidden jump-anywhere %{
    evaluate-commands -save-regs a %{ # use evaluate-commands to ensure jumps are collapsed
        try %{
            evaluate-commands -draft %{
                execute-keys ',xs([^:\s]+):(\d+)(?::(\d+))?<ret>'
                set-register a %reg{1} %reg{2} %reg{3}
            }
            set-option buffer jump_current_line %val{cursor_line}
            evaluate-commands -try-client %opt{jumpclient} -verbatim -- edit -existing -- %reg{a}
            try %{ focus %opt{jumpclient} }
        }
    }
}

define-command -params 1 pandoc-web %{
	pandoc -f html %arg{1} -t gfm-raw_html -o /tmp/tmp
	edit /tmp/tmp
}

define-command -params 1 mark-location %{
    prompt 'note:' %{
    	nop %sh{
    		echo "$kak_buffile:$kak_cursor_line:$kak_cursor_column $kak_text" >> "$1" 
    	}
    }
}

define-command lsp-enable-wrapper %{
    set-option global lsp_file_watch_support true
    lsp-enable
    lsp-inlay-diagnostics-enable global
    lsp-inlay-hints-enable global
    lsp-diagnostic-lines-disable global
    lsp-semantic-tokens
}

define-command lsp-disable-wrapper %{
    lsp-disable
    try %{ rmhl global/lsp_inlay_diagnostics }
    try %{ rmhl global/lsp_inlay_hints }
}

define-command -params 1.. grep-smart %{
    set-option global jumpclient %val{client}
    new "
        set-option global toolsclient %{%val{client}}
        %arg{@}
        map buffer normal <up> '\k<ret>'
        map buffer normal <down> '\j<ret>'
        hook buffer RawKey <ret> 'quit'
    "
}

define-command -params 1 link %{
    evaluate-commands %sh{
        tmp=$(mktemp)
        curl -sL "$1" -o "$tmp"
        printf "edit -scratch $tmp\\n"
    }
}

define-command toggle-warp %{
    try %{
        remove-highlighter buffer/wrap
    } catch %{
        add-highlighter buffer/wrap wrap -word
    }
}

define-command toggle-num-lines %{
    try %{
        remove-highlighter global/number-lines
    } catch %{
        add-highlighter global/number-lines number-lines -separator '  ' -min-digits 3
    }
}

define-command toggle-git-diff %{
    try %{
        remove-highlighter window/git-diff
    } catch %{
        git show-diff
    }
}

define-command -override context-replace %{
    try %{
        # fails if the line or the line above aren't in a nested block
        exec -draft '<a-:><a-;>K<a-x>s^[^\h]<ret>'
        set window context_replace_range %val{timestamp}
    } catch %{
        eval -draft %{
            # select the text to replace. Everything between the block start and the current line.
            exec 'k[iK<a-x>s^\h*(def\h|for\h|if\h)[^\n]+:\n\K.*(?=\n)<ret>'
            set window context_replace_range %val{timestamp} "%val{selection_desc}|------ CONTEXT ------"
        }
    } catch %{}
}

define-command -params 1.. cflow %{
    edit -scratch *cflow*
    execute-keys %exp{!cflow %arg{@}<ret>}
    # add-highlighter buffer/cflow regex \(
}

complete-command cflow file

define-command -params 1.. prg %{
    nop %sh{ %arg{@} >/dev/null 2>&1 }
}

define-command colorschemes %{
    edit -scratch *colorschemes*
    execute-keys '!find -L "${kak_runtime}/colors" "${kak_config}/colors" -type f -name ''*\.kak''<ret>'
    map buffer normal <ret> 'x_:source %reg{.}<ret>j'
}

declare-option int increment

define-command -params 1 increment-sel %{
    evaluate-commands -itersel -save-regs '"' %{
        set-option current increment %val{selection}
        set-option -add current increment %arg{1}
        set-register dquote %opt{increment}
        execute-keys R
    }
}

define-command -params 1 passwd %{
    prompt -password password: %{
        echo -to-file %arg{1} %val{text}
    }
}
