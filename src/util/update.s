



format elfobj

include "../_include/include.h"

import "free" free
import "g_object_unref" g_object_unref

import "file_get_content" file_get_content
import "uri_get_content" uri_get_content


#v
function update_got_new(str text)
    str toupdate="Update available at site (to disable this notification uncheck 'Check for updates' from stage preferences). New version: "
    data strtype=stringstring
    import "strvaluedisp" strvaluedisp
    call strvaluedisp(toupdate,text,strtype)
endfunction

#void/err
function update_got_localversion(data mem,data size)
    data msg#1
    data ptrmsg^msg
    str uri="https://gist.githubusercontent.com/colin-i/1c06e597689e204793a7e89fbcf2a481/raw/1fbcffc89fdcbd2e663c1e102378733ceb5155a1/gistfile1.txt"
    str msgmem#1
    data msgsize#1
    data ptrmsgmem^msgmem
    data ptrmsgsize^msgsize
    data err#1
    data noerr=noerror
    setcall err uri_get_content(uri,ptrmsg,ptrmsgmem,ptrmsgsize)
    if err!=noerr
        return err
    endif

    #forward to view if it is a new version
    data compare#1
    import "cmpmem_s" cmpmem_s
    setcall compare cmpmem_s(msgmem,msgsize,mem,size)

    data different=differentCompare
    if compare==different
        import "memtostrFw_s" memtostrFw_s
        const safeversion=20
        chars newvers#safeversion
        str newv^newvers
        data sfsize=safeversion
        data fw^update_got_new
        call memtostrFw_s(msgmem,msgsize,newv,sfsize,fw)
    endif
    #

    call g_object_unref(msg)
endfunction

function update()
    sd up
    setcall up update_get()
    if up==(FALSE)
        return (void)
    endif

    str localversion="version.txt"

    data err#1
    data noerr=noerror

    data size#1
    data ptrsize^size
    str mem#1
    data ptrmem^mem
    setcall err file_get_content(localversion,ptrsize,ptrmem)
    if err!=noerr
        return (void)
    endif
    call update_got_localversion(mem,size)
    call free(mem)
endfunction

function update_path()
    str update_fname="update.data"
    return update_fname
endfunction
function update_mem()
    data mem#1
    return #mem
endfunction
import "openfile" openfile
import "fclose" fclose
function update_set(sd value)
    ss path
    setcall path update_path()
    sd err
    sd file
    setcall err openfile(#file,path,"wb")
    if err!=(noerror)
        return (void)
    endif
    import "file_write" file_write
    call file_write(#value,4,file)
    call fclose(file)
    sd mem
    setcall mem update_mem()
    set mem# value
endfunction
#file_value
function update_get()
    ss path
    setcall path update_path()
    sd err
    sd file
    setcall err openfile(#file,path,"rb")
    if err!=(noerror)
        return (FALSE)
    endif
    import "file_get_dword" file_get_dword
    sd value=0
    call file_get_dword(file,#value)
    call fclose(file)
    sd mem
    setcall mem update_mem()
    set mem# value
    return value
endfunction
