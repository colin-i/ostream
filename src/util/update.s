



format elfobj

include "../_include/include.h"

import "uri_queue_content" uri_queue_content


#v
function update_got_new(ss text)
    vstr toupdate="Update available at site (to disable this notification uncheck 'Check for updates' from stage preferences). New version: "
    data strtype=stringstring
    import "strvaluedisp" strvaluedisp
    call strvaluedisp(toupdate,text,strtype)
endfunction

import "move_to_share_v" move_to_share_v

#void
function update_async_callback(sd *session,sd msg) #,sd *data
	sd netmem
	sd netsize
	sd err
	import "getSessionMessageBody" getSessionMessageBody
	setcall err getSessionMessageBody(msg,#netmem,#netsize,(TRUE))
	if err==(noerror)
		call move_to_share_v()
		sd mem
		sd size
		import "file_get_content" file_get_content
		setcall err file_get_content("version.txt",#size,#mem)
		if err==(noerror)
			call update_got_netversion(mem,size,netmem,netsize)
			importx "_free" free
			call free(mem)
		endif
	endif
endfunction

#void
function update_got_netversion(sd mem,sd size,sd netmem,sd netsize)
    #forward to view if it is a new version
    data compare#1
    import "cmpmem_s" cmpmem_s
    setcall compare cmpmem_s(netmem,netsize,mem,size)

    data different=differentCompare
    if compare==different
        import "memtostrFw_s" memtostrFw_s
        const safeversion=1+1+3+1 #hard coded, hard to remember
        chars newvers#safeversion
        vstr newv^newvers
        data sfsize=safeversion
        vdata fw^update_got_new
        call memtostrFw_s(netmem,netsize,newv,sfsize,fw)
    endif
endfunction

function update()
	sd up
	setcall up update_get()
	if up==(FALSE)
		return (void)
	endif

	ss s="https://gist.githubusercontent.com/colin-i/1c06e597689e204793a7e89fbcf2a481/raw/aa1c2e22f404aaa797ac24af20507a45e26178c6/gistfile1.txt"
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
