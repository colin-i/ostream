

format elfobj

include "../../_include/include.h"

import "stage_get_sel" stage_get_sel
import "stage_get_sel_pos" stage_get_sel_pos

import "sound_pixbuf_redraw" sound_pixbuf_redraw

function stage_remove()
    #verify no frames
    sd img
    setcall img stage_get_sel()
    if img==0
        return 0
    endif

    #get current pos
    sd pos
    setcall pos stage_get_sel_pos()

    call stage_remove_frame(pos)

    call stage_remove_after(pos)

    #redraw the visual sound pulse
    call sound_pixbuf_redraw()
endfunction

import "stage_nthwidgetFromcontainer" stage_nthwidgetFromcontainer

function stage_remove_frame(sd pos)
    #remove sound(using current total frames)
    import "stage_sound_removeframe" stage_sound_removeframe
    call stage_sound_removeframe(pos)

    #index delete
    import "stage_frame_time_numbers" stage_frame_time_numbers
    call stage_frame_time_numbers((stage_frame_time_delete_frame),pos)

    #verify if selection is deleted for clearing the value
    import "stage_get_sel_position" stage_get_sel_position
    sd selpos
    sd p_selpos^selpos
    sd err
    setcall err stage_get_sel_position(p_selpos)
    if err==(noerror)
        if selpos==pos
            import "stage_sel_prepare_img_space" stage_sel_prepare_img_space
            call stage_sel_prepare_img_space()
        endif
    endif

    #get container
    sd ebox
    setcall ebox stage_nthwidgetFromcontainer(pos)
    #remove the pixbuf and destroy the frame(total frames changed)
    import "unref_pixbuf_frame" unref_pixbuf_frame
    call unref_pixbuf_frame(ebox)
    importx "_gtk_widget_destroy" gtk_widget_destroy
    call gtk_widget_destroy(ebox)
endfunction

function stage_remove_after(sd pos)
    #return if there are no frames
    import "stage_get_frames" stage_get_frames
    sd total_pos
    setcall total_pos stage_get_frames()
    if total_pos==0
        #clears the draw area
        import "stage_redraw" stage_redraw
        call stage_redraw()
        return 0
    endif

    #return if the sel was not deleted
    import "stage_sel" stage_sel
    sd sel
    setcall sel stage_sel()
    if sel!=0
        import "stage_get_sel_parent" stage_get_sel_parent
        sd ebox
        sd p_ebox^ebox
        call stage_get_sel_parent(p_ebox)
        import "stage_display_info" stage_display_info
        call stage_display_info(ebox)
        return 0
    endif

    #if last position was deleted, decrement position
    if pos==total_pos
        dec pos
    endif

    #arrange the frames bar
    sd frame
    setcall frame stage_nthwidgetFromcontainer(pos)
    import "stage_sel_reparent" stage_sel_reparent
    call stage_sel_reparent(frame)

    #display the frame
    import "stage_display_pixbuf" stage_display_pixbuf
    call stage_display_pixbuf(frame)
endfunction

#mass remove
function mass_remove_run(sd action,sd value)
    data start_entry#1
    if action==(value_set)
        set start_entry value
    else
    #if action==(value_run)
        sd end_entry
        setcall end_entry link_mass_remove((value_get))
        sd max_pos
        setcall max_pos stage_get_frames()
        dec max_pos

        import "entry_to_int_min_N_max_M" entry_to_int_min_N_max_M
        sd start
        sd end
        sd p_start^start
        sd p_end^end
        sd bool

        setcall bool entry_to_int_min_N_max_M(start_entry,p_start,0,max_pos)
        if bool!=1
            return 0
        endif
        setcall bool entry_to_int_min_N_max_M(end_entry,p_end,0,max_pos)
        if bool!=1
            return 0
        endif

        if start>end
            sd aux
            set aux end
            set end start
            set start aux
        endif

        while start<=end
            call stage_remove_frame(end)
            dec end
        endwhile
        call stage_remove_after(start)
    endelse
endfunction

function link_mass_remove(sd action,sd value)
    data link#1
    if action==(value_set)
        set link value
    elseif action==(value_write)
        if link!=0
            import "int_to_entry" int_to_entry
            sd pos
            setcall pos stage_get_sel_pos()
            call int_to_entry(pos,link)
        endif
    else
    #if action==(value_get)
        return link
    endelse
endfunction

function mass_remove()
    #verify already started
    sd dialog_initiated#1
    setcall dialog_initiated link_mass_remove((value_get))
    if dialog_initiated!=0
        return 0
    endif

    #verify no frames
    sd img
    setcall img stage_get_sel()
    if img==0
        return 0
    endif

    #launch the dialog
    import "dialogfield" dialogfield
    str title="Frames remove"
    data init^mass_remove_init
    data do^mass_remove_set
    call dialogfield(title,0,init,do)
endfunction

function mass_remove_init(sd vbox,sd *dialog)
    str info="Remove video(and sound) from Start to End"
    import "labelfield_l" labelfield_l
    call labelfield_l(info,vbox)
    str info_txt="Press on a frame to modify the End value"
    call labelfield_l(info_txt,vbox)
    sd start_txt
    sd start_entry
    sd end_txt
    sd end_entry
    ss cells^start_txt
    ss s="Start"
    ss e="End"

    import "labelfield_left_prepare" labelfield_left_prepare
    importx "_gtk_entry_new" gtk_entry_new
    setcall start_txt labelfield_left_prepare(s)
    setcall start_entry gtk_entry_new()
    setcall end_txt labelfield_left_prepare(e)
    setcall end_entry gtk_entry_new()

    sd pos
    setcall pos stage_get_sel_pos()
    call int_to_entry(pos,start_entry)
    call int_to_entry(pos,end_entry)

    import "tablefield_cells" tablefield_cells
    call tablefield_cells(vbox,2,2,cells)
    call mass_remove_run((value_set),start_entry)
    call link_mass_remove((value_set),end_entry)
endfunction

function mass_remove_set(sd response_id)
    #start to remove if response is ok
    if response_id==(GTK_RESPONSE_OK)
        call mass_remove_run((value_run))
    endif
    call link_mass_remove((value_set),0)
    #redraw the visual sound pulse
    call sound_pixbuf_redraw()
endfunction

