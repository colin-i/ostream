


format elfobj

include "../_include/include.h"

function stage_preview()
    import "stage_get_sel" stage_get_sel
    sd img
    setcall img stage_get_sel()
    if img==0
        return 0
    endif

    #used for allowing only one timeout for preview
    sd key
    setcall key sound_random_key()
    inc key#

    data letplay#1
    const ptr_letplay^letplay
    set letplay 1

    call stage_preview_next(key#)
endfunction

function stage_pause()
    data p%ptr_letplay
    set p# 0
    call sound_pause()
endfunction

import "stage_get_sel_pos" stage_get_sel_pos
import "stage_get_frames" stage_get_frames

function stage_preview_next(sd random_key)
    #get sel position
    sd pos
    setcall pos stage_get_sel_pos()
    #total positions
    sd total_pos
    setcall total_pos stage_get_frames()

    #get the frame length
    import "stage_frame_time_numbers" stage_frame_time_numbers
    sd length
    setcall length stage_frame_time_numbers((stage_f_length_get),pos)

    #sound
    call sound_send_buffer(pos,random_key)

    #test next pos with the final one
    inc pos
    if pos==total_pos
        #stop if last pos
        return 0
    endif

    #set the timeout duration
    import "stage_file_options_fps" stage_file_options_fps
    sd fps
    setcall fps stage_file_options_fps()
    import "rule3" rule3
    sd timeoutduration
    setcall timeoutduration rule3(length,fps,1000)

    importx "_gdk_threads_add_timeout" gdk_threads_add_timeout
    data f^stage_preview_timeout
    call gdk_threads_add_timeout(timeoutduration,f,random_key)
endfunction

function sound_random_key()
    data key#1
    return #key
endfunction

#timeout function
function stage_preview_timeout(sd key)
    #pause or close
    sd pause%ptr_letplay
    if pause#==0
        return 0
    endif

    sd k
    setcall k sound_random_key()
    if k#!=key
        #there is another timeout launched
        return 0
    endif

    #get sel position
    sd pos
    setcall pos stage_get_sel_pos()
    #get next pos
    inc pos
    #total positions
    sd total_pos
    setcall total_pos stage_get_frames()
    if pos!=total_pos
        #display the selection
        import "stage_nthwidgetFromcontainer" stage_nthwidgetFromcontainer
        sd ebox
        setcall ebox stage_nthwidgetFromcontainer(pos)
        import "stage_display_pixbuf" stage_display_pixbuf
        call stage_display_pixbuf(ebox)
        #sync with the scroll
        sd x
        sd y
        sd wind
        importx "_gtk_widget_get_window" gtk_widget_get_window
        setcall wind gtk_widget_get_window(ebox)
        importx "_gdk_window_get_position" gdk_window_get_position
        call gdk_window_get_position(wind,#x,#y)
        import "stage_scroll" stage_scroll
        sd scrl
        setcall scrl stage_scroll()
        importx "_gtk_scrolled_window_get_hadjustment" gtk_scrolled_window_get_hadjustment
        sd adj
        setcall adj gtk_scrolled_window_get_hadjustment(scrl#)
        sd value#2
        sd upper#2
        sd page_size#2
        importx "_g_object_get" g_object_get
        call g_object_get(adj,"value",#value,"upper",#upper,"page-size",#page_size,0)
        import "double_to_int" double_to_int
        setcall value double_to_int(#value)
        setcall upper double_to_int(#upper)
        setcall page_size double_to_int(#page_size)
        #use [lower,upper-page_size]
        sd max
        set max upper
        sub max page_size
        if value<max
            sd next
            set next value
            add next page_size
            if x>=next
                if x>max
                    set x max
                endif
                import "int_to_double" int_to_double
                sd double_low
                sd double_high
                call int_to_double(x,#double_low)
                importx "_gtk_adjustment_set_value" gtk_adjustment_set_value
                call gtk_adjustment_set_value(adj,double_low,double_high)
            endif
        endif
    endif

    call stage_preview_next(key)

    return 0
endfunction


#sound preview
import "sound_preview_init" sound_preview_init
import "sound_preview_free" sound_preview_free
import "sound_preview_write_buffer" sound_preview_write_buffer

function sound_preview_bool()
    data bool#1
    return #bool
endfunction

function sound_ready(sd frame_pos,sd random_key)
    data logical_frame_pos#1
    sd ptrbool
    setcall ptrbool sound_preview_bool()
    #condition to unset the previous player: if was created and has a different format, or another frame pressed
    if ptrbool#==1
        sd bool
        setcall bool sound_format((value_get))
        if bool==1
            inc logical_frame_pos
            if frame_pos!=logical_frame_pos
                set bool 0
            endif
        endif
        if bool==0
            #unset the previous player
            call sound_preview_free()
            set ptrbool# 0
        endif
    endif
    #condition to set the player: if isn't created
    if ptrbool#==0
        setcall ptrbool# sound_preview_init()
        if ptrbool#==1
            call sound_format((value_set))
            set logical_frame_pos frame_pos
            sd i=0
            sd cursor
            set cursor frame_pos
            sd max
            setcall max sound_preview_buffers()
            while i<max
                call sound_prev_pos(cursor,random_key)
                inc cursor
                inc i
            endwhile
        endif
    endif
endfunction

function sound_pause()
    sd prev
    setcall prev sound_preview_bool()
    if prev#==1
        call sound_preview_free()
        set prev# 0
    endif
endfunction

import "stage_sound_rate" stage_sound_rate
import "stage_sound_channels" stage_sound_channels
import "stage_sound_bps" stage_sound_bps
import "stage_sound_blockalign" stage_sound_blockalign

function sound_send_buffer(sd frame_pos,sd random_key)
    call sound_ready(frame_pos,random_key)
    addcall frame_pos sound_preview_buffers()
    call sound_prev_pos(frame_pos,random_key)
endfunction

function sound_preview_buffers()
    sd buffers
    setcall buffers stage_file_options_fps()
    mult buffers 2
    return buffers
endfunction

import "stage_sound_framelength_to_soundlength" stage_sound_framelength_to_soundlength

function sound_prev_pos(sd frame_pos,sd random_key)
    #get logical sound position
    sd sum_at_point
    setcall sum_at_point stage_frame_time_numbers((stage_frame_time_sum_at_index),frame_pos)
    if sum_at_point==0
        if frame_pos!=0
            #after the last frame, once
            return (void)
        endif
    endif
    sd pos_sound_size
    setcall pos_sound_size stage_sound_framelength_to_soundlength(sum_at_point)
    import "stage_sound_subsize" stage_sound_subsize
    sd current_sound_size
    setcall current_sound_size stage_sound_subsize((value_get))
    if current_sound_size<=pos_sound_size
        #no sound buffer to add
        return (void)
    endif

    sd test_minimum_sz
    set test_minimum_sz current_sound_size
    sub test_minimum_sz pos_sound_size
    sd minimum_sz
	sd blockalign
	setcall blockalign stage_sound_blockalign()
    set minimum_sz blockalign
    if test_minimum_sz<=minimum_sz
        #insignificant sound detected
        return (void)
    endif

    #get next logical size
    sd next_size
    set next_size pos_sound_size
    sd length_at_point
    setcall length_at_point stage_frame_time_numbers((stage_frame_time_get_at_index),frame_pos)
    addcall next_size stage_sound_framelength_to_soundlength(length_at_point)

    #next size can be smaller
    if current_sound_size<next_size
        set next_size current_sound_size
    else
	#if it's last, forward all remaining sound
        sd all_frames
        setcall all_frames stage_get_frames()
        sd next_frame
        set next_frame frame_pos
        inc next_frame
        if next_frame==all_frames
            set next_size current_sound_size
        endif
    endelse

    #output the sound
    import "stage_sound_alloc_getbytes" stage_sound_alloc_getbytes
    sd buf_size
    sd buf
    set buf_size next_size
    sub buf_size pos_sound_size
    setcall buf stage_sound_alloc_getbytes()
    add buf pos_sound_size
    call sound_preview_write_buffer(buf,buf_size,random_key)
endfunction

function sound_format(sd procedure)
    data sample_rate#1
    data channels#1
    data bits_per_sample#1
    sd current_sample_rate
    sd current_channels
    sd current_bits_per_sample
    setcall current_sample_rate stage_sound_rate((value_get))
    setcall current_channels stage_sound_channels((value_get))
    setcall current_bits_per_sample stage_sound_bps((value_get))
    if procedure==(value_set)
        set sample_rate current_sample_rate
        set channels current_channels
        set bits_per_sample current_bits_per_sample
    else
    #bool
        sd changed=0
        if sample_rate!=current_sample_rate
            set changed 1
        endif
        if channels!=current_channels
            set changed 1
        endif
        if bits_per_sample!=current_bits_per_sample
            set changed 1
        endif
        if changed==1
            set sample_rate current_sample_rate
            set channels current_channels
            set bits_per_sample current_bits_per_sample
            return 0
        endif
        return 1
    endelse
endfunction
