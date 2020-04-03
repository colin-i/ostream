

format elfobj

include "../../_include/include.h"

const stage_reveal_shape_rectangle=0
const stage_reveal_shape_diamond=1
const stage_reveal_shape_curve=2

function stage_reveal_rectangle()
    call stage_reveal_shape_data(0,(stage_reveal_shape_rectangle))
    ss title="Uncover/Cover rectangle effect"
    call stage_reveal_shape(title)
endfunction

function stage_reveal_diamond()
    call stage_reveal_shape_data(0,(stage_reveal_shape_diamond))
    ss title="Uncover/Cover diamond effect"
    call stage_reveal_shape(title)
endfunction

function stage_reveal_curve()
    call stage_reveal_shape_data(0,(stage_reveal_shape_curve))
    ss title="Uncover/Cover curve effect"
    call stage_reveal_shape(title)
endfunction


function stage_reveal_shape_data(sd action,sd value)
    if action==0
        data shape#1
        set shape value
    else
        return shape
    endelse
endfunction

function stage_reveal_shape(ss title)
    import "stage_frame_dialog" stage_frame_dialog
    data init^stage_reveal_shape_init
    data do^stage_reveal_shape_set
    call stage_frame_dialog(init,do,title)
endfunction

function stage_reveal_shape_init(sd vbox,sd *dialog)
    import "stage_effect_common_cover_fields" stage_effect_common_cover_fields
    call stage_effect_common_cover_fields(vbox)
endfunction

function stage_reveal_shape_set()
    call stage_reveal_shape_tool(0)
    data f^stage_reveal_shape_tool
    import "stage_effect_new" stage_effect_new
    call stage_effect_new(f,1)
endfunction

function stage_reveal_shape_tool(sd part,sd k,sd nr,sd pixels,sd w,sd h,sd rowstride,sd animpixels,sd *animpixbuf,sd in_out)
    data init#1
    if part==0
        set init 0
        return 0
    endif
    if init==0
        data last_frame#1
        set last_frame nr
        dec last_frame

        data start_width#1
        data end_width#1
        data start_height#1
        data end_height#1

        if in_out==(uncover)
            set start_width 0
            set end_width w
            set start_height 0
            set end_height h
        else
            set start_width w
            set end_width 0
            set start_height h
            set end_height 0
        endelse

        set init 1
    endif

    import "rule3_offset" rule3_offset
    import "centered" centered

    sd frame_width
    sd frame_height

    setcall frame_width rule3_offset(k,last_frame,start_width,end_width)
    setcall frame_height rule3_offset(k,last_frame,start_height,end_height)

    sd left
    sd top
    sd right
    sd bottom

    setcall left centered(w,frame_width)
    setcall top centered(h,frame_height)

    set right left
    add right frame_width
    set bottom top
    add bottom frame_height


    sd shape
    setcall shape stage_reveal_shape_data(1)

    import "rgb_px_get" rgb_px_get
    import "rgb_px_set" rgb_px_set

    sd i
    sd j
    sd value
    if shape==(stage_reveal_shape_rectangle)
        set j top
        while j!=bottom
            set i left
            while i!=right
                setcall value rgb_px_get(animpixels,i,j,8,3,rowstride)
                call rgb_px_set(value,pixels,i,j,8,3,rowstride)
                inc i
            endwhile
            inc j
        endwhile
        return 1
    else
    #if shape==(stage_reveal_shape_diamond)||shape==(stage_reveal_shape_curve)
        sd half_width
        set half_width frame_width
        div half_width 2
        if half_width==0
            return 0
        endif
        sd half_height
        set half_height frame_height
        div half_height 2
        if half_height==0
            return 0
        endif

        sd diamond_part_left
        sd diamond_part_top
        sd diamond_part_right
        sd diamond_part_bottom

        set diamond_part_left left
        set diamond_part_top top
        set diamond_part_right right
        set diamond_part_bottom bottom

        sub diamond_part_left half_width
        sub diamond_part_top half_height
        sub diamond_part_right half_width
        sub diamond_part_bottom half_height

        sd diamond_bottom
        set diamond_bottom diamond_part_bottom
        add diamond_bottom frame_height

        set j diamond_part_top
        while j!=diamond_bottom
            sd bool
            setcall bool stage_reveal_diamond_row(j,h)
            if bool==1
                sd start_x
                sd end_x
                sd start_y
                sd end_y

                import "rule3_two_offsets" rule3_two_offsets

                if j<top
                    set start_x diamond_part_right
                    set end_x left
                    set start_y diamond_part_top
                    set end_y top
                elseif j<diamond_part_bottom
                    set start_x left
                    set end_x diamond_part_left
                    set start_y top
                    set end_y diamond_part_bottom
                elseif j<bottom
                    set start_x diamond_part_left
                    set end_x left
                    set start_y diamond_part_bottom
                    set end_y bottom
                else
                    set start_x left
                    set end_x diamond_part_right
                    set start_y bottom
                    set end_y diamond_bottom
                endelse
                setcall i rule3_two_offsets(start_y,j,end_y,start_x,end_x)

                if shape==(stage_reveal_shape_curve)
                #curve
                    if j<diamond_part_bottom
                        setcall i rule3_two_offsets(diamond_part_top,j,diamond_part_bottom,i,diamond_part_left)
                    else
                        setcall i rule3_two_offsets(diamond_part_bottom,j,diamond_bottom,diamond_part_left,i)
                    endelse
                endif

                if i<0
                    set i 0
                endif

                sd z
                set z w
                sub z i

                while i!=z
                    setcall value rgb_px_get(animpixels,i,j,8,3,rowstride)
                    call rgb_px_set(value,pixels,i,j,8,3,rowstride)
                    inc i
                endwhile
            endif
            inc j
        endwhile
    endelse
endfunction

function stage_reveal_diamond_row(sd j,sd height)
    if j<0
        return 0
    elseif j>=height
        return 0
    endelseif
    return 1
endfunction
