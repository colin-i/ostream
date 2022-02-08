


format elfobj



##lists
function widget_get_children_number_count_fn(sd *element,sd data)
    inc data#
endfunction

function widget_get_children_number_count(sd list,sd *data)
    importx "_g_list_foreach" g_list_foreach
    sd nr=0
    sd ptr_nr^nr
    data fn^widget_get_children_number_count_fn
    call g_list_foreach(list,fn,ptr_nr)
    return nr
endfunction

#returns what forward returns
function widget_forward_children_data(sd widget,sd forward,sd data)
    sd GList
    importx "_gtk_container_get_children" gtk_container_get_children
    setcall GList gtk_container_get_children(widget)
    sd ret
    setcall ret forward(GList,data)
    importx "_g_list_free" g_list_free
    call g_list_free(GList)
    return ret
endfunction

#nr of widget childrens
function widget_get_children_number(sd widget)
    data fn^widget_get_children_number_count
    sd ret
    setcall ret widget_forward_children_data(widget,fn)
    return ret
endfunction


#pos
function widget_position_in_container(sd widget,sd container)
    importx "_g_list_index" g_list_index
    data f^g_list_index
    sd ret
    setcall ret widget_forward_children_data(container,f,widget)
    return ret
endfunction

importx "_g_list_nth_data" g_list_nth_data

function nthwidgetFromcontainer(data container,data index)
    data widget#1
    data GList#1
    setcall GList gtk_container_get_children(container)
    #the element's data, or NULL if the position is off the end of the GList
    setcall widget g_list_nth_data(GList,index)
    call g_list_free(GList)
    return widget
endfunction

function firstwidgetFromcontainer(sd container)
    sd widget
    setcall widget nthwidgetFromcontainer(container,0)
    return widget
endfunction
