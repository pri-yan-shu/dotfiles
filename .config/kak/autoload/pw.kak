define-command -params 1..4 pw-lm %{
	sh-send "load-module libpipewire-module-filter-chain filter.graph { nodes = [ { type = lv2 name = ""%arg{4}"" plugin = ""%arg{1}"" } ] node.name = ""%arg{4}"" } capture.props { node.name = ""%arg{4}_in"" target.object = ""%arg{2}"" } playback.props { node.name = ""%arg{4}_out"" target.object = ""%arg{3}"" }"
	# sh-send "load-module libpipewire-module-filter-chain filter.graph { nodes = [ { type = lv2 name = ""lv2"" plugin = ""%arg{1}"" } ] } capture.props { node.name = ""%arg{4}_in"" target.object = ""%arg{2}"" } playback.props { node.name = ""%arg{4}_out"" target.object = ""%arg{3}"" }"
}

define-command -params 1 pw-destroy %{
    sh-send "destroy %arg{1}"
}

define-command -params 1..2 pw-lm-cmus %{ pw-lm %arg{1} 'C* Music Player' '' %arg{2} }

complete-command pw-lm shell-script-candidates %{ lv2ls }
complete-command pw-lm-cmus shell-script-candidates %{ lv2ls }

define-command -params 1 pw-getparams %{
    reg r %sh{
        pw-dump | jq -r ".[] | select(.info.props[\"node.name\"] == \"$1\") | .id"
    }
	execute-keys "ggO%reg{r} <esc>!pw-dump %reg{r} | jq -c '.[].info.params.Props.[1].params'<ret>"
	# execute-keys "ggO%reg{r} <esc>!pw-dump %reg{r} | jq -c '.[].info.params.Props.[1]'<ret>"
}

complete-command pw-getparams shell-script-candidates %{
    pw-dump | jq -r '.[] | select(
        .type=="PipeWire:Interface:Node"
        and (.info["n-input-ports"] > 0)
        and (.info.props["media.class"]
        | contains("Audio"))
    ) | "\(.info.props["node.name"])"'
}

define-command pw-setparam %{
    try %{
        # execute-keys 'xs^\d+ <ret>Zxs^(\d+) (.*?)$<ret>'
        execute-keys -draft 'xs^\d+ <ret>xs^(\d+) (.*?)$<ret>!pw-cli set-param %reg{1} Props ''{"params":%reg{2}}''<a-!> >/dev/null<ret>'
    } catch %{
        execute-keys '<c-s>:xifone<ret>:sh-send %reg{.}<ret>'
    }
	# execute-keys "!pw-cli set-param %arg{1} Props '%arg{2}' >/dev/null<ret>"
}


define-command -params 2 pw-link %{
	evaluate-commands %sh{ pw-link -P $1 $2 }
}

define-command -params 2 pw-link-pair %{
	evaluate-commands %sh{
		pw-link -P $1_FL $2_FL
		pw-link -P $1_FR $2_FR
	}
}

complete-command -menu pw-link shell-script-candidates %{ [ $kak_token_to_complete -eq 0 ] && pw-link -i || pw-link -o }

hook global WinSetOption filetype=pw-cli %{
    map window user g ':pw-getparams '
    map window normal <ret> ':pw-setparam<ret>'
    map window insert <ret> '<a-;>:pw-setparam<ret>'
    map window normal <)> '/,\K[\d.]+<ret>'
    map window normal <(> '<a-/>,\K[\d.]+<ret>'
}

