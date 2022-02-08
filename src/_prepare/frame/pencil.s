


format elfobj

include "../../_include/include.h"

importx "_gtk_widget_get_window" gtk_widget_get_window

const stage_pencil_pixbuf_set=0
const stage_pencil_pixbuf_get=1
#const stage_pencil_pixbuf_on_ok=2
#pixbuf
function stage_pencil_pixbuf(sd action,sd value)
    data pixbuf#1
    if action==(stage_pencil_pixbuf_set)
        set pixbuf value
    elseif action==(stage_pencil_pixbuf_get)
        return pixbuf
    else
    #if action==(stage_pencil_on_ok)
    endelse
endfunction

const stage_pencil_cursor_set=0
const stage_pencil_cursor_get=1
const stage_pencil_cursor_free=2

importx "_g_object_unref" g_object_unref

#cursor
function stage_pencil_cursor(sd action)
    data cursor#1
    if action==(stage_pencil_cursor_set)
        importx "_gdk_cursor_new" gdk_cursor_new
        setcall cursor gdk_cursor_new((GDK_PENCIL))
    elseif action==(stage_pencil_cursor_get)
        return cursor
    else
        importx "_gdk_cursor_unref" gdk_cursor_unref
        call gdk_cursor_unref(cursor)
    #if action==(stage_pencil_cursor_free)
    endelse
endfunction

#color widget
function stage_pencil_color(sd action,sd value)
    data color#1
    if action==(value_set)
        set color value
    else
    #if action==(value_get)
        return color
    endelse
endfunction

#draw widget
function stage_pencil_draw(sd action,sd value)
    data drawfield#1
    if action==(value_set)
        set drawfield value
    else
    #if action==(value_get)
        return drawfield
    endelse
endfunction

function stage_pencil_zoomvalue(sd action,sd value)
    data zoomfield#1
    if action==(value_set)
        set zoomfield value
    else
        import "hscale_get" hscale_get
        sd pos
        setcall pos hscale_get(zoomfield)
        return pos
    endelse
endfunction

function stage_pencil_size_entry()
    data size_entry#1
    return #size_entry
endfunction

##parts fns


function stage_pencil()
    sd pixbuf=0
    sd p_pixbuf^pixbuf
    import "stage_get_sel_pixbuf" stage_get_sel_pixbuf
    call stage_get_sel_pixbuf(p_pixbuf)
    if pixbuf==0
        return 0
    endif

    import "pixbuf_copy" pixbuf_copy
    sd workingpixbuf
    setcall workingpixbuf pixbuf_copy(pixbuf)
    if workingpixbuf==0
        return 0
    endif
    call stage_pencil_pixbuf((stage_pencil_pixbuf_set),workingpixbuf)

    #cursor in
    call stage_pencil_cursor((stage_pencil_cursor_set))
    #

    import "stage_frame_dialog" stage_frame_dialog
    ss title="Pencil window"
    data init^stage_pencil_init
    data on_ok^stage_pencil_set
    call stage_frame_dialog(init,on_ok,title)

    #cursor out
    call stage_pencil_cursor((stage_pencil_cursor_free))
    #

    #unref the pixbuf, if required
    setcall workingpixbuf stage_pencil_pixbuf((stage_pencil_pixbuf_get))
    if workingpixbuf!=0
        call g_object_unref(workingpixbuf)
    endif
endfunction

importx "_gtk_widget_set_size_request" gtk_widget_set_size_request

const visible_area_width=640
const visible_area_height=480

function stage_pencil_init(sd vbox,sd *dialog)
    import "hboxfield_cnt" hboxfield_cnt
    sd hbox
    setcall hbox hboxfield_cnt(vbox)
    #
    importx "_gtk_hbox_new" gtk_hbox_new
    import "labelfield_l" labelfield_l
    import "packstart_default" packstart_default
    ss color="Pencil Color: "
    sd colorwidget
    sd color_hbox
    setcall color_hbox gtk_hbox_new(0,0)
    call labelfield_l(color,color_hbox)
    importx "_gtk_color_button_new" gtk_color_button_new
    setcall colorwidget gtk_color_button_new()
    call packstart_default(color_hbox,colorwidget)
    call stage_pencil_color((value_set),colorwidget)
    call packstart_default(hbox,color_hbox)
    #
    importx "_gtk_vseparator_new" gtk_vseparator_new
    sd sep
    setcall sep gtk_vseparator_new()
    call packstart_default(hbox,sep)
    #pencil size
    import "editfield_pack" editfield_pack
    sd penc_sz_hbox
    sd sz_en
    setcall sz_en stage_pencil_size_entry()
    str lb="Pencil size: "
    setcall penc_sz_hbox gtk_hbox_new(0,0)
    call labelfield_l(lb,penc_sz_hbox)
    setcall sz_en# editfield_pack(penc_sz_hbox)
    call packstart_default(hbox,penc_sz_hbox)
    #
    setcall sep gtk_vseparator_new()
    call packstart_default(hbox,sep)
    #
    import "labelfield_left_default" labelfield_left_default
    ss zm="Zoom"
    call labelfield_left_default(zm,hbox)
    import "hscalefield" hscalefield
    sd zoom_wd
    setcall zoom_wd hscalefield(hbox,1,16,1,1)
    call stage_pencil_zoomvalue((value_set),zoom_wd)

    import "scrollfield" scrollfield
    sd scroll
    setcall scroll scrollfield(vbox)
    call gtk_widget_set_size_request(scroll,(visible_area_width),(visible_area_height))

    import "eventboxfield_cnt" eventboxfield_cnt
    sd ebox
    setcall ebox eventboxfield_cnt(scroll)
    import "drawfield_cnt" drawfield_cnt
    sd drawing
    setcall drawing drawfield_cnt(ebox)
    call stage_pencil_draw((value_set),drawing)
    #set the draw width knowing the zoom
    call stage_pencil_drawsize()

    import "connect_signal" connect_signal

    #at main realize
    str rel="realize"
    data rel_fn^stage_pencil_realize
    call connect_signal(drawing,rel,rel_fn)

    #at expose draw the pixbuf
    str expose="expose-event"
    data exp^stage_pencil_expose
    call connect_signal(drawing,expose,exp)

    #zoom level changed
    str ch="value-changed"
    data changed^stage_pencil_drawsize
    call connect_signal(zoom_wd,ch,changed)

    #on click is the pencil color point
    str press="button-press-event"
    data clickfunction^stage_pencil_setpixel
    call connect_signal(ebox,press,clickfunction)

    #on mouse moving
    str motion="motion-notify-event"
    data motionfunction^stage_pencil_motion
    call connect_signal(ebox,motion,motionfunction)

    importx "_gtk_widget_add_events" gtk_widget_add_events
    call gtk_widget_add_events(ebox,(GDK_BUTTON_PRESS_MASK|GDK_POINTER_MOTION_MASK))
endfunction

function stage_pencil_set()
    sd workingpixbuf
    setcall workingpixbuf stage_pencil_pixbuf((stage_pencil_pixbuf_get))
    import "stage_sel_replace_pixbuf" stage_sel_replace_pixbuf
    call stage_sel_replace_pixbuf(workingpixbuf)

    #set 0 for not unreference it at the exit
    call stage_pencil_pixbuf((stage_pencil_pixbuf_set),0)
endfunction



##signals

function stage_pencil_realize(sd drawing,sd *data)
    #pencil cursor over drawing area
    importx "_gdk_window_set_cursor" gdk_window_set_cursor
    sd window
    setcall window gtk_widget_get_window(drawing)
    sd cursor
    setcall cursor stage_pencil_cursor((stage_pencil_cursor_get))
    call gdk_window_set_cursor(window,cursor)
endfunction

importx "_gdk_pixbuf_get_width" gdk_pixbuf_get_width
importx "_gdk_pixbuf_get_height" gdk_pixbuf_get_height

#bool false, continue events
function stage_pencil_setpixel(sd *ebox,sd event,sd *data)
    #get draw widget
    sd drawfield
    setcall drawfield stage_pencil_draw((value_get))
    #get coords
    import "eventbutton_get_coords" eventbutton_get_coords
    sd mouse_x
    sd mouse_y
    sd p_mouse_y^mouse_y
    setcall mouse_x eventbutton_get_coords(event,p_mouse_y)
    #get the color
    sd color_widget
    setcall color_widget stage_pencil_color((value_get))
    #convert to rgb
    import "color_widget_get_color_to_rgb" color_widget_get_color_to_rgb
    sd color
    setcall color color_widget_get_color_to_rgb(color_widget)
    #from little to big
    import "dword_reverse" dword_reverse
    setcall color dword_reverse(color)
    #get pixbuf and zoom
    sd pixbuf
    setcall pixbuf stage_pencil_pixbuf((stage_pencil_pixbuf_get))
    sd zoom_count
    setcall zoom_count stage_pencil_zoomvalue((value_get))

    #adjust to zoom
    div mouse_x zoom_count
    div mouse_y zoom_count
    #get the pencil size
    sd sz_en
    setcall sz_en stage_pencil_size_entry()
    import "memtoint" memtoint
    importx "_gtk_entry_get_text" gtk_entry_get_text
    import "slen" slen
    sd pixel_value
    ss txt
    setcall txt gtk_entry_get_text(sz_en#)
    sd sz
    setcall sz slen(txt)
    sd bool
    setcall bool memtoint(txt,sz,#pixel_value)
    if bool==(FALSE)
        set pixel_value 1
    elseif pixel_value<1
        set pixel_value 1
    endelseif
    #test for be on the pixbuf
    sd px_width
    sd px_height
    setcall px_width gdk_pixbuf_get_width(pixbuf)
    setcall px_height gdk_pixbuf_get_height(pixbuf)
    if mouse_x<0
        return 0
    elseif mouse_y<0
        return 0
    elseif mouse_x>=px_width
        return 0
    elseif mouse_y>=px_height
        return 0
    endelseif
    sd mouse_x_max
    set mouse_x_max mouse_x
    add mouse_x_max pixel_value
    if mouse_x_max>px_width
        set mouse_x_max px_width
    endif
    sd mouse_y_max
    set mouse_y_max mouse_y
    add mouse_y_max pixel_value
    if mouse_y_max>px_height
        set mouse_y_max px_height
    endif
    #set the pixel
    sd x_cursor
    sd y_cursor
    set y_cursor mouse_y
    while y_cursor<mouse_y_max
        set x_cursor mouse_x
        while x_cursor<mouse_x_max
            import "pixbuf_set_pixel" pixbuf_set_pixel
            call pixbuf_set_pixel(pixbuf,color,x_cursor,y_cursor)
            inc x_cursor
        endwhile
        inc y_cursor
    endwhile
    #redraw the new area
    #get width and height size
    sd width_size
    set width_size mouse_x_max
    sub width_size mouse_x
    sd height_size
    set height_size mouse_y_max
    sub height_size mouse_y
    #get rect
    mult mouse_x zoom_count
    mult mouse_y zoom_count
    sd left
    sd top
    sd width
    sd height
    sd rect^left
    #set rect
    set left mouse_x
    set top mouse_y
    set width zoom_count
    set height zoom_count
    mult width width_size
    mult height height_size
    #redraw
    importx "_gdk_window_invalidate_rect" gdk_window_invalidate_rect
    sd window
    setcall window gtk_widget_get_window(drawfield)
    call gdk_window_invalidate_rect(window,rect,0)
    #return
    return (FALSE)
endfunction

#bool false to continue
function stage_pencil_motion(sd *widget,sd EventMotion,sd *data)
    sd state
    sd p_state^state
    importx "_gdk_event_get_state" gdk_event_get_state
    call gdk_event_get_state(EventMotion,p_state)
    and state (GDK_BUTTON1_MASK)
    if state!=0
        call stage_pencil_setpixel(0,EventMotion)
    endif
    return (FALSE)
endfunction

const expose_return=FALSE
#bool false to propagate
function stage_pencil_expose(sd drawwidget,sd ev_expose,sd *data)
    #ev_expose
    sd draw_left
    sd draw_top

    sd left
    sd top
    sd right
    sd bottom
    #GdkEventType type;
    #GdkWindow *window;
    #gint8 send_event;
    #GdkRectangle area;
    #GdkRegion *region;
    #gint count;

    #get rect: left top width height; and zoom multiplier
    import "structure_get_int" structure_get_int
    setcall draw_left structure_get_int(ev_expose,(ev_expose_left))
    set left draw_left
    setcall draw_top structure_get_int(ev_expose,(4*DWORD))
    set top draw_top
    sd width
    sd height
    setcall width structure_get_int(ev_expose,(ev_expose_width))
    setcall height structure_get_int(ev_expose,(6*DWORD))
    sd zoom_count
    setcall zoom_count stage_pencil_zoomvalue((value_get))
    #to normal size
    div left zoom_count
    div top zoom_count
    div width zoom_count
    div height zoom_count
    #more at rect for unpainted spaces(left top take floor, +1; width height can also take floor, +1)
    add width 2
    add height 2
    #pixbuf width and height
    sd px_width
    sd px_height
    sd pixbuf
    setcall pixbuf stage_pencil_pixbuf((stage_pencil_pixbuf_get))
    setcall px_width gdk_pixbuf_get_width(pixbuf)
    setcall px_height gdk_pixbuf_get_height(pixbuf)
    #corrections
    if left<0
        set left 0
    endif
    if top<0
        set top 0
    endif
    #rigth and bottom
    set right left
    add right width
    set bottom top
    add bottom height
    #get real right,bottom, correct width,height
    if right>px_width
        set right px_width
        set width px_width
        sub width left
    endif
    if bottom>px_height
        set bottom px_height
        set height px_height
        sub height top
    endif
    #input event sometimes has negative width,height
    if width<0
        return (expose_return)
    endif
    if height<0
        return (expose_return)
    endif
    #get pixbuf to draw
    import "pixbuf_new_subpixels" pixbuf_new_subpixels
    sd sub_pixbuf
    setcall sub_pixbuf pixbuf_new_subpixels(pixbuf,left,top,right,bottom)
    if sub_pixbuf!=0
        import "pixbuf_scale" pixbuf_scale
        sd zoomed_pixbuf
        mult left zoom_count
        mult top zoom_count
        mult width zoom_count
        mult height zoom_count
        setcall zoomed_pixbuf pixbuf_scale(sub_pixbuf,width,height)
        if zoomed_pixbuf!=0
            sd drawable
            setcall drawable gtk_widget_get_window(drawwidget)
            importx "_gdk_draw_pixbuf" gdk_draw_pixbuf
            call gdk_draw_pixbuf(drawable,0,zoomed_pixbuf,0,0,left,top,width,height,(GDK_RGB_DITHER_NONE),0,0)
            call g_object_unref(zoomed_pixbuf)
        endif
        call g_object_unref(sub_pixbuf)
    endif
    return (expose_return)
endfunction


##other fns

function stage_pencil_drawsize()
    sd zoom_count
    setcall zoom_count stage_pencil_zoomvalue((value_get))

    sd width
    sd height
    sd pixbuf
    setcall pixbuf stage_pencil_pixbuf((stage_pencil_pixbuf_get))
    setcall width gdk_pixbuf_get_width(pixbuf)
    setcall height gdk_pixbuf_get_height(pixbuf)

    mult width zoom_count
    mult height zoom_count

    sd drawwidg
    setcall drawwidg stage_pencil_draw((value_get))

    call gtk_widget_set_size_request(drawwidg,width,height)
endfunction
