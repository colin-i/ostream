


format elfobj

include "../../_include/include.h"

function stage_crop()
    import "stage_frame_dialog" stage_frame_dialog
    ss title="Crop the selection"
    data init^stage_crop_init
    data on_ok^stage_crop_set
    call stage_frame_dialog(init,on_ok,title)
endfunction

const stage_crop_tool_init=0
const stage_crop_tool_input=1
const stage_crop_tool_preview=2
const stage_crop_tool_set=3

importx "_gtk_widget_set_size_request" gtk_widget_set_size_request
const action_height=50

function stage_crop_init(sd vbox,sd dialog)
    sd dlg
    setcall dlg stage_crop_dialog()
    set dlg# dialog
    call stage_crop_tool((stage_crop_tool_init),vbox)
    importx "_gtk_dialog_get_action_area" gtk_dialog_get_action_area
    sd abox
    setcall abox gtk_dialog_get_action_area(dialog)
    call gtk_widget_set_size_request(abox,-1,(action_height))
endfunction

function stage_crop_set()
    call stage_crop_tool((stage_crop_tool_input))
    call stage_crop_tool((stage_crop_tool_set))
endfunction

function stage_crop_tool(sd action,sd vbox)
    if action==(stage_crop_tool_init)
        import "hboxfield_cnt" hboxfield_cnt
        sd hbox
        setcall hbox hboxfield_cnt(vbox)

        import "vboxfield" vboxfield
        sd dimensions
        setcall dimensions vboxfield(hbox)

        import "label_and_edit" label_and_edit

        ss left_t="Left: "
        ss top_t="Top: "
        ss right_t="Right: "
        ss bottom_t="Bottom: "

        data left_entry#1
        data top_entry#1
        data right_entry#1
        data bottom_entry#1

        setcall left_entry label_and_edit(dimensions,left_t)
        setcall top_entry label_and_edit(dimensions,top_t)
        setcall right_entry label_and_edit(dimensions,right_t)
        setcall bottom_entry label_and_edit(dimensions,bottom_t)

        import "stage_get_sel_pixbuf" stage_get_sel_pixbuf
        data pixbuf#1
        sd p_pixbuf^pixbuf
        call stage_get_sel_pixbuf(p_pixbuf)

        data width_orig#1
        data height_orig#1

        importx "_gdk_pixbuf_get_width" gdk_pixbuf_get_width
        importx "_gdk_pixbuf_get_height" gdk_pixbuf_get_height
        setcall width_orig gdk_pixbuf_get_width(pixbuf)
        setcall height_orig gdk_pixbuf_get_height(pixbuf)

        sd text_data#100/4
        ss text^text_data
        ss format="%s: %u"
        ss w="Original Width"
        ss h="Original Height"

        importx "_gtk_vbox_new" gtk_vbox_new
        sd origs
        setcall origs gtk_vbox_new(0,0)
        import "boxpackstart" boxpackstart
        call boxpackstart(vbox,origs,0,20)

        importx "_sprintf" sprintf
        import "labelfield_l" labelfield_l

        call sprintf(text,format,w,width_orig)
        call labelfield_l(text,origs)

        call sprintf(text,format,h,height_orig)
        call labelfield_l(text,origs)

        data left#1
        data top#1
        data right#1
        data bottom#1
        set left 0
        set top 0
        set right width_orig
        set bottom height_orig

        import "buttonfield" buttonfield
        import "connect_clicked" connect_clicked
        importx "_gtk_button_set_label" gtk_button_set_label

        sd button
        setcall button buttonfield(dimensions)
        ss pre="Preview"
        call gtk_button_set_label(button,pre)
        data f^stage_crop_preview
        call connect_clicked(button,f)

        #the maximize button
        sd button_max
        setcall button_max buttonfield(dimensions)
        ss maximize="Maximize dialog"
        call gtk_button_set_label(button_max,maximize)
        data f_max^stage_crop_maximize
        call connect_clicked(button_max,f_max)

        import "drawfield" drawfield
        data display#1
        const p_display^display
        setcall display drawfield(hbox)
        call gtk_widget_set_size_request(display,320,240)
        import "connect_signal" connect_signal
        str expose="expose-event"
        data fn^stage_crop_preview_expose
        call connect_signal(display,expose,fn)
    elseif action==(stage_crop_tool_input)
    #preview or set
        sd value
        sd p_value^value
        sd bool

        import "entry_to_int_min_N_max_M" entry_to_int_min_N_max_M

        setcall bool entry_to_int_min_N_max_M(right_entry,p_value,1,width_orig)
        if bool!=0
            set right value
        endif
        setcall bool entry_to_int_min_N_max_M(bottom_entry,p_value,1,height_orig)
        if bool!=0
            set bottom value
        endif
        sd max
        set max right
        dec max
        setcall bool entry_to_int_min_N_max_M(left_entry,p_value,0,max)
        if bool!=0
            set left value
        endif
        set max bottom
        dec max
        setcall bool entry_to_int_min_N_max_M(top_entry,p_value,0,max)
        if bool!=0
            set top value
        endif
    else
        import "pixbuf_new_subpixels" pixbuf_new_subpixels
        sd croppixbuf
        setcall croppixbuf pixbuf_new_subpixels(pixbuf,left,top,right,bottom)
        if croppixbuf==0
            return 0
        endif

        if action==(stage_crop_tool_preview)
            import "widget_draw_pixbuf" widget_draw_pixbuf
            call widget_draw_pixbuf(display,croppixbuf)
            importx "_g_object_unref" g_object_unref
            call g_object_unref(croppixbuf)
        else
        #if action==(stage_crop_tool_set)
            import "stage_sel_replace_pixbuf" stage_sel_replace_pixbuf
            call stage_sel_replace_pixbuf(croppixbuf)
        endelse
    endelse
endfunction

function stage_crop_preview(sd *widget,sd *data)
    call stage_crop_tool((stage_crop_tool_input))
    import "widget_redraw" widget_redraw
    sd p%p_display
    call widget_redraw(p#)
    call stage_crop_tool((stage_crop_tool_preview))
endfunction

function stage_crop_preview_expose(sd *draw,sd *event,sd *data)
    call stage_crop_tool((stage_crop_tool_preview))
    #false to propagate all actions
    return 0
endfunction

function stage_crop_dialog()
    data dialog#1
    return #dialog
endfunction

function stage_crop_maximize()
    importx "_gtk_window_maximize" gtk_window_maximize
    sd dlg
    setcall dlg stage_crop_dialog()
    sd dialog
    set dialog dlg#
    #
    importx "_gtk_widget_get_window" gtk_widget_get_window
    sd wind
    importx "_gdk_window_get_width" gdk_window_get_width
    importx "_gdk_window_get_height" gdk_window_get_height
    call gtk_window_maximize(dialog)
    setcall wind gtk_widget_get_window(dialog)
    sd w
    sd h
    setcall w gdk_window_get_width(wind)
    setcall h gdk_window_get_height(wind)
    sub h (action_height)
    #
    importx "_gtk_window_resize" gtk_window_resize
    call gtk_window_resize(dialog,w,h)
endfunction
