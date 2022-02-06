


format elfobj

include "../_include/include.h"

#e
import "chdr" chdir
function dirch(str value)
    data change#1
    data zero=0
    setcall change chdir(value)
    if change!=zero
        str chdirerr="Change dir err: "
        import "strerrno" strerrno
        call strerrno(chdirerr)
        return chdirerr
    endif
    data noerr=noerror
    return noerr
endfunction

importx "_free" free

import "Scriptfullpath" Scriptfullpath
import "endoffolders" endoffolders

#void/err
function movetoScriptfolder(data forward)
    data path#1
    data ptrpath^path
    data err#1
    data noerr=noerror
    setcall err Scriptfullpath(ptrpath)
    if err!=noerr
        return err
    endif

    data pointer#1
    chars z=0
    setcall pointer endoffolders(path)
    set pointer# z

    setcall err dirch(path)
    if err!=noerr
        return err
    endif

    call free(path)

    call forward()
endfunction

#e
function folder_enterleave_data(ss folder,sd forward,sd data)
    sd err
    data noerr=noerror
    setcall err dirch(folder)
    if err!=noerr
        return err
    endif
    call forward(data)

    ss cursor
    set cursor folder
    sd sz
    import "slen" slen
    setcall sz slen(folder)
    add cursor sz

    import "filepathdelims" filepathdelims

    str back="../"
    while folder!=cursor
        sd bool
        SetCall bool filepathdelims(cursor#)
        If bool==(TRUE)
            setcall err dirch(back)
            if err!=(noerror)
                return err
            endif
        EndIf
        dec cursor
    endwhile
    setcall err dirch(back)
    return err
endfunction

function folder_enterleave(ss folder,data forward)
    data n=0
    call folder_enterleave_data(folder,forward,n)
endfunction




