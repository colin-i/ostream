

format elfobj

include "../_include/include.h"

#color(base) to a widget
#importx "_gtk_widget_modify_base" gtk_widget_modify
#importx "_gtk_widget_modify_text" gtk_widget_modify
importx "_gtk_widget_modify_bg" gtk_widget_modify
#importx "_gtk_widget_modify_fg" gtk_widget_modify

#void
function setWidgetBase(sd widget,ss in_colors)
	data guint32_pixel=0
	char *=0;char guint16_red#1
	char *=0;char guint16_green#1
	char *=0;char guint16_blue#1
	set guint16_red in_colors#
	inc in_colors;set guint16_green in_colors#
	inc in_colors;set guint16_blue in_colors#
	call gtk_widget_modify(widget,(GTK_STATE_NORMAL),#guint32_pixel)
endfunction

###container preadd actions
#test for scroll viewport need
function viewport_test(sd container,sd widget)
    data null=0

    importx "_g_type_name" g_type_name
    sd obj
    set obj container#
    set obj obj#
    ss typename
    setcall typename g_type_name(obj)
    if typename==null
        return container
    endif

    str scrolled="GtkScrolledWindow"
    import "cmpstr" cmpstr
    Data equal=equalCompare
    sd ret
    setcall ret cmpstr(scrolled,typename)
    if ret!=equal
        return container
    endif

    str signal="set_scroll_adjustments_signal"
    importx "_gtk_widget_class_find_style_property" gtk_widget_class_find_style_property
    setcall ret gtk_widget_class_find_style_property(widget,signal)
    if ret!=null
        return container
    endif

    importx "_gtk_container_add" gtk_container_add
    importx "_gtk_viewport_new" gtk_viewport_new
    sd viewport
    setcall viewport gtk_viewport_new(null,null)
    call gtk_container_add(container,viewport)
    return viewport
endfunction

function container_add(sd container,sd widget)
    setcall container viewport_test(container,widget)
    call gtk_container_add(container,widget)
endfunction

function container_child(sd container,sd widget)
    import "firstwidgetFromcontainer" firstwidgetFromcontainer
    sd old
    setcall old firstwidgetFromcontainer(container)
    data z=0
    if old!=z
        importx "_gtk_widget_destroy" gtk_widget_destroy
        call gtk_widget_destroy(old)
    endif
    call gtk_container_add(container,widget)
endfunction
###

import "getsubject" getsubject

#integer to string to object name
function object_set_dword_name(sd object,sd int_name)
    char str_name#dword_null
    str s_name^str_name
    str dw_str="%u"
    importx "_sprintf" sprintf
    call sprintf(s_name,dw_str,int_name)

    ss name
    setcall name getsubject()
    importx "_g_object_set" g_object_set
    data null=0
    call g_object_set(object,name,s_name,null)
endfunction

function object_get_dword_name(sd object)
    ss name
    setcall name getsubject()

    ss handle_str
    sd ptr_str^handle_str

    data null=0
    importx "_g_object_get" g_object_get
    call g_object_get(object,name,ptr_str,null)

    import "strtoint" strtoint
    sd img
    sd ptr_img^img
    call strtoint(handle_str,ptr_img)

    importx "_g_free" g_free
    call g_free(handle_str)

    return img
endfunction
