


format elfobj

include "../_include/include.h"

function getsubject()
    str nm="name"
    return nm
endfunction

function search_photo_set_scaled(sd pixbuf,sd img)
    importx "_gtk_image_set_from_pixbuf" gtk_image_set_from_pixbuf
    call gtk_image_set_from_pixbuf(img,pixbuf)
endfunction

#ve
function search_photo_set(sd pixbuf,sd img)
    importx "_gdk_pixbuf_get_width" gdk_pixbuf_get_width
    importx "_gdk_pixbuf_get_height" gdk_pixbuf_get_height

    sd w
    sd h
    setcall w gdk_pixbuf_get_width(pixbuf)
    setcall h gdk_pixbuf_get_height(pixbuf)

    sd scale_w=200
    sd scale_h

    #w..h
    #sw..sh
    #sh=h*sw/w
    mult h scale_w
    div h w
    set scale_h h

    data fn^search_photo_set_scaled
    import "pixbuf_scale_forward_data" pixbuf_scale_forward_data
    call pixbuf_scale_forward_data(pixbuf,scale_w,scale_h,fn,img)
endfunction


function search_photo_received(sd *bus,sd msg,sv combo)
	sd pipe
	set pipe combo#

	import "set_pipe_null" set_pipe_null
	call set_pipe_null(pipe)

	add combo :
	import "msgelement_pixbuf_forward_data" msgelement_pixbuf_forward_data
	call msgelement_pixbuf_forward_data(msg,search_photo_set,combo#)

	import "unset_pipe_and_watch" unset_pipe_and_watch
	call unset_pipe_and_watch(pipe)
endfunction


importx "_sprintf" sprintf
importx "_free" free

function search_connect_pixbuf(sd bus,sd combo)
	#add_watch(and maybe not here, it is not spec a subelement) is not posting, maybe gtk_main isn't GMainLoop
	importx "_g_signal_connect_data" g_signal_connect_data
	call g_signal_connect_data(bus,"message::element",search_photo_received,combo,free,0)
endfunction

#void
function search_get_image(ss uri,sd handle)
    ss launcher="uridecodebin uri=\"%s\" ! %s ! gdkpixbufsink"
    ss src
	ss inter
    sd *term=0

	import "get_mxf_inputformat" get_inputformat
    set src uri
	setcall inter get_inputformat()

    sd strs^launcher

    sd mem
    sd ptrmem^mem

    import "allocsum_null" allocsum_null
    sd err
    data noerr=noerror

    setcall err allocsum_null(strs,ptrmem)
    if err!=noerr
        return err
    endif
    call sprintf(mem,launcher,uri,inter)

    import "launch_pipe" launch_pipe
    sd pipeline
    data n=0

    setcall pipeline launch_pipe(mem)

    call free(mem)
    if pipeline==n
        return n
    endif

    import "start_pipe" start_pipe
    setcall err start_pipe(pipeline)
    if err!=noerr
        return err
    endif

    import "bus_default_signals" bus_default_signals
    call bus_default_signals(pipeline)

	import "memalloc" memalloc
	sv data
	setcall data memalloc((2*:))
	if data!=(NULL)
		set data# pipeline
		sv img=:
		add img data
		set img# handle
		import "bus_signals_data" bus_signals_data
		data fn^search_connect_pixbuf
		call bus_signals_data(pipeline,fn,data)
	endif
endfunction
