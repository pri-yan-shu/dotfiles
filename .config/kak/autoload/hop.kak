declare-option -hidden range-specs hop_ranges
declare-option -hidden str-list hop_pairs
declare-option -hidden str hop_str 'tnseriaodhfuwykvplgm'

set-face global hop_face "red+bifa"
add-highlighter global/hop-ranges replace-ranges hop_ranges

define-command hop_generate_pairs %{
    edit -scratch *hop_pairs*
    evaluate-commands -buffer *hop_pairs* -save-regs '"' %{
        set-register dquote %opt{hop_str}
        execute-keys 'Ps.<ret>'
        execute-keys "y%val{selection_count}p<a-d>x_s.<ret>pH"
        set-option global hop_pairs %val{selections}
    }
    delete-buffer *hop_pairs*
}

# need to call everytime after updating hop_str
hop_generate_pairs

define-command hop %{
    set-face window PrimaryCursor default,default
    set-face window SecondaryCursor default,default
    set-face window PrimarySelection default,default
    set-face window SecondarySelection default,default


    execute-keys <c-s>
    execute-keys -draft 'gtGbGls\w{2,}<ret>:reg b %val{selections_desc}<ret>'
    # -draft prevents unnecessary jump markers, but doesn't work with offscreen main cursor
    #

    evaluate-commands -no-hooks %{

    edit -scratch *hop*
    execute-keys '<">b<a-P>s,\d+\.\d+<ret><a-c>+2|{hop_face}<esc>:reg dquote %opt{hop_pairs}<ret>Pa <esc>x_S <ret>'
    set-register a %val{selections}
    delete-buffer *hop*

    }

    set-option -add window hop_ranges %reg{a}

    on-key %{
        set-register c %val{key}
        on-key %{
            unset-option window hop_ranges
            unset-face window PrimarySelection
            unset-face window SecondarySelection
            unset-face window PrimaryCursor
            unset-face window SecondaryCursor

            try %{
                edit -scratch *hop*
                execute-keys "<dquote>a<a-P><a-k>\Q%reg{c}%val{key}\E\z<ret>s\A\d+\.\d+<ret>"
                execute-keys "<dquote>b<a-P><a-k>\A\Q%reg{.}<a-!>,<ret>"

                set-register c %val{selection}
                delete-buffer *hop*
                # execute-keys <c-o>
                select %reg{c}
                # execute-keys <c-s>
            } catch %{
                delete-buffer *hop*
            }
        }
    }
}

