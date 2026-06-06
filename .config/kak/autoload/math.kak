declare-option -hidden int math_int

define-command -params 3 add %{
    set-option local math_int %arg{1}
    set-option -add local math_int %arg{2}
    set-register %arg{3} %opt{math_int}
}

define-command -params 3 sub %{
    set-option local math_int %arg{1}
    set-option -remove local math_int %arg{2}
    set-register %arg{3} %opt{math_int}
}

define-command -params 3.. switch %{
    evaluate-commands "%%arg{%arg{1}}"
}

define-command -params 2 iter %{
    greater-than %arg{1} 0
    evaluate-commands %arg{2}
    sub %arg{1} 1 t
    iter %reg{t} %arg{2}
}

define-command -params 2 loop %{
    try %{
        evaluate-commands %arg{1}
    } catch %{
        fail condition failed
    }
    evaluate-commands %arg{2}
    loop %arg{1} %arg{2}
}

define-command -params 3 mul %{
    set-register %arg{3} 0
    iter %arg{1} "add %%reg{%arg{3}} %arg{2} %arg{3}"
}

define-command -params 3 div %{
    set-register %arg{3} 0
    set-option local math_int 0
    loop %exp{ greater-than %arg{1} %%reg{%arg{3}} } %exp{
        add %%reg{%arg{3}} %arg{2} %arg{3}
        set-option -add current math_int 1
    }

    set-register %arg{3} %opt{math_int}
}

define-command -params 2 equal-to %{
    less-or-equal %arg(1) %arg(2)
    greater-or-equal %arg(1) %arg(2)
}

define-command -params 2 different-from %{
    try %{
        less-than %arg(1) %arg(2)
    } catch %{
        greater-than %arg(1) %arg(2)
    }
}

define-command -params 2 less-than %{
    set-option local math_int %arg(2)
    set-option -remove local math_int %arg(1)
    set-option -remove local math_int 1

    try %{
        echo %opt(math_int)
    } catch %{
        fail condition failed
    }
}

define-command -params 2 less-or-equal %{
    set-option local math_int %arg(2)
    set-option -remove local math_int %arg(1)
    try %{
        echo %opt(math_int) 
    } catch %{
        fail condition failed
    }
}

define-command -params 2 greater-than %{
    set-option local math_int %arg(1)
    set-option -remove local math_int %arg(2)
    set-option -remove local math_int 1
    try %{
        echo %opt(math_int) 
    } catch %{
        fail condition failed 
    }
}

define-command -params 2 greater-or-equal %{
    set-option local math_int %arg(1)
    set-option -remove local math_int %arg(2)
    try %{
        echo %opt(math_int) 
    } catch %{
        fail condition failed 
    }
}

define-command -params 2 strcmp %{
    evaluate-commands -draft -no-hooks -save-regs '"' %{
        edit -scratch math_strcmp
        set-register dquote %arg{1}
        try %{
            execute-keys -buffer math_strcmp "Ps\A%arg{2}\z<ret>"
        } catch %{
            delete-buffer math_strcmp
            fail condition failed 
        }
        delete-buffer math_strcmp
    }
}

define-command -params 2 strlen %{
    evaluate-commands -no-hooks -save-regs '"' %{
        edit -scratch math_strlen
        set-register dquote %arg{1}
        execute-keys <a-P>
        set-register %arg{2} %val{selection_length}
        delete-buffer math_strlen
    }
}

define-command -params 3.. list-index %{
    set-option local math_int %arg{1}
    set-option -add local math_int 2
    evaluate-commands %exp{
        set-register %arg{2} "%%arg{%opt{math_int}}"
    }
}

define-command -params 2 iter-str %{
}
