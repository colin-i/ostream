


format elfobj

include "../../_include/include.h"

const stage_move_cover_set=0
const stage_move_cover_get=1

const stage_move_select=0
const stage_cover_select=1

const stage_move_cover_move_or_cover=0
const stage_move_cover_in_text=1
const stage_move_cover_out_text=2
const stage_move_cover_direction_text=3

import "stage_frame_dialog" stage_frame_dialog
function stage_move()
    call stage_move_cover_effect((stage_move_cover_set),(stage_move_select))
    ss title="Move In/Move Out effect"
    call stage_move_cover_start(title)
endfunction
function stage_cover()
    call stage_move_cover_effect((stage_move_cover_set),(stage_cover_select))
    ss title="Uncover/Cover effect"
    call stage_move_cover_start(title)
endfunction

function stage_move_cover_start(ss title)
    data init^stage_move_init
    data do^stage_move_set
    call stage_frame_dialog(init,do,title)
endfunction

function stage_move_cover_effect(sd action,sd value)

    data effect#1
    str in_text#1
    str out_text#1
    str direction_text#1

    data p_values^effect

    if action==(stage_move_cover_set)
        set effect value
        if effect==(stage_move_select)
            ss move_in_text="Move In"
            ss move_out_text="Move Out"
            ss move_direction_text="Move in From/Move out To:"

            set in_text move_in_text
            set out_text move_out_text
            set direction_text move_direction_text
        else
            ss cover_in_text="Uncover"
            ss cover_out_text="Cover"
            ss cover_direction_text="Uncover From/Cover To:"

            set in_text cover_in_text
            set out_text cover_out_text
            set direction_text cover_direction_text
        endelse
    else
    #value
        mult value 4
        add value p_values
        return value#
    endelse
endfunction

function stage_move_init(sd vbox,sd *dialog)
    #common fields
    #the in or out
    import "stage_effect_common_fields" stage_effect_common_fields

    ss in_text
    ss out_text
    setcall in_text stage_move_cover_effect((stage_move_cover_get),(stage_move_cover_in_text))
    setcall out_text stage_move_cover_effect((stage_move_cover_get),(stage_move_cover_out_text))

    call stage_effect_common_fields(vbox,in_text,out_text)

    #the direction
    ss text
    setcall text stage_move_cover_effect((stage_move_cover_get),(stage_move_cover_direction_text))

    import "stage_effect_orientation" stage_effect_orientation
    call stage_effect_orientation(0,vbox,(FALSE),text)
endfunction

function stage_move_set()
    call stage_move_tool(0)
    data f^stage_move_tool
    import "stage_effect_new" stage_effect_new
    call stage_effect_new(f,1)
endfunction

function stage_move_tool(sd part,sd k,sd nr,sd pixels,sd w,sd h,sd rowstride,sd animpixels,sd *animpixbuf,sd in_out)
    data inits#1
    if part==0
        set inits 1
        return 1
    endif
    if inits==1
        set inits 0

        data start_x#1
        data start_y#1

        data end_x#1
        data end_y#1

        sd x_coef
        sd y_coef
        sd p_y_coef^y_coef
        setcall x_coef stage_effect_orientation(1,p_y_coef,(FALSE))

        set start_x w
        set start_y h
        set end_x 0
        set end_y 0

        mult start_x x_coef
        mult start_y y_coef

        if in_out==(out_effect)
            sd aux
            set aux start_x
            set start_x end_x
            set end_x aux
            set aux start_y
            set start_y end_y
            set end_y aux
        endif

        data last_index#1
        set last_index nr
        dec last_index
    endif

    sd frame_left
    sd frame_top

    import "rule3_offset" rule3_offset
    #image coordinates at current frame
    setcall frame_left rule3_offset(k,last_index,start_x,end_x)
    setcall frame_top rule3_offset(k,last_index,start_y,end_y)

    sd frame_right
    sd frame_bottom
    set frame_right frame_left
    add frame_right w
    set frame_bottom frame_top
    add frame_bottom h

    sd j=0
    if frame_top>j
        set j frame_top
    endif
    sd max_j
    set max_j h
    if frame_bottom<max_j
        set max_j frame_bottom
    endif
    sd min_i=0
    if frame_left>min_i
        set min_i frame_left
    endif
    sd max_i
    set max_i w
    if frame_right<max_i
        set max_i frame_right
    endif

    while j!=max_j
        sd i
        set i min_i
        while i!=max_i
            sd x
            sd y
            set x i
            set y j
            sd move_or_cover
            setcall move_or_cover stage_move_cover_effect((stage_move_cover_get),(stage_move_cover_move_or_cover))
            if move_or_cover==(stage_move_select)
                sub x frame_left
                sub y frame_top
            endif

            import "rgb_px_get" rgb_px_get
            import "rgb_get_set" rgb_get_set
            sd value
            sd p_value^value
            setcall value rgb_px_get(animpixels,x,y,8,3,rowstride)
            call rgb_get_set(p_value,pixels,i,j,8,3,rowstride,(set_rgb))

            inc i
        endwhile
        inc j
    endwhile
endfunction


