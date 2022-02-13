

format elfobj

include "../_include/include.h"

#unselected frame
#image
function stage_unselected_frame(sd parent)
    ss normalframe
    import "unselectedframe" unselectedframe
    setcall normalframe unselectedframe()
    sd img
    setcall img stage_img_with_length(normalframe,parent)
    return img
endfunction

#selected frame
#creates selection image with pixbuf
#img returned
function stage_sel_img(sd parent)
    import "selectedframe" selectedframe
    ss file
    setcall file selectedframe()
    data img#1
    const ptr_img^img
    setcall img stage_img_with_length(file,parent)
    return img
endfunction
#put the selection at the eventbox position(newparent)
#img return
function stage_sel_img_set(sd newparent)
    sd img
    setcall img stage_sel_img(newparent)
    importx "_gtk_widget_show" gtk_widget_show
    call gtk_widget_show(img)
    return img
endfunction

importx "_gdk_pixbuf_get_width" gdk_pixbuf_get_width
importx "_gdk_pixbuf_get_height" gdk_pixbuf_get_height

#returns the new img with the length set and added to the parent
function stage_img_with_length(ss file,sd parent)
    sd img
    importx "_gtk_image_new" gtk_image_new
    setcall img gtk_image_new()

    import "pixbuf_from_file" pixbuf_from_file
    sd pixbuf
    setcall pixbuf pixbuf_from_file(file)
    if pixbuf==0
        return img
    endif

    import "stage_get_fr_length" stage_get_fr_length
    sd length
    setcall length stage_get_fr_length(parent)

    sd w
    setcall w gdk_pixbuf_get_width(pixbuf)
    mult w length
    sd h
    setcall h gdk_pixbuf_get_height(pixbuf)
    import "pixbuf_scale_forward_data" pixbuf_scale_forward_data
    data f^stage_img_with_length_fn
    call pixbuf_scale_forward_data(pixbuf,w,h,f,img)

    importx "_g_object_unref" g_object_unref
    call g_object_unref(pixbuf)

    import "container_child" container_child
    call container_child(parent,img)
    return img
endfunction
function stage_img_with_length_fn(sd pixb,sd img)
    #draw a border around the pixbuf
    sd w
    setcall w gdk_pixbuf_get_width(pixb)
    sd h
    setcall h gdk_pixbuf_get_height(pixb)
    importx "_gdk_pixbuf_get_pixels" gdk_pixbuf_get_pixels
    sd pixels
    setcall pixels gdk_pixbuf_get_pixels(pixb)
    importx "_gdk_pixbuf_get_rowstride" gdk_pixbuf_get_rowstride

    sd rowsub
    set rowsub w
    mult rowsub 3
    sd rowdif
    setcall rowdif gdk_pixbuf_get_rowstride(pixb)
    sub rowdif rowsub

    sd prelast_h
    set prelast_h h
    dec prelast_h

    sd prelast_w
    set prelast_w w
    dec prelast_w

    sd j=0
    while j!=h
        sd i=0
        while i!=w
            sd border=0
            if j==0
                set border 1
            elseif j==prelast_h
                set border 1
            elseif i==0
                set border 1
            elseif i==prelast_w
                set border 1
            endelseif
            if border==1
                ss px
                set px pixels
                set px# 0
                inc px
                set px# 0
                inc px
                set px# 0
            endif
            add pixels 3
            inc i
        endwhile
        add pixels rowdif
        inc j
    endwhile

    importx "_gtk_image_set_from_pixbuf" gtk_image_set_from_pixbuf
    call gtk_image_set_from_pixbuf(img,pixb)
endfunction

#initialize/set the img to zero
function stage_sel_prepare_img_space()
    sd pi%ptr_img
    data z=0
    set pi# z
endfunction

#listen for the first frame to select it
#img or null
function stage_sel_img_listen(sd newparent)
    sd pi%ptr_img
    sd img=0
    data z=0
    if pi#==z
        setcall img stage_sel_img_set(newparent)
    endif
    return img
endfunction

importx "_gtk_widget_get_parent" gtk_widget_get_parent

#deletes the old selection frame and creates the new
function stage_sel_reparent(sd newparent)
    sd pi%ptr_img
    data z=0
    sd img
    set img pi#
    if img!=z
        sd parent
        setcall parent gtk_widget_get_parent(img)
        call stage_unselected_frame(parent)
        importx "_gtk_widget_show_all" gtk_widget_show_all
        call gtk_widget_show_all(parent)
    endif
    call stage_sel_img_set(newparent)
endfunction

#e
function stage_save_nothing()
    str noframe="There is no frame on the stage."
    import "texter" texter
    call texter(noframe)
    return noframe
endfunction

#0/pixbuf
#get the sel frame bar pixbuf
function stage_sel_framebar_pixbuf()
    sd img
    setcall img stage_get_sel()
    if img==0
        return 0
    endif
    importx "_gtk_image_get_pixbuf" gtk_image_get_pixbuf
    sd pixbuf
    setcall pixbuf gtk_image_get_pixbuf(img)
    return pixbuf
endfunction

function stage_sel_pointer()
    sd pi%ptr_img
    return pi
endfunction

function stage_sel()
    sd pi
    setcall pi stage_sel_pointer()
    return pi#
endfunction

#NULL/img
function stage_get_sel()
    sd pi%ptr_img
    sd img
    set img pi#
    if img==0
        call stage_save_nothing()
        return 0
    endif
    return img
endfunction

#e
function stage_get_sel_parent(sd ptr_eventbox)
    sd img
    setcall img stage_get_sel()
    if img==0
        return (error)
    endif
    setcall ptr_eventbox# gtk_widget_get_parent(img)
    return (noerror)
endfunction

#e
function stage_get_sel_pixbuf(sd ptr)
    sd eventbox
    sd ptr_eventbox^eventbox
    sd err
    setcall err stage_get_sel_parent(ptr_eventbox)
    if err!=(noerror)
        return err
    endif
    sd pixbuf
    import "object_get_dword_name" object_get_dword_name
    setcall pixbuf object_get_dword_name(eventbox)
    set ptr# pixbuf
    data noerr=noerror
    return noerr
endfunction
#e
function stage_get_sel_pixbuf_nowarning(sd ptr)
    sd pi%ptr_img
    if pi#==0
        return (error)
    endif
    call stage_get_sel_pixbuf(ptr)
endfunction
#0/pixbuf
function stage_get_selection_pixbuf()
    sd px
    sd p_px^px
    sd err
    setcall err stage_get_sel_pixbuf(p_px)
    if err!=(noerror)
        return 0
    endif
    return px
endfunction

#save the selection to a file
function stage_save_img()
    sd pixbuf
    sd ptr_pixbuf^pixbuf
    sd err
    data noerr=noerror
    setcall err stage_get_sel_pixbuf(ptr_pixbuf)
    if err!=noerr
        return err
    endif

    ss location
    str format="jpeg"
    import "save_destination" save_destination
    setcall location save_destination(format)

    sd file
    sd p_file^file
    import "openfile" openfile
    importx "_fclose" fclose
    sd er
    ss mode="wb"
    setcall er openfile(p_file,location,mode)
    if er!=(noerror)
        return 0
    endif
    import "stage_jpeg_write" stage_jpeg_write
    call stage_jpeg_write(file,pixbuf)
    call fclose(file)

    import "save_inform_saved" save_inform_saved
    call save_inform_saved(location)
endfunction


#verify a frame exists and mass remove is close
#bool
function frame_jobs()
    sd img
    setcall img stage_get_sel()
    if img==0
        return 0
    endif
    sd bool
    setcall bool mass_remove_job()
    return bool
endfunction

#bool
function mass_remove_job()
    import "link_mass_remove" link_mass_remove
    sd massremove
    setcall massremove link_mass_remove((value_get))
    if massremove!=0
        str er="Close the interval remove dialog first"
        call texter(er)
        return 0
    endif
    return 1
endfunction

#a dialog checking if there is at least one frame and mass remove is off
function stage_frame_dialog(sd init,sd on_ok,sd title)
    sd bool
    setcall bool frame_jobs()
    if bool!=(TRUE)
        return (void)
    endif
    import "dialogfield" dialogfield
    call dialogfield(title,(GTK_DIALOG_MODAL),init,on_ok)
endfunction
#dialog, checking if mass remove is off
function stage_frame_dialog_solo(sd init,sd on_ok,sd title)
    sd bool
    setcall bool mass_remove_job()
    if bool!=(TRUE)
        return (void)
    endif
    call dialogfield(title,(GTK_DIALOG_MODAL),init,on_ok)
endfunction

import "stage_frame_index" stage_frame_index

#the sel pos
function stage_get_sel_pos()
    sd selparent
    sd p_selparent^selparent
    call stage_get_sel_parent(p_selparent)
    sd pos
    setcall pos stage_frame_index(selparent)
    return pos
endfunction
#e
function stage_get_sel_position(sd p_pos)
    #no texter
    sd pi%ptr_img
    sd img
    set img pi#
    if img==0
        return (error)
    endif
    sd selparent
    setcall selparent gtk_widget_get_parent(img)
    setcall p_pos# stage_frame_index(selparent)
    return (noerror)
endfunction

function stage_sel_replace_pixbuf(sd newpixbuf)
    sd ebox
    sd p_ebox^ebox
    call stage_get_sel_parent(p_ebox)

    import "unref_pixbuf_frame" unref_pixbuf_frame
    call unref_pixbuf_frame(ebox)

    import "object_set_dword_name" object_set_dword_name
    call object_set_dword_name(ebox,newpixbuf)
    import "stage_redraw" stage_redraw
    call stage_redraw()
endfunction


