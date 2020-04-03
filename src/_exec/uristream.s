
format elf obj

include "../_include/include.h"

import "getplaybin2ptr" getplaybin2ptr

import "nullifyplaybin" nullifyplaybin
import "texter" texter
function endofstream()
    str eos="End Of Stream"
    call texter(eos)
    call nullifyplaybin()
endfunction

import "gst_message_parse_error" gst_message_parse_error
import "getptrgerr" getptrgerr
import "gerrtoerr" gerrtoerr
function stream_error(data message)
    data ptrgerr#1
    setcall ptrgerr getptrgerr()
    data null=NULL
    call gst_message_parse_error(message,ptrgerr,null)
    call gerrtoerr(ptrgerr)
endfunction
function streamerror(data *bus,data message)
    call stream_error(message)
endfunction

import "lldiv" lldiv
function splitGstClockTime(data ptrclock,data ptrtime)
    data dword=4

    data clockLow#1
    data clockHigh#1
    data ptrH#1
    data ptrM#1
    data ptrS#1
    set clockLow ptrclock#
    add ptrclock dword
    set clockHigh ptrclock#
    set ptrH ptrtime
    add ptrtime dword
    set ptrM ptrtime
    add ptrtime dword
    set ptrS ptrtime

    data nomLow#1
    data nomHigh=0
    data resLow#1
    data resHigh#1
    data remLow#1
    data *remHigh#1
    data ptrresult^resLow

    data gstsec=GST_SECOND
    set nomLow gstsec
    call lldiv(ptrresult,clockLow,clockHigh,nomLow,nomHigh)

    data secinH=3600
    set nomLow secinH
    call lldiv(ptrresult,resLow,resHigh,nomLow,nomHigh)

    set ptrH# resLow

    data thenumber=60
    data x#1
    set x remLow
    div x thenumber
    set ptrM# x

    mult x thenumber
    sub remLow x
    set ptrS# remLow
endfunction

import "gst_element_query_position" gst_element_query_position
import "sprintf" sprintf
#false=stop timer,true=displayed
function streamtimer(data *data)
    data playbool#1
    const globalplaybool^playbool
    data true=1
    data false=0

    if playbool==true
        data duration64low#1
        data duration64high#1
        data ptrduration^duration64low
        const ptrduration^duration64low

        data current64low#1
        data *current64high#1
        data ptrcurrent^current64low

        data CLOCK_NONE=GST_CLOCK_TIME_NONE_lowhigh
        if duration64low!=CLOCK_NONE
            if duration64high!=CLOCK_NONE
                data bool#1
                data ptrplaybin#1
                data format=GST_FORMAT_TIME
                data ptrformat^format

                setcall ptrplaybin getplaybin2ptr()
                setcall bool gst_element_query_position(ptrplaybin#,ptrformat,ptrcurrent)
                if bool==false
                    str poserr="Could not query current position."
                    call texter(poserr)
                else
                    chars printduration#200
                    str print^printduration

                    data durH#1
                    data durM#1
                    data durS#1
                    data posH#1
                    data posM#1
                    data posS#1

                    data ptrdur^durH
                    data ptrpos^posH

                    call splitGstClockTime(ptrduration,ptrdur)
                    call splitGstClockTime(ptrcurrent,ptrpos)

                    str timeformat="%u:%02u:%02u / %u:%02u:%02u"
                    call sprintf(print,timeformat,posH,posM,posS,durH,durM,durS)
                    call texter(print)
                    return true
                endelse
            endif
        endif
    endif
    return false
endfunction

function unset_playbool()
    data ptr%globalplaybool
    data false=0
    set ptr# false
endfunction
function get_playbool()
    data ptr%globalplaybool
    return ptr#
endfunction

import "gst_message_parse_state_changed" gst_message_parse_state_changed
import "gdk_threads_add_timeout" gdk_threads_add_timeout
function statechanged(data *bus,data message)
    data newstate#1
    data ptrnewstate^newstate
    data null=0
    data true=1
    data ptrplaybool%globalplaybool

    call gst_message_parse_state_changed(message,null,ptrnewstate,null)

    data GST_STATE_PLAYING=GST_STATE_PLAYING
    data duration%ptrduration
    data clock_none=GST_CLOCK_TIME_NONE_lowhigh
    data quadword=8
    if newstate==GST_STATE_PLAYING
        set ptrplaybool# true
        data msec=1000
        data tm^streamtimer
        call gdk_threads_add_timeout(msec,tm,null)

        str playing="Playing..."
        call texter(playing)

        import "setmem" setmem
        call setmem(duration,quadword,clock_none)

        import "gst_element_query_duration" gst_element_query_duration
        data format=GST_FORMAT_TIME
        data ptrformat^format
        data ptrplaybin#1
        setcall ptrplaybin getplaybin2ptr()
        call gst_element_query_duration(ptrplaybin#,ptrformat,duration)
    endif
endfunction

import "rec_unset" rec_unset
function stop()
    call nullifyplaybin()
    call rec_unset()
    str stopped="Stopped"
    call texter(stopped)
endfunction

import "g_object_set" g_object_set
import "gst_element_set_state" gst_element_set_state
#void
function streamuri(data buffer)
    call nullifyplaybin()

    data playbin2ptr#1
    setcall playbin2ptr getplaybin2ptr()

    data null=0
    str uri="uri"
    call g_object_set(playbin2ptr#,uri,buffer,null)

    data GST_STATE_PLAYING=GST_STATE_PLAYING
    call gst_element_set_state(playbin2ptr#,GST_STATE_PLAYING)
endfunction

function play_click()
    import "editWidgetBufferForward" editWidgetBufferForward
    data forward^streamuri
    call editWidgetBufferForward(forward)
endfunction


