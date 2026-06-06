define-command -params 2 snip %{
    map global insert %arg{1} "<a-semicolon>\a%arg{2}<a-semicolon><a-semicolon><esc><del><esc>_<a-s>&s`<ret>d)Z,i"
}

hook global BufSetOption filetype=zig %{
    snip <a-f> 'fn `(`) ` {
}
'
    snip <a-i> 'if (`) {
}
'
    snip <a-I> 'if (`) |`| {
	`
} else {
	`
}
'
    snip <a-l> 'for (`) |`| {
}
'
    snip <a-L> 'for (`, 0..) |`, `| {
}
'
    snip <a-s> 'const ` = struct {
};
'
    snip <a-S> 'switch (`) {
    ` => `,
}
'
    snip <a-w> 'while (`) {
}
'
}



hook global BufSetOption filetype=(?:c|cpp) %{
    snip <a-f> '` `(`) {
}
'
    snip <a-i> 'if (`) {
}
'
    snip <a-I> 'if (`) {
	`
} else {
	`
}
'
    snip <a-l> 'for (`) {
}
'
    snip <a-L> 'for (`, 0..) |`, `| {
}
'
    snip <a-s> 'struct ` = {
};
'
    snip <a-S> 'switch (`) {
    case `:
        break;
}
'
    snip <a-w> 'while (`) {
}
'
}


