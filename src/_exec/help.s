

format elfobj

import "getptrgerr" getptrgerr
import "gerrtoerr" gerrtoerr

importx "_g_object_unref" g_object_unref

function view_use_file_got_gappinfo_glist(sd gappinfo,sd glist)
    sd ptrgerr
    setcall ptrgerr getptrgerr()

    sd launch_context=0
    importx "_g_app_info_launch" g_app_info_launch
    sd bool
    setcall bool g_app_info_launch(gappinfo,glist,launch_context,ptrgerr)
    sd z=0
    if gappinfo==z
        call gerrtoerr(ptrgerr)
    endif
endfunction

function view_use_file_got_gfile_gappinfo(sd gfile,sd gappinfo)
    sd list=0
    importx "_g_list_append" g_list_append
    importx "_g_list_free" g_list_free
    setcall list g_list_append(list,gfile)
    call view_use_file_got_gappinfo_glist(gappinfo,list)
    call g_list_free(list)
endfunction

function view_use_file_got_gfile(sd gfile)
    sd ptrgerr
    setcall ptrgerr getptrgerr()

    importx "_g_file_query_default_handler" g_file_query_default_handler
    sd cancellable=0
    sd appinfo
    setcall appinfo g_file_query_default_handler(gfile,cancellable,ptrgerr)
    sd z=0
    if appinfo==z
        call gerrtoerr(ptrgerr)
    endif
    call view_use_file_got_gfile_gappinfo(gfile,appinfo)
    call g_object_unref(appinfo)
endfunction

function move_to_html()
    ss filename="use.html"
    sd file
    importx "_g_file_new_for_path" g_file_new_for_path
    setcall file g_file_new_for_path(filename)
    call view_use_file_got_gfile(file)
    call g_object_unref(file)
endfunction

import "move_to_share_v" move_to_share_v
function view_use_file()
	call move_to_share_v()
	import "folder_enterleave" folder_enterleave
	ss loc="html"
	data f^move_to_html
	call folder_enterleave(loc,f)
endfunction
