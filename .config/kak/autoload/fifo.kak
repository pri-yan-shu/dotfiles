declare-option str fifo_path

define-command -params 1.. fifo-open %{
    evaluate-commands %sh{
        tmp=$(mktemp -d "${TMPDIR:-/tmp}"/fifo.XXXX)
        mkfifo $tmp/in $tmp/out $tmp/fifo
        exec 3<> $tmp/in; exec 4<> $tmp/out; exec 5<> $tmp/fifo
        # printf '%s' "hook buffer InsertKey .* %{echo -to-file $tmp/in %val{hook_param}}\\n"
        FIFO_PATH=$tmp setsid $@ >$tmp/fifo 2>&1 </dev/null &
        printf "edit -fifo $tmp/out -scroll $!:in\\n"
        printf "set-option buffer fifo_path $tmp"
    }
    hook buffer InsertChar .* %{ echo -to-file "%opt{fifo_path}/in" %val{hook_param} }
    hook -always -once buffer BufCloseFifo .* %{ nop %sh{
        rm -rf $kak_opt_fifo_path
    }}
}
