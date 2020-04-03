

format elfobj


function stage_rotate_left()
    call stage_rotate(0,1,-1,1)
endfunction

function stage_rotate_right()
    call stage_rotate(1,0,1,-1)
endfunction

function stage_rotate(sd x_at_start,sd y_at_start,sd on_y,sd on_x)
    import "stage_get_selection_pixbuf" stage_get_selection_pixbuf
    sd px
    setcall px stage_get_selection_pixbuf()
    if px==0
        return 0
    endif
    sd w
    sd h
    sd p_w^w
    import "pixbuf_get_wh" pixbuf_get_wh
    call pixbuf_get_wh(px,p_w)
    import "new_pixbuf" new_pixbuf
    sd newpixbuf
    setcall newpixbuf new_pixbuf(h,w)
    if newpixbuf==0
        return 0
    endif

    #rotate 90, the width will be height and viceversa
    sd x
    set x h
    mult x x_at_start
    sub x x_at_start

    sd j=0
    while j!=h
        sd y
        set y w
        mult y y_at_start
        sub y y_at_start

        sd i=0
        while i!=w
            import "pixbuf_get_pixel" pixbuf_get_pixel
            import "pixbuf_set_pixel" pixbuf_set_pixel
            sd value
            setcall value pixbuf_get_pixel(px,i,j)
            call pixbuf_set_pixel(newpixbuf,value,x,y)
            add y on_y
            inc i
        endwhile
        add x on_x
        inc j
    endwhile

    import "stage_sel_replace_pixbuf" stage_sel_replace_pixbuf
    call stage_sel_replace_pixbuf(newpixbuf)
endfunction
