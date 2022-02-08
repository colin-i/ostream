




format elfobj

include "../_include/include.h"

#key-press-event , false invoke rest of actions
function recoverEnter(data *GtkWidget,data GdkEventKey,data gpointer)
    Const keyvaloff=5*DWORD
    data keyvaloff=keyvaloff

    add GdkEventKey keyvaloff
    data pressedkey#1
    set pressedkey GdkEventKey#

    data enterkey#1
    data true=TRUE
    data false=FALSE
    set enterkey false

    data GDK_Return=0xff0d
    data GDK_KP_Enter=0xff8d

    if pressedkey==GDK_Return
            set enterkey true
    elseif pressedkey==GDK_KP_Enter
            set enterkey true
    endelseif

    if enterkey==true
        import "editWidgetBufferForward" editWidgetBufferForward
        call editWidgetBufferForward(gpointer)
    endif
    return false
endfunction

#GdkEventType type;
#GdkWindow *window;
#gint8 send_event;
#guint32 time;
#guint state;
#guint keyval;
#gint length;
#gchar *string;
#guint16 hardware_keycode;
#guint8 group;
#guint is_modifier : 1;

importx "_g_signal_connect_data" g_signal_connect_data

#v
function connect_signal_data(data instance,str event,data callback,data passdata)
    data null=0
    call g_signal_connect_data(instance,event,callback,passdata,null,null)
endfunction

#v
function connect_signal(data instance,str event,data callback)
    data null=0
    call connect_signal_data(instance,event,callback,null)
endfunction

function connect_clicked(sd instance,sd callback)
    call connect_clicked_data(instance,callback,0)
endfunction
function connect_clicked_data(sd instance,sd callback,sd data)
    call connect_signal_data(instance,"clicked",callback,data)
endfunction

import "double_to_int" double_to_int

#x
function eventbutton_get_coords(sd event,sd p_y)
    importx "_gdk_event_get_coords" gdk_event_get_coords
    sd _x#2
    sd _y#2
    sd _p_x^_x
    sd _p_y^_y
    call gdk_event_get_coords(event,_p_x,_p_y)
    if p_y!=0
        setcall p_y# double_to_int(_p_y)
    endif
    sd x
    setcall x double_to_int(_p_x)
    return x
endfunction
