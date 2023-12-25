

format elfobj

importx "_gtk_window_list_toplevels" gtk_window_list_toplevels
importx "_g_list_free" g_list_free

include "../_include/include.h"


import "nthwidgetFromcontainer" nthwidgetFromcontainer
import "firstwidgetFromcontainer" firstwidgetFromcontainer

#########main
#main window widget
function mainwidget()
        data GList#1
        setcall GList gtk_window_list_toplevels()
        data widget#1
        set widget GList#
        call g_list_free(GList)
        return widget
endfunction

########vbox
#vbox window widget
function boxwidget()
        data widget#1
        setcall widget mainwidget()
        setcall widget firstwidgetFromcontainer(widget)
        return widget
endfunction
#vbox/nth
function boxwidget_nth(data index)
    data widget#1
    setcall widget boxwidget()
    setcall widget nthwidgetFromcontainer(widget,index)
    return widget
endfunction

#######edit
function editWidget()
    data widget#1
    Data i=mainwinEditIndex
    setcall widget boxwidget_nth(i)
    return widget
endfunction
#buffer, forward
importx "_gtk_entry_get_text" gtk_entry_get_text
function editWidgetBufferForwardData(data forward,data forwarddata)
    data widget#1
    setcall widget editWidget()
    data buffertext#1
    setcall buffertext gtk_entry_get_text(widget)
    call forward(buffertext,forwarddata)
endfunction
function editWidgetBufferForward(data forward)
    data n=0
    call editWidgetBufferForwardData(forward,n)
endfunction

#######draw
function drawwidget()
    data widget#1
    Data draw=mainwinDrawIndex
    setcall widget boxwidget_nth(draw)
    return widget
endfunction

#######buttons
function buttonsalignWidget()
    data widget#1
    Data mainwinButtonsIndex=mainwinButtonsIndex
    setcall widget boxwidget_nth(mainwinButtonsIndex)
    return widget
endfunction

function buttonswidget()
    data widget#1
    setcall widget buttonsalignWidget()
    setcall widget firstwidgetFromcontainer(widget)
    return widget
endfunction

#######stage
#stage window widget
function stagewidget()
    data widget#1
    Data st=mainwinStageIndex
    setcall widget boxwidget_nth(st)
    return widget
endfunction

#######info
#info window widget
#function infowidget()
#    data widget#1
#    Data mainwinInfoIndex=mainwinInfoIndex
#    setcall widget boxwidget_nth(mainwinInfoIndex)
#    return widget
#endfunction

