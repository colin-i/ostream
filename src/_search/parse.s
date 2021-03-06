


format elfobj

include "../_include/include.h"

import "edit_info_prepare_green" edit_info_prepare_green

function search_parse_URIs_launch(ss str,sd table)
    import "table_add_row" table_add_row

    import "gtk_hseparator_new" gtk_hseparator_new
    sd hseparator
    setcall hseparator gtk_hseparator_new()
    data w=-1
    data h=20
    import "gtk_widget_set_size_request" gtk_widget_set_size_request
    call gtk_widget_set_size_request(hseparator,w,h)
    call table_add_row(table,hseparator)

    sd newedit
    setcall newedit edit_info_prepare_green(str)
    call table_add_row(table,newedit)

    import "gtk_image_new" gtk_image_new
    sd img
    setcall img gtk_image_new()
    call table_add_row(table,img)

    import "search_get_image" search_get_image
    call search_get_image(str,img)
endfunction

import "sprintf" sprintf

function search_parse_URIs(ss str,sd table)
    data ind=search_preferences_wrap_index
    sd vars
    import "search_get_vars_based_on_index" search_get_vars_based_on_index
    setcall vars search_get_vars_based_on_index(ind)
    sd s1
    sd s2
    sd s3
    sd *=0
    sd strings^s1

    set s1 vars#
    set s2 str
    data dw=4
    add vars dw
    set s3 vars#

    import "allocsum_null" allocsum_null
    sd mem
    sd ptr_mem^mem
    sd err
    data noerr=noerror
    setcall err allocsum_null(strings,ptr_mem)
    if err!=noerr
        return err
    endif
    str form="%s%s%s"
    call sprintf(mem,form,s1,s2,s3)
    call search_parse_URIs_launch(mem,table)
    import "free" free
    call free(mem)
endfunction

function count_the_findings(ss *str,sd data)
    inc data#
endfunction

import "search_get_vars" search_get_vars
import "find_start_end_forward_center_data" find_start_end_forward_center_data
function search_parse_got_body(ss body,sd size,sd data)
    sd vars
    setcall vars search_get_vars()
    sd start
    set start vars#
    data dw=4
    add vars dw
    sd end
    set end vars#

    sd table
    set table data#
    add data dw

    sd totalentries=0
    sd ptr_totalentries^totalentries
    sd counter^count_the_findings
    call find_start_end_forward_center_data(body,size,start,end,counter,ptr_totalentries)
    chars number#dword_null
    ss nr^number
    str dw_str="%u"
    call sprintf(nr,dw_str,totalentries)
    import "gtk_entry_set_text" gtk_entry_set_text
    call gtk_entry_set_text(data#,nr)

    sd entries^search_parse_URIs
    call find_start_end_forward_center_data(body,size,start,end,entries,table)
endfunction



import "uri_get_content_forward_data" uri_get_content_forward_data
function search_parse_got_uri(ss uri,sd vbox)
    sd urilabel
    sd uritext

    sd itemslabel
    sd itemstext

    sd rows=2
    sd cols=2
    sd widgets^urilabel

    #row1
    import "gtk_label_new" gtk_label_new
    str uristr="URI: "

    setcall urilabel gtk_label_new(uristr)

    setcall uritext edit_info_prepare_green(uri)

    #row2
    str itemsstr="Items: "

    setcall itemslabel gtk_label_new(itemsstr)

    str init=""
    setcall itemstext edit_info_prepare_green(init)

    #scroll panel
    import "scrollfield" scrollfield
    sd scroll
    setcall scroll scrollfield(vbox)
    import "gtk_scrolled_window_set_policy" gtk_scrolled_window_set_policy
    data always=GTK_POLICY_ALWAYS
    data auto=GTK_POLICY_AUTOMATIC
    call gtk_scrolled_window_set_policy(scroll,auto,always)

    import "tablefield_cells" tablefield_cells
    ##begin the table
    sd table
    sd extradata
    setcall table tablefield_cells(scroll,rows,cols,widgets)

    #entries
    data nextFn^search_parse_got_body
    sd pass^table
    set extradata itemstext
    call uri_get_content_forward_data(uri,nextFn,pass)

    #lastrow
    str endoflist="End of List"
    sd last
    setcall last gtk_label_new(endoflist)
    call table_add_row(table,last)
endfunction



function search_parse_set_windows(sd vbox)
    import "editWidgetBufferForwardData" editWidgetBufferForwardData
    data nextFn^search_parse_got_uri
    call editWidgetBufferForwardData(nextFn,vbox)
endfunction

import "dialogfield_size" dialogfield_size
function search_parse()
    ss searchlist="Search List"
    sd null=0
    data fn^search_parse_set_windows
    data w=300
    data h=512
    call dialogfield_size(searchlist,null,fn,null,w,h)
endfunction
