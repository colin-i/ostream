




format elfobj

include "../_include/include.h"

importx "_fopen" fopen
importx "_fclose" fclose
importx "_fseek" fseek
importx "_ftell" ftell
importx "_fread" fread

import "memoryalloc" memoryalloc
import "strerrno" strerrno


##file base
#err
Function openfile(data pfile,str path,str fmode)
        data null=0
        SetCall pfile# fopen(path,fmode)
        If pfile#==null
            str err="Cannot open a file. Error: "
            call strerrno(err)
            return err
        EndIf
        Data noerr=noerror
        Return noerr
EndFunction

function getreadmode()
    str read="rb"
    return read
endfunction

function getwritemode()
    str write="wb"
    return write
endfunction

#e
function seek_err(sd seekint)
    If seekint!=0
        str seekerr="File seek error: "
        call strerrno(seekerr)
        return seekerr
    endif
    return (noerror)
endfunction

#e
function file_seek(sd file,sd off,sd method)
    data seekint#1
    SetCall seekint fseek(file,off,method)
    sd err
    setcall err seek_err(seekint)
endfunction

#e
function file_seek_set(sd file,sd off)
    sd err
    setcall err file_seek(file,off,(SEEK_SET))
    return err
endfunction

#e
function file_seek_end(sd file)
    sd err
    setcall err file_seek(file,0,(SEEK_END))
    return err
endfunction
#e
function file_seek_cursor(sd file,sd off)
    sd err
    setcall err file_seek(file,off,(SEEK_CUR))
    return err
endfunction

#e
function file_tell(sd file,sd p_sz)
    setcall p_sz# ftell(file)
    if p_sz#==-1
        str ftellerr="File tell error: "
        call strerrno(ftellerr)
        return ftellerr
    endif
    return (noerror)
endfunction

#err
function file_length(sd file,sd ptr_size)
    sd err
    setcall err file_seek_end(file)
    if err!=(noerror)
        return err
    endif

    setcall err file_tell(file,ptr_size)
    return err
endfunction

#e
function file_sizeofseek_offset_plus_size(sd file,sd size,sd filepos,sd p_sizeofseek)
    sd file_offset
    sd ptr_file_offset^file_offset
    sd err
    setcall err file_tell(file,ptr_file_offset)
    if err!=(noerror)
        return err
    endif
    add filepos size
    sub filepos file_offset
    set p_sizeofseek# filepos
    return (noerror)
endfunction

#e
function file_seek_offset_plus_size(sd file,sd size,sd filepos)
    #get size of seek
    sd sizeofseek
    sd p_sizeofseek^sizeofseek
    sd err
    setcall err file_sizeofseek_offset_plus_size(file,size,filepos,p_sizeofseek)
    if err!=(noerror)
        return err
    endif

    #seek
    setcall err file_seek_cursor(file,sizeofseek)
    if err!=(noerror)
        return err
    endif
    return (noerror)
endfunction

#rename return
function change_name(ss oldpath,ss newpath)
    importx "_rename" rename
    import "texter" texter
    sd ret
    setcall ret rename(oldpath,newpath)
    if ret!=0
        call texter("rename error")
    endif
    return ret
endfunction

##forward simple

#err/returns what forward returns
function file_forward(ss path,sd method,sd forward)
    sd returnvalue
    data noerr=noerror
    sd file
    sd ptrfile^file
    SetCall returnvalue openfile(ptrfile,path,method)
    If returnvalue!=noerr
            Return returnvalue
    EndIf
    setcall returnvalue forward(file,path)
    call fclose(file)
    return returnvalue
EndFunction

##read

#err
function readtomem(data file,data ptrsize,data ptrmem,data offset,data trail)
    sd size
    sd ptr_size^size
    sd err
    setcall err file_length(file,ptr_size)
    if err!=(noerror)
        return err
    endif

    #seek back for reading
    Call fseek(file,0,(SEEK_SET))

    Set ptrsize# size

    add size offset
    add size trail

    data noerr=noerror
    SetCall err memoryalloc(size,ptrmem)
    If err!=noerr
        return err
    endif

    Data mem#1
    Set mem ptrmem#

    add mem offset

    data byte=1
    Call fread(mem,byte,ptrsize#,file)

    return noerr
endfunction

#err
#get: offset+size+trail
Function file_get_content_offset_trail(str path,data ptrsize,data ptrmem,data offset,data trail)
        Data err#1
        Data noerr=noerror

        Data file#1
        Data ptrfile^file

        str readfile#1
        setcall readfile getreadmode()
        SetCall err openfile(ptrfile,path,readfile)
        If err!=noerr
                Return err
        EndIf

        setcall err readtomem(file,ptrsize,ptrmem,offset,trail)
        Call fclose(file)
        Return err
EndFunction

#err
function file_get_content(str path,data ptrsize,data ptrmem)
    data err#1
    data null=0
    setcall err file_get_content_offset_trail(path,ptrsize,ptrmem,null,null)
    return err
EndFunction

function file_get_content_forward(ss filename,sd forward)
    sd err
    sd noerr=noerror

    sd size
    sd ptr_size^size
    sd mem
    sd ptr_mem^mem
    setcall err file_get_content(filename,ptr_size,ptr_mem)
    if err!=noerr
        return err
    endif
    call forward(mem,size)
    importx "_free" free
    call free(mem)
endfunction

#e
function file_forward_read(ss path,sd forward)
    sd method
    setcall method getreadmode()
    sd returnvalue
    setcall returnvalue file_forward(path,method,forward)
    return returnvalue
endfunction
#e
function file_read(sd mem,sd size,sd file)
    sd readed
    setcall readed fread(mem,1,size,file)
    if readed!=size
        str er="Read error: "
        call strerrno(er)
        return er
    endif
    return (noerror)
endfunction
#e
function file_get_size_forward(sd file,sd size,sd forward)
    sd mem
    sd p_mem^mem
    sd err
    SetCall err memoryalloc(size,p_mem)
    If err!=(noerror)
        return err
    endif
    SetCall err file_read(mem,size,file)
    If err!=(noerror)
        return err
    endif
    call forward(mem,size)
    call free(mem)
    return (noerror)
endfunction
#e
function file_get_dword(sd file,sd p_dw)
    sd err
    setcall err file_read(p_dw,4,file)
    return err
endfunction
#e
function file_get_dword_reverse(sd file,sd p_dw)
    sd err
    setcall err file_get_dword(file,p_dw)
    if err!=(noerror)
        return err
    endif
    import "dword_reverse" dword_reverse
    setcall p_dw# dword_reverse(p_dw#)
    return (noerror)
endfunction
#err
#function file_seek_cursor_get_dword(sd file,sd offset,sd p_dw)
#    sd err
#    setcall err file_seek_cursor(file,offset)
#    if err!=(noerror)
#        return err
#    endif
#    setcall err file_get_dword(file,p_dw)
#    if err!=(noerror)
#        return err
#    endif
#    return (noerror)
#endfunction
#err
function file_seek_cursor_get_dword_reverse(sd file,sd offset,sd p_dw)
    sd err
    setcall err file_seek_cursor(file,offset)
    if err!=(noerror)
        return err
    endif
    setcall err file_get_dword_reverse(file,p_dw)
    if err!=(noerror)
        return err
    endif
    return (noerror)
endfunction

#err
function file_read_and_back_with_intervening_call(sd mem,sd size,sd file)
    sd err
    #the intervening call is used when a read(write) call follows a write(read) call
    setcall err file_seek_cursor(file,0)
    if err!=(noerror)
        return err
    endif
    #
    setcall err file_read(mem,size,file)
    if err!=(noerror)
        return err
    endif
    sd pos
    sd p_pos^pos
    setcall err file_tell(file,p_pos)
    if err!=(noerror)
        return err
    endif
    sub pos size
    setcall err file_seek_set(file,pos)
    if err!=(noerror)
        return err
    endif
    return (noerror)
endfunction

##write

function file_write_forward(ss filename,sd forward)
    sd method
    setcall method getwritemode()
    call file_forward(filename,method,forward)
endfunction

#e
function file_write(sd buffer,sd size,sd file)
    data z=0
    data noe=noerror
    if size==z
        return noe
    endif
    data byte=1
    sd sizewrote
    importx "_fwrite" fwrite
    setcall sizewrote fwrite(buffer,byte,size,file)
    if sizewrote!=z
        return noe
    endif
    str er="File write error number: "
    call strerrno(er)
    return er
endfunction
#bool
function file_write_string(sd string,sd file)
    import "slen" slen
    sd len
    setcall len slen(string)
    inc len
    sd err
    setcall err file_write(string,len,file)
    if err!=(noerror)
        return 0
    endif
    return 1
endfunction

#bool
function file_seekSet_setDwRev_goEnd(sd file,sd offset,sd dw)
    sd err
    setcall err file_seek_set(file,offset)
    if err!=(noerror)
        return 0
    endif
    sd p_dw^dw
    setcall dw dword_reverse(dw)
    setcall err file_write(p_dw,4,file)
    if err!=(noerror)
        return 0
    endif
    setcall err file_seek_end(file)
    if err!=(noerror)
        return 0
    endif
    return 1
endfunction

#e
function file_set_dword(sd file,sd position,sd ptr_value)
    sd err

    sd pos
    sd p_pos^pos
    setcall err file_tell(file,p_pos)
    if err!=(noerror)
        return err
    endif

    setcall err file_seek(file,position,(SEEK_SET))
    if err!=(noerror)
        return err
    endif

    setcall err file_write(ptr_value,4,file)
    if err!=(noerror)
        return err
    endif

    setcall err file_seek_set(file,pos)
    if err!=(noerror)
        return err
    endif

    return (noerror)
endfunction
