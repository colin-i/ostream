


format elfobj

include "../../_include/include.h"

const top_left=0
const top_right=1
const bottom_left=2
const bottom_right=3

function stage_reveal_diagonal()
    import "stage_frame_dialog" stage_frame_dialog

    ss title="Uncover/Cover diagonal effect"
    data init^stage_reveal_diagonal_init
    data do^stage_reveal_diagonal_set
    call stage_frame_dialog(init,do,title)
endfunction

function stage_reveal_diagonal_init(sd vbox,sd *dialog)
    import "stage_effect_common_cover_fields" stage_effect_common_cover_fields
    call stage_effect_common_cover_fields(vbox)

    call stage_effect_corner(0,vbox)
endfunction

function stage_reveal_diagonal_set()
    call stage_reveal_diagonal_tool(0)
    data f^stage_reveal_diagonal_tool
    import "stage_effect_new" stage_effect_new
    call stage_effect_new(f,1)
endfunction

function stage_reveal_diagonal_tool(sd part,sd k,sd nr,sd pixels,sd w,sd h,sd rowstride,sd animpixels,sd *animpixbuf,sd in_out)
    data init#1
    if part==0
        set init 0
        return 1
    endif

    data start_x#1
    data end_x#1
    data start_y#1
    data end_y#1
    data width_factor#1
    data height_factor#1
    data effect_side_x#1
    data effect_side_y#1
    const left_is_effect=0
    #const right_is_effect=1
    const top_is_effect=0
    const bottom_is_effect=1
    data diagonal#1
    const first_diagonal=0
    const second_diagonal=1

    if init==0
        set init 1

        sd corners
        setcall corners stage_effect_corner(1)
        set start_x w
        set end_x w
        set start_y h
        set end_y h
        set width_factor 0
        set height_factor 0
        set effect_side_x 0
        set effect_side_y 0
        if corners==(top_left)
            set start_x 0
            set start_y 0

            set diagonal (second_diagonal)
        elseif corners==(top_right)
            set end_x 0
            set start_y 0

            set height_factor 1

            set effect_side_x 1

            set diagonal (first_diagonal)
        elseif corners==(bottom_left)
            set start_x 0
            set end_y 0

            set width_factor 1

            set effect_side_y 1

            set diagonal (first_diagonal)
        else
            set end_x 0
            set end_y 0

            set width_factor 1
            set height_factor 1

            set effect_side_x 1
            set effect_side_y 1

            set diagonal (second_diagonal)
        endelse
        if in_out==(cover)
            xor effect_side_x 1
            xor effect_side_y 1
        endif
    endif

    sd last_frame
    set last_frame nr
    dec last_frame

    sd part_frame
    set part_frame nr
    div part_frame 2

    if k==part_frame
        xor width_factor 1
        xor height_factor 1
    endif
    sd index
    set index part_frame
    if k>=part_frame
        set index last_frame

        sub k part_frame
        sub index part_frame
    endif

    sd pointwidth_x
    sd pointwidth_y
    sd pointheight_x
    sd pointheight_y

    import "rule3_offset" rule3_offset

    setcall pointwidth_x rule3_offset(k,index,start_x,end_x)
    set pointwidth_y h
    mult pointwidth_y width_factor

    set pointheight_x w
    mult pointheight_x height_factor
    setcall pointheight_y rule3_offset(k,index,start_y,end_y)

    sd diag_left
    sd diag_top
    sd diag_right
    sd diag_bottom

    import "get_lower" get_lower
    import "get_higher" get_higher
    setcall diag_left get_lower(pointwidth_x,pointheight_x)
    setcall diag_top get_lower(pointwidth_y,pointheight_y)
    setcall diag_right get_higher(pointwidth_x,pointheight_x)
    setcall diag_bottom get_higher(pointwidth_y,pointheight_y)

    import "rgb_copy" rgb_copy
    if effect_side_y==(top_is_effect)
        call rgb_copy(animpixels,pixels,0,0,w,diag_top,rowstride)
    endif

    sd j
    set j diag_top
    while j!=diag_bottom
        import "rule3_two_offsets" rule3_two_offsets
        sd x
        if diagonal==(first_diagonal)
            setcall x rule3_two_offsets(diag_top,j,diag_bottom,diag_left,diag_right)
        else
            setcall x rule3_two_offsets(diag_top,j,diag_bottom,diag_right,diag_left)
        endelse
        sd i
        sd end_i
        if effect_side_x==(left_is_effect)
            set i 0
            set end_i x
        else
            set i x
            set end_i w
        endelse
        while i!=end_i
            import "rgb_px_get" rgb_px_get
            import "rgb_px_set" rgb_px_set
            sd value
            setcall value rgb_px_get(animpixels,i,j,8,3,rowstride)
            call rgb_px_set(value,pixels,i,j,8,3,rowstride)

            inc i
        endwhile
        inc j
    endwhile

    if effect_side_y==(bottom_is_effect)
        call rgb_copy(animpixels,pixels,0,diag_bottom,w,h,rowstride)
    endif
endfunction




function stage_effect_corner(sd part,sd vbox)
    if part==0
        #frame
        import "framefield" framefield
        str corner="Corner start"
        sd frame
        setcall frame framefield(vbox,corner)

        sd framechild
        import "tablefield" tablefield
        setcall framechild tablefield(frame,2,2)

        data c_top_left#1
        data c_top_right#1
        data c_bottom_left#1
        data *c_bottom_right#1
        ss c_top_left_text="Top-Left"
        ss *o_top_right_text="Top-Right"
        ss *o_bottom_left_text="Bottom-Left"
        ss *o_bottom_right_text="Bottom-Right"

        import "table_attach" table_attach
        sd p_corner^c_top_left
        sd p_text_corner^c_top_left_text
        sd c_y=0
        sd radio=0
        while c_y!=2
            sd c_x
            set c_x 0
            while c_x!=2
                importx "_gtk_radio_button_get_group" gtk_radio_button_get_group
                if radio!=0
                    setcall radio gtk_radio_button_get_group(radio)
                endif
                importx "_gtk_radio_button_new_with_label" gtk_radio_button_new_with_label
                setcall radio gtk_radio_button_new_with_label(radio,p_text_corner#)

                call table_attach(framechild,radio,c_x,c_y)

                set p_corner# radio
                add p_corner 4
                add p_text_corner 4
                inc c_x
            endwhile
            inc c_y
        endwhile
        importx "_gtk_toggle_button_set_active" gtk_toggle_button_set_active
        call gtk_toggle_button_set_active(c_top_left,1)
        return 0
    else
        importx "_gtk_toggle_button_get_active" gtk_toggle_button_get_active

        sd bool

        #top-left
        setcall bool gtk_toggle_button_get_active(c_top_left)
        if bool==1
            return (top_left)
        endif
        #top-right
        setcall bool gtk_toggle_button_get_active(c_top_right)
        if bool==1
            return (top_right)
        endif
        #bottom-left
        setcall bool gtk_toggle_button_get_active(c_bottom_left)
        if bool==1
            return (bottom_left)
        endif
        #bottom
        return (bottom_right)
    endelse
endfunction
