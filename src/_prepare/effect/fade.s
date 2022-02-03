

format elfobj

function stage_fade()
    ss title="Fade In/Fade Out effect"
    data init^stage_fade_init
    data do^stage_fade_set
    import "stage_frame_dialog" stage_frame_dialog
    call stage_frame_dialog(init,do,title)
endfunction

function stage_fade_init(sd vbox,sd *dialog)
    import "stage_effect_common_fields" stage_effect_common_fields
    #the in or out
    ss fadeintext="Fade In"
    ss fadeouttext="Fade Out"
    call stage_effect_common_fields(vbox,fadeintext,fadeouttext)
endfunction

function stage_fade_set()
    data f^stage_fade_tool
    import "stage_effect_new" stage_effect_new
    call stage_effect_new(f,1)
endfunction

function stage_fade_tool(sd *part,sd k,sd nr,sd pixels,sd w,sd h,sd rowstride,sd animpixels,sd *animpixbuf,sd in_out)
    #nr-1
    sd last_index
    set last_index nr
    dec last_index

    sd j=0
    while j!=h
        sd i=0
        while i!=w
            import "rgb_px_get" rgb_px_get
            import "rgb_uint_to_colors" rgb_uint_to_colors

            sd valuepixel
            setcall valuepixel rgb_px_get(pixels,i,j,8,3,rowstride)
            sd red_bg
            sd green_bg
            sd blue_bg
            sd colors_bg^red_bg
            call rgb_uint_to_colors(valuepixel,colors_bg)

            setcall valuepixel rgb_px_get(animpixels,i,j,8,3,rowstride)
            sd red
            sd green
            sd blue
            sd colors^red
            call rgb_uint_to_colors(valuepixel,colors)

            const fadein=0
            #const fadeout=1
            import "rule3_offset" rule3_offset
            if in_out==(fadein)
                setcall red rule3_offset(k,last_index,red_bg,red)
                setcall green rule3_offset(k,last_index,green_bg,green)
                setcall blue rule3_offset(k,last_index,blue_bg,blue)
            else
                setcall red rule3_offset(k,last_index,red,red_bg)
                setcall green rule3_offset(k,last_index,green,green_bg)
                setcall blue rule3_offset(k,last_index,blue,blue_bg)
            endelse

            import "rgb_colors_to_uint" rgb_colors_to_uint
            setcall valuepixel rgb_colors_to_uint(colors)

            import "rgb_px_set" rgb_px_set
            call rgb_px_set(valuepixel,pixels,i,j,8,3,rowstride)

            inc i
        endwhile
        inc j
    endwhile
endfunction
