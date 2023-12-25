
format elfobj

importx "_g_error_free" g_error_free

import "texter" texter
import "geterrno" geterrno

include "../_include/include.h"

#get pointer
function getptrgerr()
    data gerror#1
    data ptrgerror^gerror
    data null=0
    set gerror null
    return ptrgerror
endfunction

#view gerror
function view_gerror_message(data gerror)
    #typedef guint32 GQuark;
    #GQuark       domain
    #gint         code
    #gchar       *message

    data pointer#1
    set pointer gerror
    data qword=QWORD
    add pointer qword

    call texter(pointer#)
endfunction

#view and clean
function gerrtoerr(data ptrgerror)
    call view_gerror_message(ptrgerror#)
    call g_error_free(ptrgerror#)
endfunction

import "strvaluedisp" strvaluedisp

#void
#errno
function strerrno(str text)
        data err#1
        setcall err geterrno()
        data si=stringinteger
        call strvaluedisp(text,err,si)
endfunction




