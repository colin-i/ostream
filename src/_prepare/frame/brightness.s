


format elfobj

include "../../_include/include.h"

function stage_brightness()
    import "stage_frame_dialog" stage_frame_dialog
    sd init^stage_brightness_init
    sd set^stage_brightness_set
    ss title="Image brightness"
    call stage_frame_dialog(init,set,title)
endfunction

const brightness_half=50
const brightness_max=brightness_half*2

function stage_brightness_init(sd vbox,sd *dialog)
    import "hboxfield_cnt" hboxfield_cnt
    sd hbox
    setcall hbox hboxfield_cnt(vbox)

    import "labelfield_left_default" labelfield_left_default
    str dark="Darken"
    call labelfield_left_default(dark,hbox)

    import "hscalefield" hscalefield
    sd hscale
    setcall hscale hscalefield(hbox,0,(brightness_max),1,(brightness_half))
    importx "_gtk_widget_set_size_request" gtk_widget_set_size_request
    call gtk_widget_set_size_request(hscale,400,-1)
    call hscale_entry((value_set),hscale)

    str bright="Brighten"
    call labelfield_left_default(bright,hbox)
endfunction

function hscale_entry(sd action,sd value)
    data hscale#1
    if action==(value_set)
        set hscale value
    else
        return hscale
    endelse
endfunction

function stage_brightness_set()
    sd hscale
    setcall hscale hscale_entry((value_get))
    import "hscale_get" hscale_get
    sd value
    setcall value hscale_get(hscale)

    const blacken=0
    const whiten=0xFF
    sd procedure
    sd walked
    if value<=(brightness_half)
        set procedure (blacken)
        set walked (brightness_half)
        sub walked value
    else
        set procedure (whiten)
        set walked value
        sub walked (brightness_half)
    endelse

    import "stage_get_sel_pixbuf" stage_get_sel_pixbuf
    sd pixbuf
    sd ptr_pixbuf^pixbuf
    call stage_get_sel_pixbuf(ptr_pixbuf)

    import "pixbuf_get_wh" pixbuf_get_wh
    sd w
    sd h
    sd wh^w
    call pixbuf_get_wh(pixbuf,wh)
    sd j=0
    sd red
    sd green
    sd blue
    sd colors^red
    while j!=h
        sd i=0
        while i!=w
            import "pixbuf_get_pixel" pixbuf_get_pixel
            import "pixbuf_set_pixel" pixbuf_set_pixel
            import "rgb_uint_to_colors" rgb_uint_to_colors

            sd pixel
            setcall pixel pixbuf_get_pixel(pixbuf,i,j)
            call rgb_uint_to_colors(pixel,colors)

            import "rule3_offset" rule3_offset

            sd end_red
            sd end_green
            sd end_blue
            sd end_colors^end_red
            import "cpymem" cpymem
            call cpymem(end_colors,colors,(3*4))

            sd average_color
            set average_color red
            add average_color green
            add average_color blue
            if average_color!=0
                div average_color 3
            endif

            if procedure==(blacken)
                #sub colors to same level
                sub end_red average_color
                sub end_green average_color
                sub end_blue average_color
            else
                #add colors to same level
                add end_red average_color
                add end_green average_color
                add end_blue average_color
            endelse

            #advance according to horizontal scale
            setcall red rule3_offset(walked,(brightness_half),red,end_red)
            setcall green rule3_offset(walked,(brightness_half),green,end_green)
            setcall blue rule3_offset(walked,(brightness_half),blue,end_blue)

            #correct overflow
            if procedure==(blacken)
                if red<0
                    set red 0
                endif
                if green<0
                    set green 0
                endif
                if blue<0
                    set blue 0
                endif
            else
                if red>0xff
                    set red 0xff
                endif
                if green>0xff
                    set green 0xff
                endif
                if blue>0xff
                    set blue 0xff
                endif
            endelse

            import "rgb_colors_to_uint" rgb_colors_to_uint
            setcall pixel rgb_colors_to_uint(colors)

            call pixbuf_set_pixel(pixbuf,pixel,i,j)
            inc i
        endwhile
        inc j
    endwhile
    import "stage_redraw" stage_redraw
    call stage_redraw()
endfunction
