map global goto a '<esc>:git apply --cached<ret>'
map global goto <a-a> '<esc>:git apply --reverse<ret>'
map global goto s '<esc>:git status -bs --porcelain<ret>'
map global goto S '<esc>:git stash list<ret>'
map global goto l '<esc>:git log --oneline <ret>'
map global goto L '<esc>:git log --oneline -- <c-x>f'
map global goto <a-l> '<esc>:git-log-L<ret>'
map global goto / '<esc>:git log --oneline -S %val{selections}<a-!><home>'
map global goto c '<esc>:git commit --verbose '
map global goto b '<esc>:git blame<ret>'
map global goto B '<esc>:git show-branch<ret>'
map global goto c '<esc>:git checkout<ret>'
map global goto d '<esc>:git diff<ret>'
map global goto D '<esc>:git diff --staged<ret>'
map global goto <a-d> '<esc>:git diff '
map global goto ) '<esc>:git next-hunk<ret>'
map global goto ( '<esc>:git prev-hunk<ret>'
map global goto n '<esc>:new '

define-command git-log-L %{
    set-register dquote %val{selections_desc}
    set-register a %val{buffile}
    edit -scratch *git-log-L*
    execute-keys '<a-P>i-L<esc>a:<c-r>a<space><esc>S,<ret>1s\A\d+(\.\d+)<ret>dx_:git log %val{selection}<a-!><ret>'
    # echo -debug -- %val{selection}
    # git log %val{selection}
    delete-buffer *git-log-L*
}

define-command git-diff-add %{
    reg f %sh{ mktemp -t XXXXXX }
    write %reg{f}
    git add %reg{f}
}

hook global WinSetOption filetype=git-status %{
	map window normal d 'xs[^\s]+$<ret>:git diff -- %val{selections}<ret>'
	map window normal D 'xs[^\s]+$<ret>:git diff --staged -- %val{selections}<ret>'
	map window normal <a-d> 'xs[^\s]+$<ret>:-- %val{selections}<a-!><home> git diff '
	map window normal a 'xs[^\s]+$<ret>:git add -- %val{selections}<ret>'
	map window normal <a-a> 'xs[^\s]+$<ret>:-- %val{selections}<a-!><home> git add '
	map window normal r 'xs[^\s]+$<ret>:git reset -- %val{selections}<ret>'
	map window normal R 'xs[^\s]+$<ret>:-- %val{selections}<a-!><home> git restore '
	# map window normal R 'xs[^\s]+$<ret>:-- %val{selections}<a-!><home> terminal git reset -p '
	map window normal o 'xs[^\s]+$<ret>:-- %val{selections}<a-!><home> git checkout '
	map window normal l 'xs[^\s]+$<ret>:-- %val{selections}<a-!><home> git log --oneline '
}

hook global WinSetOption filetype=git-stash %{
	map window normal p 'x1s^stash@\{(\d+)\}:<ret>:git stash pop %val{selections}<ret>'
	map window normal D 'x1s^stash@\{(\d+)\}:<ret>:git stash drop %val{selections}<ret>'
	map window normal a 'x1s^stash@\{(\d+)\}:<ret>:git stash apply %val{selections}<ret>'
	map window normal s 'x1s^stash@\{(\d+)\}:<ret>:git stash show -p %val{selections}<ret>'
}

hook global WinSetOption filetype=git-diff %{
    map window normal o '/^@@.*?@@.*?^(?=@@)<ret>'
    # map window normal <ret> 'd%s^@@.*?@@.*?^(?=@@)<ret><a-d>p'
    map window object h '^@@.*?@@.*?^(?:(?=@@)|(?=$))'
    map window normal a ':git apply --cached'
    map window normal A ':git apply --cached --reverse'
}

hook global WinSetOption filetype=git-log %{
	map window normal d 'xs^.*?\K\w+<ret>:%val{selections}<a-!><home>git diff '
	map window normal r 'xs^.*?\K\w+<ret>:%val{selections}<a-!><home>git reset '
	map window normal R 'xs^.*?\K\w+<ret>:%val{selections}<a-!><home>terminal git reset -p '
	map window normal o 'xs^.*?\K\w+<ret>:%val{selections}<a-!><home>git checkout '
    map window normal s 'xs^.*?\K\w+<ret>:%val{selections}<a-!><home>git show '
	map window normal l ':git log --oneline --graph -- <c-x>f'
	# map window normal <ret>  m
}

hook global WinSetOption filetype=git-show-branch %{
    map window normal c 'xs\[.*?\]<ret>:git checkout %val{selection}<ret>'
}

hook global WinSetOption filetype=git-.* %{
	map window normal <a-d> ':git diff<ret>'
	map window normal <a-D> ':git diff --cached<ret>'
	map window normal c ':git commit --verbose '
    map window normal <quote> ':try %{db "*%opt{filetype}*"};rename-buffer "*%opt{filetype}*"<ret>'
}

