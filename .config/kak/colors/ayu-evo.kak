# Ayu-dark theme for Kakoune

# Color palette
declare-option str black 'rgb:000000'
declare-option str dark 'rgb:0D1016'
declare-option str gray 'rgb:5c6773'
declare-option str light_gray 'rgb:aaaaaa'
declare-option str dimgray 'rgb:2d3640'
declare-option str white 'rgb:dddddd'
declare-option str blue 'rgb:59c2ff'
declare-option str cyan 'rgb:90e0ff'
declare-option str green 'rgb:aaff55'
declare-option str light_orange 'rgb:ff8732'
declare-option str light_yellow 'rgb:cfca0d'
declare-option str orange 'rgb:ff9933'
declare-option str purple 'rgb:cc99ff'
declare-option str red 'rgb:ff3e25'
declare-option str yellow 'rgb:ffd050'
declare-option str psel "%opt{dimgray}"
declare-option str ssel "%opt{dimgray}"
# declare-option str aqua 'rgb:73b8ff'
# declare-option str white 'rgb:bfbdb6' #
# declare-option str blue_green 'rgb:73b8ff'
# declare-option str psel 'rgba:27374780'
# declare-option str ssel 'rgba:1b273380'
# declare-option str lime 'rgb:91b362'

# declare-option str background %opt{black}
# declare-option str dimmed_background %opt{gray}
# declare-option str foreground %opt{white}

# Reference
# https://github.com/mawww/kakoune/blob/master/colors/default.kak
# For code
set-face global value "%opt{yellow}"
set-face global type "%opt{green}+i"
set-face global variable "%opt{blue}"
set-face global module "%opt{light_gray}"
set-face global function "%opt{yellow}"
set-face global string "%opt{green}"
set-face global keyword "%opt{orange}"
set-face global operator "%opt{orange}"
set-face global attribute "%opt{purple}"
set-face global bracket "%opt{gray}+b"
set-face global argument "%opt{purple}"
set-face global comma "%opt{white}"
set-face global constant "%opt{purple}"
set-face global class "%opt{cyan}"
set-face global comment "%opt{gray}+i"
set-face global meta "%opt{orange}"
set-face global builtin "%opt{purple}+b"

# For markup
set-face global title "%opt{purple}"
set-face global header "%opt{orange}"
set-face global bold "%opt{orange}+b"
set-face global italic "%opt{orange}+i"
set-face global mono "%opt{green}"
set-face global block "%opt{cyan}"
set-face global link "%opt{green}"
set-face global bullet "%opt{green}"
set-face global list "%opt{yellow}"

# Builtin faces
set-face global Default "%opt{white},default"
set-face global PrimarySelection "default,%opt{psel}"
set-face global SecondarySelection "default,%opt{ssel}"
set-face global PrimaryCursor "%opt{black},%opt{blue}"
set-face global SecondaryCursor "%opt{black},%opt{cyan}"
set-face global PrimaryCursorEol "default,%opt{light_orange}"
set-face global SecondaryCursorEol "default,%opt{blue}"
set-face global LineNumbers "%opt{dimgray},default"
set-face global LineNumberCursor "%opt{gray},default+b"
set-face global LineNumbersWrapped "%opt{dimgray},default+i"
set-face global MenuForeground "%opt{black},%opt{gray}+b"
set-face global MenuBackground "%opt{white},default"
set-face global MenuInfo "%opt{white},default"
set-face global Information "%opt{gray},default"
set-face global Error "%opt{red},default"
set-face global StatusLine "%opt{white},rgb:0e0e0e"
# set-face global StatusLine "default,default"
set-face global StatusLineMode PrimarySelection
set-face global StatusLineInfo PrimarySelection
# set-face global StatusLineValue "%opt{orange},default"
set-face global StatusCursor "default,%opt{dimgray}"
set-face global Prompt "%opt{green},default"
set-face global MatchingChar "%opt{blue},default"
set-face global Whitespace "%opt{dimgray},default+f"
set-face global WrapMarker Whitespace
# set-face global BufferPadding "%opt{black},%opt{black}"
