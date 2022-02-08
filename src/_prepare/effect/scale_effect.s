

format elfobj

include "../../_include/include.h"

import "stage_frame_dialog" stage_frame_dialog

function stage_effect_scale()
    ss title="Scale In/Scale Out effect"
    data init^stage_effect_scale_init
    data do^stage_effect_scale_set
    call stage_frame_dialog(init,do,title)
endfunction

function stage_effect_scale_init(sd vbox,sd *dialog)
    import "stage_effect_common_fields" stage_effect_common_fields
    #Common fields and start from image/end with image
    ss in_text="Start from image"
    ss out_text="End with image"
    call stage_effect_common_fields(vbox,in_text,out_text)

    #Scale to smaller size/Scale to greater size
    import "stage_effect_in_out" stage_effect_in_out
    ss low_text="Scale to smaller size"
    ss high_text="Scale to greater size"
    data higher_scale#1
    const p_higher_scale^higher_scale
    setcall higher_scale stage_effect_in_out(vbox,low_text,high_text)

    call stage_effect_scale_orientation(0,vbox)
endfunction

function stage_effect_scale_set()
    call stage_effect_scale_tool(0)
    data f^stage_effect_scale_tool
    import "stage_effect_new" stage_effect_new
    call stage_effect_new(f,1)
endfunction

const start_from_image=0
#const end_with_image=1

importx "_gtk_toggle_button_get_active" gtk_toggle_button_get_active

function stage_effect_scale_tool(sd part,sd k,sd nr,sd pixels,sd w,sd h,sd rowstride,sd *animpixels,sd animpixbuf,sd in_out)
    data orientation_left_mult#1
    data orientation_top_mult#1
    if part==0
        data init#1
        set init 0
        sd p_orientation_top_mult^orientation_top_mult
        setcall orientation_left_mult stage_effect_scale_orientation(1,p_orientation_top_mult)

        return 0
    endif
    if init==0
        data start_rect_width#1
        data start_rect_height#1

        data end_rect_width#1
        data end_rect_height#1

        if in_out==(start_from_image)
            set start_rect_width w
            set start_rect_height h
            set end_rect_width 0
            set end_rect_height 0
        else
            set end_rect_width w
            set end_rect_height h
            set start_rect_width 0
            set start_rect_height 0
        endelse

        data last_frame#1
        set last_frame nr
        dec last_frame

        sd smaller_greater_entry%p_higher_scale
        data smaller_greater#1
        setcall smaller_greater gtk_toggle_button_get_active(smaller_greater_entry#)

        const smaller=0
        const greater=1

        data subpixels#1
        set subpixels 0
        if in_out==(start_from_image)
            if smaller_greater==(greater)
                set subpixels 1
            endif
        else
            if smaller_greater==(smaller)
                set subpixels 1
            endif
        endelse

        set init 1
    endif

    import "rule3_offset" rule3_offset
    sd frame_width
    sd frame_height
    setcall frame_width rule3_offset(k,last_frame,start_rect_width,end_rect_width)
    setcall frame_height rule3_offset(k,last_frame,start_rect_height,end_rect_height)

    if frame_width<4
        return 0
    elseif frame_height<4
        return 0
    endelseif

    sd left
    sd top
    set left w
    sub left frame_width
    div left 2
    set top h
    sub top frame_height
    div top 2

    sd orientation_left_offset
    set orientation_left_offset left
    mult orientation_left_offset orientation_left_mult
    setcall orientation_left_offset rule3_offset(k,last_frame,orientation_left_offset,0)
    add left orientation_left_offset

    sd orientation_top_offset
    set orientation_top_offset top
    mult orientation_top_offset orientation_top_mult
    setcall orientation_top_offset rule3_offset(k,last_frame,orientation_top_offset,0)
    add top orientation_top_offset

    sd newpixbuf

    import "pixbuf_scale" pixbuf_scale
    importx "_g_object_unref" g_object_unref

    if subpixels==0
        setcall newpixbuf pixbuf_scale(animpixbuf,frame_width,frame_height)
    else
        importx "_gdk_pixbuf_new_subpixbuf" gdk_pixbuf_new_subpixbuf
        sd croppixbuf
        setcall croppixbuf gdk_pixbuf_new_subpixbuf(animpixbuf,left,top,frame_width,frame_height)
        if croppixbuf==0
            return 0
        endif
        setcall newpixbuf pixbuf_scale(croppixbuf,w,h)
        call g_object_unref(croppixbuf)
        set left 0
        set top 0
        set frame_width w
        set frame_height h
    endelse
    if newpixbuf==0
        return 0
    endif

    import "rgb_px_get" rgb_px_get
    import "rgb_px_set" rgb_px_set
    importx "_gdk_pixbuf_get_pixels" gdk_pixbuf_get_pixels

    import "rgb_get_all_sizes" rgb_get_all_sizes
    sd rowstr
    sd p_rowstr^rowstr
    call rgb_get_all_sizes(frame_width,frame_height,p_rowstr)

    ss newbytes
    setcall newbytes gdk_pixbuf_get_pixels(newpixbuf)

    sd left_off
    set left_off left
    sd j=0
    while j!=frame_height
        sd i=0
        set left left_off
        while i!=frame_width
            sd value
            setcall value rgb_px_get(newbytes,i,j,8,3,rowstr)
            call rgb_px_set(value,pixels,left,top,8,3,rowstride)
            inc left
            inc i
        endwhile
        inc top
        inc j
    endwhile
    call g_object_unref(newpixbuf)
endfunction

function stage_effect_scale_orientation(sd part,sd argument)
    import "stage_effect_orientation" stage_effect_orientation
    sd value
    ss text="Orientation"
    setcall value stage_effect_orientation(part,argument,(TRUE),text)
    return value
endfunction
