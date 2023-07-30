



format elfobj

include "../_include/include.h"



#v
function update_got_new(ss text)
    vstr toupdate="Update available at site (to disable this notification uncheck 'Check for updates' from stage preferences). New version: "
    data strtype=stringstring
    import "strvaluedisp" strvaluedisp
    call strvaluedisp(toupdate,text,strtype)
endfunction

import "move_to_share_v" move_to_share_v
importx "_g_object_unref" g_object_unref
importx "_g_idle_add" g_idle_add

importx "_free" free

#void
function update_async_callback(sd ses,sd msg) #,sd data
	sd netmem
	sd netsize
	import "getSessionMessageBody" getSessionMessageBody
	sd bool
	setcall bool getSessionMessageBody(msg,#netmem,#netsize)
	if bool==(TRUE)
		call move_to_share_v()
		sd mem
		sd size
		import "file_get_content" file_get_content
		sd err
		setcall err file_get_content("version.txt",#size,#mem)
		if err==(noerror)
			call update_got_netversion(mem,size,netmem,netsize)
			call free(mem)
		endif
	endif
	call g_idle_add(update_async_sync,ses) #unref session later, not in session callback
endfunction

#bool
function update_async_sync(sd ses)
	call g_object_unref(ses)
	return (FALSE)
endfunction

#void
function update_got_netversion(sd mem,sd size,sd netmem,ss netsize)
	import "memalloc" memalloc
	sd sz=1;add sz netsize
	sd newmem;setcall newmem memalloc(sz)
	if newmem!=(NULL)
		import "cmpmem_s" cmpmem_s
		sd compare;setcall compare cmpmem_s(netmem,netsize,mem,size)

		importx "_memcpy" memcpy
		importx "_printf" printf
		call memcpy(newmem,netmem,netsize)
		add netsize newmem
		set netsize# 0

		if compare==(differentCompare)
			call update_got_new(newmem)
		else
			call printf("version: %s\n",newmem)
		endelse
		call free(newmem)
	endif
endfunction

function update()
	sd up
	setcall up update_get()
	if up==(FALSE)
		return (void)
	endif

	import "uri_queue_content" uri_queue_content
	ss s="https://gist.github.com/colin-i/1c06e597689e204793a7e89fbcf2a481/raw"
	#ss s="http://localhost/b.php"

	call uri_queue_content(s,update_async_callback)
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
importx "_fclose" fclose
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
