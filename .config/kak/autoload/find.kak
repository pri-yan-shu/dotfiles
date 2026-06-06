declare-option int find_depth 1
declare-option str find_home
declare-option int-list find_pos
declare-option str-list find_dirs

define-command -override find %{
    # save-scroll
    # execute-keys "%%d!find -maxdepth %opt{find_depth} -printf '%%P\n' | sort<ret>;dggd"
    execute-keys "%%d!find -maxdepth %opt{find_depth} -printf '%%P\n' | sort<ret>;dggd%val{cursor_line}g"
}

define-command -params 1..2 find-file %{
    execute-keys "%%d!find %arg{2} %arg{1} -printf '%%P\n' | sort<ret>;dggd%val{cursor_line}g"
}

complete-command find-file file

define-command find-buf %{
    try %{ buffer *find* } catch %{
        edit -scratch *find*
        set-option buffer filetype find
        set-option buffer find_home %val{client_env_PWD}
        find
    }
}

define-command find-enter %{
    evaluate-commands %sh{
        eval set -- "$kak_quoted_selections"

        case $(file -Lb --mime-type -- "$1") in
        inode/directory)
        	printf "cd '$1'\n"
    	;;
        text/*)
        	for file in "$@"; do
            	printf "eval -try-client %%opt{jumpclient} %%{e '$file'}\n"
        	done
        ;;
        application/x-pie-executable)
        	"$@" >/dev/null 2>&1 &
        ;;
    	*)
        	for file in "$@"; do
            	xdg-open "$file" >/dev/null 2>&1 &
        	done
        ;;
        esac
    }
}

define-command find-chmod %{
    reg f %reg{.}
    prompt -init %sh{stat $kak_selection --format %a} permissions: %{
        nop %sh{
            chmod $kak_text "$kak_selection"
        }
    }
}

define-command -hidden -params 1 find-sel %{
    nop %sh{
        cmd=$1
        eval set -- "$kak_quoted_selections"
        $cmd -- "$@"
    }
    find
}

define-command -hidden -params 2 find-prompt %{
    prompt -file-completion %arg{1} %{
        nop %sh{ $2 -- $kak_text }
        find
    }
}

define-command -override -hidden -params 2 find-prompt-sel %{
    prompt -file-completion %arg{1} %{
        nop %sh{
            cmd=$2
            eval set -- "$kak_quoted_selections"
            $cmd -- "$@" $kak_text
        }
        find
    }
}

define-command -params 1 find-set-depth %{
    set-option buffer find_depth %arg{1}
    set-option -add buffer find_depth 1
}

define-command -params 2 tar-extract %{
    execute-keys "!bsdtar -xf %arg{1} -C %arg{2} %val{selections}<ret>"
}

define-command -params 1 tar-find %{
    fifo -name *tar* -scroll bsdtar tf %arg{1}
    map buffer normal <ret> "x_:tar-extract '%arg{1}' <c-x>f"
}

define-command -params 1 find-bookmark %{
    cd %arg{1}
}

complete-command -menu find-bookmark shell-script-candidates %{
    eval set -- "$kak_quoted_opt_find_dirs"
    printf '%q\n' "$@"
}

define-command -params 1 find-bookmark-rm %{
    set-option -remove buffer find_dirs %arg{1}
}
complete-command -menu find-bookmark-rm shell-script-candidates %{
    eval set -- "$kak_quoted_opt_find_dirs"
    printf '%q\n' "$@"
}

hook global BufSetOption filetype=find %{
    map buffer normal D 'x_:find-sel rm<ret>'
    map buffer normal <a-d> 'x_:find-sel %{rm -r}<ret>'
    map buffer normal a 'x_:tar-find %val{selection}<ret>'
    map buffer normal m ':find-bookmark '
    map buffer normal <a-m> ':find-bookmark-rm '
    map buffer normal M ':set-option -add buffer find_dirs %sh{pwd}<ret>'
    map buffer normal e 'x_:e %val{selections}<ret>'
    map buffer normal <ret> 'x_:find-enter<ret>'
    map buffer normal <s-ret> 'x_<a-!>find "$kak_selection" -maxdepth 1 -mindepth 1 -printf ''\n%p''<ret>;' # sort inserts ugly \n in end
    map buffer normal o ':find-prompt dir: "mkdir -p"<ret>'
    map buffer normal i ':find-prompt file: touch<ret>'
    map buffer normal f ':find-prompt fifo: mkfifo<ret>'
    map buffer normal s 'x_:find-prompt link: "ln -s" $PWD/$kak_selection<ret>'
    map buffer normal p 'x_:find-prompt-sel cp: cp<ret>'
    map buffer normal c 'x_:find-prompt-sel mv: mv<ret>'
    map buffer normal L 'x_:echo "%sh{ls -l $kak_selection}"<ret>'
    map buffer normal x 'x_<a-z>aZ,;'
    map buffer normal l ':find-set-depth %val{count}<ret>:find<ret>'
    map buffer normal b ':cd ..<ret>'
    map buffer normal X 'x_:find-chmod<ret>'
    map buffer normal t 'ZgtGbGl<a-s><ret>:hop<ret>'
    map buffer goto ~ '<esc>:cd<ret>:find<ret>'
    map buffer goto r '<esc>:cd /<ret>:find<ret>'
    map buffer goto h '<esc>:cd %opt{find_home}<ret>:find<ret>'
    map buffer user l :find<ret>

    hook -always global EnterDirectory .* %{
        buffer *find*
        find
    }

    add-highlighter buffer/find-dir regex ^[^\n]*/ 0:blue
    add-highlighter buffer/find-img regex (?S)(?:.+/)?(.+\.(?:jfif|jpeg|vst|exr|tga|gif|avif|svg.gz|ppm|webp|vda|heic|heif|dib|tpic|tif|bmp|avifs|svgz|pgm|icb|pbm|tiff|png|pnm|svg|jpe|hif|jpg))$ 1:red
    add-highlighter buffer/find-vid regex (?S)(?:.+/)?(.+\.(?:mp4|mkv|webm|avi|mov|flv|m4v|mpg|mpeg|ts|mts|3gp|ogv|wmv))$ 1:green
    add-highlighter buffer/find-aud regex (?S)(?:.+/)?(.+\.(?:mp3|aac|opus|flac|wav|alac|ape|ogg))$ 1:cyan
    add-highlighter buffer/find-doc regex (?S)(?:.+/)?(.+\.(?:pdf|oxps|epub|fb2))$ 1:cyan
}
