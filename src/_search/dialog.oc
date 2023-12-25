


format elfobj

include "../_include/include.h"

function show_preferences_set_windows(sd vbox)
    import "packstart" packstart

    data true=1

    importx "_gtk_frame_new" gtk_frame_new
    str body="Body"
    sd frame#1
    setcall frame gtk_frame_new(body)
    call packstart(vbox,frame,true)

    import "tablefield_row" tablefield_row

    importx "_gtk_entry_new" gtk_entry_new
    importx "_gtk_label_new" gtk_label_new

    import "labelfield_left_prepare" labelfield_left_prepare
    import "edit_info_prepare_blue" edit_info_prepare_blue
    #Get
    #info label
    data cols=5

    sd getinfo

    str getinfotext="Get the URIs between the Start and the End:"
    setcall getinfo labelfield_left_prepare(getinfotext)

    sd table
    setcall table tablefield_row(frame,cols,getinfo)

    import "search_get_fields" search_get_fields
    sd fields
    setcall fields search_get_fields()
    data dw=4
    sd widgets

    set widgets fields


    #rowGetEntries_label1
    str startlabel_text="Start->"
    setcall fields# gtk_label_new(startlabel_text)
    add fields dw

    #rowGetEntries_entry1
    setcall fields# gtk_entry_new()
    add fields dw

    #rowGetEntries_text
    str get_uri_text="URI"
    setcall fields# edit_info_prepare_blue(get_uri_text)
    add fields dw

    #rowGetEntries_entry2
    setcall fields# gtk_entry_new()
    add fields dw

    #rowGetEntries_label2
    str endlabel_text="<-End"
    setcall fields# gtk_label_new(endlabel_text)
    add fields dw

    #add the group1
    import "table_add_cells" table_add_cells
    data onerow=1
    setcall widgets table_add_cells(table,onerow,widgets)


    import "hseparatorfield_table" hseparatorfield_table
    call hseparatorfield_table(table)


    #the wrap widgets follow
    import "labelfield_left_table" labelfield_left_table

    str wraptext="Wrap the URI between the following fields to create the final URI or leave blank:"
    call labelfield_left_table(wraptext,table)

    str wrap_text="+"

    setcall fields# gtk_entry_new()
    add fields dw
    setcall fields# gtk_label_new(wrap_text)
    add fields dw
    setcall fields# edit_info_prepare_blue(get_uri_text)
    add fields dw
    setcall fields# gtk_label_new(wrap_text)
    add fields dw
    setcall fields# gtk_entry_new()

    #add the group2
    call table_add_cells(table,onerow,widgets)

    #set vars to display
    import "set_field_pack" set_field_pack
    call set_field_pack()
endfunction

import "move_to_home_v" move_to_home_v
function show_preferences_continuation()
	call move_to_home_v()
	import "sys_folder_enterleave" sys_folder_enterleave
	import "write_free_read" write_free_read
	data fn^write_free_read
	call sys_folder_enterleave(fn)
endfunction

#v
function show_preferences()
    str searchpreferences="Search Preferences"
    data modal=GTK_DIALOG_MODAL
    data set^show_preferences_set_windows
    data continuation^show_preferences_continuation

    import "dialogfield" dialogfield
    call dialogfield(searchpreferences,modal,set,continuation)
endfunction
