
format elfobj

import "texter" texter

include "../_include/include.h"

function setplaybin2(data value)
    data playbin2#1
    const propagateplaybin2^playbin2
    set playbin2 value
endfunction

#playbin2
function getplaybin2ptr()
    data propagateplaybin2%propagateplaybin2
    return propagateplaybin2
endfunction

#void gtkwidget::realize
import "gtk_widget_get_window" gtk_widget_get_window
import "gdk_window_ensure_native" gdk_window_ensure_native
import "gst_x_overlay_set_window_handle" gst_x_overlay_set_window_handle
import "gst_x_overlay_get_type" gst_x_overlay_get_type
import "gst_implements_interface_cast" gst_implements_interface_cast

import "gdkGetdrawable" gdkGetdrawable

function video_realize(data widget)
    data window#1
    setcall window gtk_widget_get_window(widget)

    data false=0
    data bool#1
    setcall bool gdk_window_ensure_native(window)
    if bool==false
        str noNative="Couldn't create native window needed for GstXOverlay!"
        call texter(noNative)
    endif

    data drawablehandle#1

    setcall drawablehandle gdkGetdrawable(window)

    #Pass it to playbin2, which implements XOverlay and will forward it to the video sink
    data overlaytype#1
    setcall overlaytype gst_x_overlay_get_type()
    data playbin2ptr#1
    setcall playbin2ptr getplaybin2ptr()
	if playbin2ptr#!=0
		data interfacecast#1
		setcall interfacecast gst_implements_interface_cast(playbin2ptr#,overlaytype)

		call gst_x_overlay_set_window_handle(interfacecast,drawablehandle)
	endif
endfunction

import "unset_playbool" unset_playbool

function gstset()
    data null=0
    call setplaybin2(null)
    call unset_playbool()
endfunction

import "gst_element_set_state" gst_element_set_state
function set_pipe_null(data pipe)
    call gst_element_set_state(pipe,(GST_STATE_NULL))
endfunction

#locations: 1. end of stream;
#           2. top level window closing;
#           3. stream start(stop 1,start 2);
#           4. stop click
#rec: same and also unref at error
function nullifyplaybin()
    data playbin2ptr#1
    setcall playbin2ptr getplaybin2ptr()
    call set_pipe_null(playbin2ptr#)
    call unset_playbool()
endfunction

import "rec_unset" rec_unset
function gstunset()
    #playbin
    data playbin2ptr#1
    setcall playbin2ptr getplaybin2ptr()
    data playbin#1
    set playbin playbin2ptr#
    data null=0
    if playbin!=null
        call nullifyplaybin()
        import "unset_pipe_and_watch" unset_pipe_and_watch
        call unset_pipe_and_watch(playbin)
    endif
    call rec_unset()
endfunction

import "connect_signal" connect_signal
function addSignals(data bus,sd *callbackdata)
    import "endofstream" endofstream
    str eos="message::eos"
    data endofstreamfn^endofstream
    call connect_signal(bus,eos,endofstreamfn)

    import "streamerror" streamerror
    str error="message::error"
    data errorfn^streamerror
    call connect_signal(bus,error,errorfn)

    import "statechanged" statechanged
    str state_changed="message::state-changed"
    data state^statechanged
    call connect_signal(bus,state_changed,state)
endfunction

import "gst_element_factory_make" gst_element_factory_make
#void/err
function gstplayinit(data videowidget)
    data null=0

    import "rec_set" rec_set
    call rec_set(null)

    data playbin2ptr#1
    str playbin2str="playbin2"
    setcall playbin2ptr getplaybin2ptr()
    setcall playbin2ptr# gst_element_factory_make(playbin2str,playbin2str)

    data playbin2#1
    set playbin2 playbin2ptr#
    if playbin2==null
        str factoryerr="Not all elements could be created."
        call texter(factoryerr)
        return factoryerr
    endif
    import "add_bus_signal_watch" add_bus_signal_watch
    call add_bus_signal_watch(playbin2)

    #draw area
    data v_realize^video_realize
    str callrealize="realize"
    call connect_signal(videowidget,callrealize,v_realize)

    import "bus_signals" bus_signals
    #bus signals
    data add_signals^addSignals
    call bus_signals(playbin2,add_signals)
endfunction

