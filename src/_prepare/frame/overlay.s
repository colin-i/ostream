


format elfobj

include "../../_include/include.h"

function stage_overlay()
    import "stage_frame_dialog" stage_frame_dialog
    sd init^stage_overlay_init
    sd set^stage_overlay_set
    ss title="Image overlay"
    call stage_frame_dialog(init,set,title)
endfunction

function stage_overlay_file(sd action,sd value)
    data file#1
    if action==(value_set)
        set file value
    else
        return file
    endelse
endfunction

function stage_overlay_init(sd vbox,sd *dialog)
    #overlay file location
    import "fchooserbuttonfield_open_label" fchooserbuttonfield_open_label
    ss text="File "
    sd file
    setcall file fchooserbuttonfield_open_label(vbox,text)
    call stage_overlay_file((value_set),file)

    import "stage_effect_orientation" stage_effect_orientation
    str position="Placement"
    call stage_effect_orientation((value_set),vbox,(TRUE),position)
endfunction

function stage_overlay_set()
    sd file_entry
    setcall file_entry stage_overlay_file((value_get))

    import "file_chooser_get_fname" file_chooser_get_fname
    sd filename
    setcall filename file_chooser_get_fname(file_entry)

    if filename==0
        return 0
    endif

    import "pixbuf_from_file" pixbuf_from_file
    sd overlay
    setcall overlay pixbuf_from_file(filename)

    importx "_g_free" g_free
    call g_free(filename)

    if overlay==0
        return 0
    endif

    import "stage_get_sel_pixbuf" stage_get_sel_pixbuf
    sd layer
    sd p_layer^layer
    call stage_get_sel_pixbuf(p_layer)

    sd x_factor
    sd y_factor
    sd p_y_factor^y_factor
    setcall x_factor stage_effect_orientation((value_get),p_y_factor)

    import "pixbuf_get_wh" pixbuf_get_wh
    sd over_width
    sd over_height
    sd lay_width
    sd lay_height
    sd over^over_width
    sd lay^lay_width
    call pixbuf_get_wh(overlay,over)
    call pixbuf_get_wh(layer,lay)

    sd min_i
    sd max_i
    if over_width>lay_width
        #the over image width is greater than the lay width
        set min_i 0
        set max_i lay_width
    else
        if x_factor==-1
            set min_i 0
        else
            sd x_space
            set x_space lay_width
            sub x_space over_width
            if x_factor==0
                div x_space 2
                set min_i x_space
            else
                set min_i x_space
            endelse
        endelse
        set max_i min_i
        add max_i over_width
    endelse
    sd min_j
    sd max_j
    if over_height>lay_height
        #the over image height is greater than the lay height
        set min_j 0
        set max_j lay_height
    else
        if y_factor==-1
            set min_j 0
        else
            sd y_space
            set y_space lay_height
            sub y_space over_height
            if y_factor==0
                div y_space 2
                set min_j y_space
            else
                set min_j y_space
            endelse
        endelse
        set max_j min_j
        add max_j over_height
    endelse

    import "pixbuf_over_pixbuf" pixbuf_over_pixbuf
    call pixbuf_over_pixbuf(overlay,layer,min_i,max_i,min_j,max_j)

    import "stage_redraw" stage_redraw
    call stage_redraw()
endfunction

