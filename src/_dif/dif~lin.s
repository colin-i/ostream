


format elfobj

override underscore_pref 0

include "../_include/include.h"

#Const X_OK=1
#Const FORWARD=1

import "setmemzero" setmemzero
import "texter" texter

function movetoScriptfolder(data forward)
#on lin no, Script is alone in bin folder
#at this first call img/version and then sys
	sd f
	sd err
	setcall f share_folder(#err,(NULL))
	if err=(noerror)
		setcall err move_to_folder(f)
		if err=(noerror)
			call forward()
			return (void)
		endif
	endif
	call texter(err)
endfunction


importx "__errno_location" errno
#errno
function geterrno()
        data err#1
        setcall err errno()
        return err#
endfunction



function system_variables_alignment_pad(data *value,data *greatest)
    data noalignment=0
    return noalignment
endfunction

importx "time" time
function timeNode(data ptrtime_t)
    data time_t#1
    setcall time_t time(ptrtime_t)
    return time_t
endfunction

importx "chdir" chd
function chdr(str value)
    data x#1
    setcall x chd(value)
    return x
endfunction

importx "snprintf" snprintf
function c_snprintf_strvaluedisp(str display,data max,str format,str text,data part2)
    call snprintf(display,max,format,text,part2)
endfunction



importx "gtk_file_chooser_get_filename" gtk_file_chooser_get_filename
function file_chooser_get_fname(sd dialog)
    sd file
    setcall file gtk_file_chooser_get_filename(dialog)
    return file
endfunction





#jpeg

function jpeg_get_jdestruct_size()
    return (jdestruct_size_lin)
endfunction

function jpeg_get_jdestruct_output_width()
    return (jdestruct_output_width_lin)
endfunction
function jpeg_get_jdestruct_output_height()
    return (jdestruct_output_height_lin)
endfunction
function jpeg_get_jdestruct_output_components()
    return (jdestruct_output_components_lin)
endfunction

#

##times

const CLOCK_MONOTONIC=1

#milliseconds
function get_time()
    importx "clock_gettime" clock_gettime
    data sec#1
    data nanoseconds#1

    data timespec^sec
    call clock_gettime((CLOCK_MONOTONIC),timespec)

    mult sec 1000
    div nanoseconds (1000*1000)

    sd milliseconds
    set milliseconds sec
    add milliseconds nanoseconds
    return milliseconds
endfunction

function sleepMs(sd value)
    importx "usleep" usleep

    #milliseconds in, convert to microseconds
    mult value 1000

    call usleep(value)
endfunction


###capture alternative

function term_toggle(sd action,sd value)
    data term_entry#1
    if action=(value_set)
        set term_entry value
    else
        return term_entry
    endelse
endfunction

function capture_alternative_init(sd vbox)
    importx "gtk_check_button_new_with_label" gtk_check_button_new_with_label
    importx "gtk_container_add" gtk_container_add
    importx "gtk_widget_set_tooltip_markup" gtk_widget_set_tooltip_markup
    ss term_txt="Terminal(if exists)"
    sd term_entry
    setcall term_entry gtk_check_button_new_with_label(term_txt)
    call term_toggle((value_set),term_entry)
    str txt="Use only if the application has a terminal."
    call gtk_widget_set_tooltip_markup(term_entry,txt)
    call gtk_container_add(vbox,term_entry)
endfunction
function capture_alternative_set(sd *p_cairoflag,sd p_term)
    sd t_entry
    setcall t_entry term_toggle((value_get))
    importx "gtk_toggle_button_get_active" gtk_toggle_button_get_active
    setcall p_term# gtk_toggle_button_get_active(t_entry)
endfunction
#bool
function capture_alternative_prepare()
    importx "gtk_widget_hide_all" gtk_widget_hide_all
    import "mainwidget" mainwidget
    import "dialog_handle" dialog_handle
    sd win
    setcall win mainwidget()
    call gtk_widget_hide_all(win)
    setcall win dialog_handle()
    call gtk_widget_hide_all(win)
    import "message_dialog" message_dialog
    str term_msg="Press ENTER in the terminal to stop."
    call message_dialog(term_msg)
    call capture_alt_ev((value_set))
    #thread for getchar
    import "getptrgerr" getptrgerr
    sd ptrgerr
    setcall ptrgerr getptrgerr()
    importx "g_thread_create" g_thread_create
    data forward^capture_alt_thread_proc
    sd thread
    setcall thread g_thread_create(forward,0,1,ptrgerr)
    if thread=0
        import "gerrtoerr" gerrtoerr
        call gerrtoerr(ptrgerr)
        call capture_alt_showback()
        return 0
    endif
    call capture_alt_thread((value_set),thread)
    call capture_alt_thread_dup((value_set),thread)
    return 1
endfunction
function capture_alternative_append()
endfunction
function capture_alternative_free()
    sd event
    setcall event capture_alt_ev((value_get))
    call closeevent(event)
    importx "g_thread_join" g_thread_join
    call capture_alt_thread_dup((value_set),0)
    sd thread
    setcall thread capture_alt_thread((value_get))
    call g_thread_join(thread)
    call capture_alt_showback()
endfunction

function capture_alt_showback()
    importx "gtk_widget_show_all" gtk_widget_show_all
    sd win
    setcall win mainwidget()
    call gtk_widget_show_all(win)
    setcall win dialog_handle()
    call gtk_widget_show_all(win)
endfunction

function capture_alt_ev(sd action)
    #sem_t is required to keep it at even(?)(at 4?) address (something about to share it by processes and threads)
    data ev#2*8+4
    data event^ev
    if action=(value_set)
        import "multiple_of_nr" multiple_of_nr
        setcall event multiple_of_nr(event,4)
        call createevent(event)
    else
    #if action==(value_get)
    #event
        return event
    endelse
endfunction
function capture_alt_ev_wait()
    sd event
    setcall event capture_alt_ev((value_get))
    call waitevent(event)
endfunction
function capture_alt_ev_set()
    sd event
    setcall event capture_alt_ev((value_get))
    call setevent(event)
endfunction
##events
function createevent(sd event)
    importx "sem_init" sem_init
    call sem_init(event,0,0)
    #0 ok,-1 error(bad argument?)
endfunction
function waitevent(sd event)
    importx "sem_wait" sem_wait
    call sem_wait(event)
endfunction
function closeevent(sd event)
    importx "sem_destroy" sem_destroy
    call sem_destroy(event)
endfunction
function setevent(sd event)
    importx "sem_post" sem_post
    call sem_post(event)
endfunction

function capture_alt_thread(sd action,sd value)
    data thread#1
    if action=(value_set)
        set thread value
    else
        return thread
    endelse
endfunction
function capture_alt_thread_dup(sd action,sd value)
    data thread#1
    if action=(value_set)
        set thread value
    else
        return thread
    endelse
endfunction
const nfdbits=8*4
function fd_mask(sd d)
    #define	__FD_MASK(d)	((__fd_mask) 1 << ((d) % __NFDBITS))
    #__fd_mask=long int
    #__NFDBITS	(8 * (int) sizeof (__fd_mask))
    import "rest" rest
    import "shl" shl
    sd mask
    setcall mask rest(d,(nfdbits))
    setcall mask shl(1,mask)
    return mask
endfunction
function fds_bits(sd fds,sd d)
    #__FDS_BITS(set) ((set)->fds_bits)
    #__fd_mask fds_bits[__FD_SETSIZE / __NFDBITS];
    #__FD_SETSIZE		1024
    sd elt
    setcall elt fd_elt(d)

    import "array_get_int" array_get_int
    sd value
    setcall value array_get_int(fds,elt)
    return value
endfunction
function fd_elt(sd d)
    #__FD_ELT(d)	((d) / __NFDBITS)
    sd elt
    set elt d
    div elt (nfdbits)
    return elt
endfunction
function capture_alt_thread_proc(sd *noArg)
    while 1=1
        const STDIN_FILENO=0
        const fd_set_size=128
        char filedescriptor_set#fd_set_size
        data fds^filedescriptor_set
        call setmemzero(fds,(fd_set_size))
        #define __FD_SET(d, set) \
            #((void) (__FDS_BITS (set)[__FD_ELT (d)] |= __FD_MASK (d)))
        import "array_set_int" array_set_int
        sd value
        sd elt
        sd mask
        setcall value fds_bits(fds,(STDIN_FILENO))
        setcall elt fd_elt((STDIN_FILENO))
        setcall mask fd_mask((STDIN_FILENO))

        or value mask
        call array_set_int(fds,elt,value)

        importx "select" select
        sd tv_sec=100
        sd *tv_usec=0
        sd timeval^tv_sec
        call select((STDIN_FILENO+1),fds,0,0,timeval)

        setcall value fds_bits(fds,(STDIN_FILENO))
        and value mask
        if value!=0
            import "av_dialog_stop" av_dialog_stop
            call av_dialog_stop((value_set),1)
            return 0
        endif
        sd thread_dup
        setcall thread_dup capture_alt_thread_dup((value_get))
        if thread_dup=0
            return 0
        endif
    endwhile
endfunction

#file seek dif

#er
function file_seek_dif_cursor(sd file,sd off)
    import "file_seek_cursor" file_seek_cursor
    sd err
    setcall err file_seek_cursor(file,off)
    return err
endfunction


#sound preview

const SND_PCM_STREAM_PLAYBACK=0
const SND_PCM_ACCESS_RW_INTERLEAVED=3

const SND_PCM_FORMAT_U8=1
const SND_PCM_FORMAT_S16_LE=2

const SND_PCM_NONBLOCK=1
#const SND_PCM_ASYNC=2

importx "snd_pcm_open" snd_pcm_open
importx "snd_pcm_hw_params_malloc" snd_pcm_hw_params_malloc
importx "snd_pcm_hw_params_free" snd_pcm_hw_params_free
importx "snd_pcm_close" snd_pcm_close
importx "snd_pcm_writei" snd_pcm_writei
importx "snd_pcm_avail_update" snd_pcm_avail_update
importx "snd_pcm_get_params" snd_pcm_get_params

importx "snd_pcm_hw_params_any" snd_pcm_hw_params_any
importx "snd_pcm_hw_params_set_access" snd_pcm_hw_params_set_access
importx "snd_pcm_hw_params_set_format" snd_pcm_hw_params_set_format
importx "snd_pcm_hw_params_set_rate" snd_pcm_hw_params_set_rate
importx "snd_pcm_hw_params_set_channels" snd_pcm_hw_params_set_channels
importx "snd_pcm_hw_params" snd_pcm_hw_params
importx "snd_pcm_prepare" snd_pcm_prepare

#bool
function sound_preview_init()
    sd handle
    setcall handle sound_preview_playback_handle()
    set handle# 0
    str name="default"
    sd err
    setcall err snd_pcm_open(handle,name,(SND_PCM_STREAM_PLAYBACK),(SND_PCM_NONBLOCK))
    if err<0
        str er="Cannot open audio device"
        call texter(er)
        return 0
    endif
    sd hw_params
    setcall err snd_pcm_hw_params_malloc(#hw_params)
    if err<0
        str hw_er="Cannot allocate hardware parameter structure"
        call texter(hw_er)
        call sound_preview_free()
        return 0
    endif
    sd bool
    setcall bool sound_preview_initialize(handle#,hw_params)
    call snd_pcm_hw_params_free(hw_params)
    if bool=0
        call sound_preview_free()
    endif
	#set buffer size 0 needed for write
	call alsa_write((value_extra))
    return bool
endfunction
function sound_preview_free()
    sd handle
    setcall handle sound_preview_playback_handle()
    if handle#!=0
        call snd_pcm_close(handle#)
        #in case a sound timeout will come
        set handle# 0
    endif
endfunction
import "stage_sound_alloc_getbytes" stage_sound_alloc_getbytes
function sound_preview_write_buffer(sd bf_pos,sd buffer_size,sd random_key)
    sd bf
    setcall bf stage_sound_alloc_getbytes()
    sub bf_pos bf
    call alsa_write((value_set),random_key,bf_pos,buffer_size)
endfunction

function sound_preview_playback_handle()
    data playback_handle#1
    return #playback_handle
endfunction

#bool
function sound_preview_initialize(sd handle,sd hw_params)
    sd err
    setcall err snd_pcm_hw_params_any(handle,hw_params)
    if err<0
        str hwini_er="Cannot initialize hardware parameter structure"
        call texter(hwini_er)
        return 0
    endif
    setcall err snd_pcm_hw_params_set_access(handle,hw_params,(SND_PCM_ACCESS_RW_INTERLEAVED))
    if err<0
        str ac_er="Cannot set access type"
        call texter(ac_er)
        return 0
    endif
    import "stage_sound_bps" stage_sound_bps
    sd bps
    setcall bps stage_sound_bps((value_get))
    if bps=8
        setcall err snd_pcm_hw_params_set_format(handle,hw_params,(SND_PCM_FORMAT_U8))
    else
        setcall err snd_pcm_hw_params_set_format(handle,hw_params,(SND_PCM_FORMAT_S16_LE))
    endelse
    if err<0
        str fr_er="Cannot set bits per sample"
        call texter(fr_er)
        return 0
    endif
    #last param is int *  dir, Sub unit direction
    import "stage_sound_rate" stage_sound_rate
    sd rate
    setcall rate stage_sound_rate((value_get))
    setcall err snd_pcm_hw_params_set_rate(handle,hw_params,rate,0)
    if err<0
        str rate_er="Cannot set sample rate"
        call texter(rate_er)
        return 0
    endif
    import "stage_sound_channels" stage_sound_channels
    sd channels
    setcall channels stage_sound_channels((value_get))
    setcall err snd_pcm_hw_params_set_channels(handle,hw_params,channels)
    if err<0
        str ch_er="Cannot set channel count"
        call texter(ch_er)
        return 0
    endif
    setcall err snd_pcm_hw_params(handle,hw_params)
    if err<0
        str hwpar_er="Cannot set parameters"
        call texter(hwpar_er)
        return 0
    endif
    #
    setcall err snd_pcm_prepare(handle)
    if err<0
        str inter_er="Cannot prepare audio interface for use"
        call texter(inter_er)
        return 0
    endif
    return 1
endfunction

function alsa_write(sd procedure,sd random_key,sd bf_pos,sd all_buffer_size)
    # send in parts or all size
    #values
    sd handle
    setcall handle sound_preview_playback_handle()
    if handle#=0
        return (void)
    endif
    data pos#1
    data buffer_size#1
    data wait_bufferfull_timeout#1
    if procedure=(value_extra)
        set buffer_size 0
        set wait_bufferfull_timeout 0
        call alsa_full_set((value_set),#wait_bufferfull_timeout)
        return (void)
    endif
    #all values are in frames(blockalign values) except pos
    importx "gdk_threads_add_timeout" gdk_threads_add_timeout
    sd main_frames
    sd period_size
    sd err
    import "stage_sound_blockalign" stage_sound_blockalign
    sd blockalign
    setcall blockalign stage_sound_blockalign()
    if procedure=(value_set)
        if buffer_size!=0
            div all_buffer_size blockalign
            add buffer_size all_buffer_size
            if wait_bufferfull_timeout=1
                #a timeout will resolve the new sound
                return (void)
            endif
        else
            set pos bf_pos
            set buffer_size all_buffer_size
            div buffer_size blockalign
        endelse
    endif
    sd low_size
    setcall low_size alsa_low_size(pos,buffer_size)
    if low_size=1
        return (void)
    endif
    #get available size
    sd avail_size
    setcall avail_size alsa_get_availsize(handle#)
    if avail_size<0
        return (void)
    endif
    #see the remaining size
    sd write_size
    set write_size buffer_size
    if buffer_size>avail_size
        set write_size avail_size
    endif
    #write the data
    import "stage_sound_subsize" stage_sound_subsize
    sd buffer
    sd rawsize
    set rawsize write_size
    mult rawsize blockalign
    set buffer pos
    add buffer rawsize
    sd currentsize
    setcall currentsize stage_sound_subsize((value_get))
    if buffer>currentsize
        str sz_err="Size error"
        call texter(sz_err)
        return (void)
    endif
    sub buffer rawsize
    addcall buffer stage_sound_alloc_getbytes()
    #
    sd frames_wrote
    setcall frames_wrote snd_pcm_writei(handle#,buffer,write_size)
    if frames_wrote!=write_size
        str wrerr="Write to audio interface failed"
        call texter(wrerr)
        return (void)
    endif
    #timeout for next data
    if buffer_size>avail_size
        set wait_bufferfull_timeout 1
        #set buffer and buffer size for next part
        add pos rawsize
        #wait half main buffer to be played
        setcall err alsa_get_params(handle#,#main_frames,#period_size)
        if err<0
            return (void)
        endif
        div main_frames 2
        #main_frames     x
        #sample rate     1000 millisec
        sd timeout_space=1000
        mult timeout_space main_frames
        divcall timeout_space stage_sound_rate((value_get))
        data f^alsa_write_timeout_callback
        call gdk_threads_add_timeout(timeout_space,f,random_key)
    endif
    sub buffer_size write_size
    return (void)
endfunction

function alsa_full_set(sd procedure,sd ptr)
    data p#1
    if procedure=(value_set)
        set p ptr
    else
        return p
    endelse
endfunction

#alsa return
function alsa_get_params(sd handle,sd frames,sd period)
    sd err
    setcall err snd_pcm_get_params(handle,frames,period)
    if err<0
        str geterr="Cannot get params"
        call texter(geterr)
    endif
    return err
endfunction
#alsa return
function alsa_get_availsize(sd handle)
    sd avail_size
    setcall avail_size snd_pcm_avail_update(handle)
    if avail_size<0
        str av_err="Avail size function error"
        call texter(av_err)
    endif
    return avail_size
endfunction

function alsa_write_timeout_callback(sd key)
    #reset the timeout pointer
    sd p
    setcall p alsa_full_set((value_get))
    set p# 0
    call alsa_write_and_verify_key(key)
    #0 for not called again
    return 0
endfunction

function alsa_write_and_verify_key(sd key)
    sd k
    import "sound_random_key" sound_random_key
    setcall k sound_random_key()
    if k#=key
        #k#!=key means another frame pressed
        call alsa_write((value_run),key)
    endif
endfunction

function alsa_low_size(sd pos,sd buffer_size)
    #reach a size for write limit
    sd rate
    setcall rate stage_sound_rate((value_get))
    if buffer_size<rate
        sd blockalign
        setcall blockalign stage_sound_blockalign()
        mult buffer_size blockalign
        add pos buffer_size
        sd currentsize
        setcall currentsize stage_sound_subsize((value_get))
        if pos<currentsize
            #low_size= true, wait for more
            return 1
        endif
    endif
    return 0
endfunction

const SND_PCM_STATE_RUNNING=3

#bool
function sound_preview_end_and_no_errors()
    importx "snd_pcm_status_malloc" snd_pcm_status_malloc
    importx "snd_pcm_status_free" snd_pcm_status_free
    sd handle
    setcall handle sound_preview_playback_handle()
    sd status
    sd er
    setcall er snd_pcm_status_malloc(#status)
    if er<0
        str alloc="snd_pcm_status_malloc error"
        call texter(alloc)
        return (FALSE)
    endif
    sd bool
    setcall bool sound_preview_end_and_no_errors_continuation(handle#,status)
    call snd_pcm_status_free(status)
    return bool
endfunction
#bool
function sound_preview_end_and_no_errors_continuation(sd handle,sd status)
    importx "snd_pcm_status" snd_pcm_status
    importx "snd_pcm_status_get_state" snd_pcm_status_get_state
    sd er
    setcall er snd_pcm_status(handle,status)
    if er<0
        str error="snd_pcm_status error"
        call texter(error)
        return (FALSE)
    endif
    sd state
    setcall state snd_pcm_status_get_state(status)
    if state=(SND_PCM_STATE_RUNNING)
        return (FALSE)
    endif
    return (TRUE)
endfunction


#html 1
#	enter leave  B
#img
#	enter leave data    1 at img enter leave at init A(has recurse in edit)   1 img edit enter leave at cover/frame B
#	stage get image 1   at frames,selectframe B
#version 1    A
#
#
#captures
#	init 1    A
#	1         B
#sys
#	init 1    A
#	sys enter leave 4(init 1 A ,dialog 1 B,stage 2 B)
#
#
#1 at A to share from img to version, next to home: init_user, at sys
#
#this was with er, rest are with texter
#
#captures changes to home  return
#sys 3 changes to home     enterleave
#html changes to share     enterleave
#img cover/frame to share  enterleave
#img frames to share       return

importx "getenv" getenv

import "init_dir" init_dir
import "dirch" dirch

#e
function move_to_folder(sd f)
	sd change
	setcall change chd(f)
	if change!=0
		return "Change dir error at init."
	endif
	return (noerror)
endfunction
#e
function move_to_home()
	sd f
	sd er
	setcall er home_folder(#f,(NULL))
	if er=(noerror)
		setcall er init_dir(f)
		if er=(noerror)
			setcall er move_to_folder(f)
		endif
	endif
	return er
endfunction
function move_to_home_v()
	sd f
	setcall f home_folder_r((NULL))
	if f!=(NULL)
		call dirch(f)
	endif
endfunction
function move_to_home_core(sv p)
	sv mem
	setcall mem home_folder_function()
	set mem mem#
	if mem!=(NULL)
		sd f
		sd h
		setcall f home_folder_r(#h)
		if f!=(NULL)
			sd b
			setcall b cat_absolute_verif(mem,h,f,p#)
			if b=(TRUE)
				set p# mem
			endif
		endif
	endif
endfunction
function move_to_share_v()
	sd f
	sd err
	setcall f share_folder(#err,(NULL))
	if err=(noerror)
		call dirch(f)
	endif
endfunction
function move_to_share_core(sv p)
	sv mem
	setcall mem share_folder_function()
	set mem mem#
	if mem!=(NULL)
		sd f
		sd err
		ss prefix=""
		setcall f share_folder(#err,#prefix)
		if err=(noerror)
			sd b
			setcall b cat_absolute_verif(mem,prefix,f,p#)
			if b=(TRUE)
				set p# mem
			endif
		endif
	endif
endfunction
importx "access" access
#er
function uninit_start()
	sd f
	sd er
	setcall er home_folder(#f,(NULL))
	if er=(noerror)
		sd a;setcall a access(f,(F_OK))
		if a=0
			setcall er move_to_folder(f)
		else
			return (error)
		endelse
	endif
	return er
endfunction
#path
function real_path(sd p)
importx "realpath" realpath
	sd mem;setcall mem realpath(p,(NULL))
	return mem
endfunction

#e
function home_folder(sv pf,sv ph)
	ss envpath
	setcall envpath getenv("HOME")
	if envpath!=(NULL)
		vstr a="ovideo"
		if ph=(NULL)
			sd err
			setcall err move_to_folder(envpath)
			if err!=(noerror)
				return err
			endif
			set pf# a
		else
			set ph# envpath
			set pf# a
		endelse
		return (noerror)
	endif
	return "Getenv error at home folder."
endfunction
#string/0
function home_folder_r(sd p)
	sd er
	sd f
	setcall er home_folder(#f,p)
	if er=(noerror)
		return f
	endif
	call texter(er)
	return (NULL)
endfunction

importx "strcmp" strcmp
function init_args(sd argc,sv argv)
	#needed quick at regforkok for fedora
	call prog_init()

	value shareprefix#1
	const shareprefix_p^shareprefix
	if argc<2
		set shareprefix (NULL)
		return (FALSE)
	endif
	add argv :
	sd cmp
	setcall cmp strcmp(argv#,"d")
	if cmp!=0
		setcall cmp strcmp(argv#,"--help")
		if cmp=0
			call puts("ovideo --help              This help
ovideo --remove-config     Remove configuration files
ovideo PATH_NAME           PATH_NAME=\"path to share folder\"
ovideo d PATH_NAME         same")
			return (FALSE)
		endif
		setcall cmp strcmp(argv#,"--remove-config")
		if cmp=0
			sd er;setcall er uninit_start()
			if er=(noerror)
				import "uninit_print" uninit_print
				import "uninit_print_entry" uninit_print_entry
				sv c;sv s;setcall s uninit_print(#c)
				vstr current_folder="."
				call uninit_print_entry(current_folder)
				import "uninit_decision" uninit_decision
				sd b;setcall b uninit_decision()
				if b=(TRUE)
					import "uninit_delete" uninit_delete
					call uninit_delete(s,c)
					import "uninit_delete_folder" uninit_delete_folder
					call uninit_delete_folder(current_folder)
				endif
			endif
			return (FALSE)
		endif
	else
	#share folder can be a reserved word. example: --help
		if argc=2
			call puts("Missing PATH_NAME")
			return (FALSE)
		endif
		add argv :
	endelse
	set shareprefix argv#
	return (TRUE)
endfunction
#string
function share_folder(sv p_err,sv prefix)
	value a%shareprefix_p
	if a#=(NULL)
		set p_err# (noerror)
		include "share.txt"
	endif
	if prefix=(NULL)
		setcall p_err# move_to_folder(a#)
	else
		set prefix# a#
		set p_err# (noerror)
	endelse
	return #prestart
endfunction

const PATH_MAX=4096
importx "malloc" malloc
importx "free" free
importx "strlen" strlen
importx "sprintf" sprintf
importx "puts" puts

function prog_init()
	sv a
	setcall a home_folder_function()
	set a# (NULL)
	sv b
	setcall b share_folder_function()
	set b# (NULL)
	vstr s="malloc error."
	sd c
	setcall c malloc((PATH_MAX))
	if c!=(NULL)
		set a# c
		setcall c malloc((PATH_MAX))
		if c!=(NULL)
			set b# c
			return (void)
		endif
	endif
	call puts(s)
endfunction
function prog_free()
	sv a
	setcall a home_folder_function()
	if a#!=(NULL)
		call free(a#)
		setcall a share_folder_function()
		if a#!=(NULL)
			call free(a#)
		endif
	endif
endfunction

function home_folder_function()
	value p#1
	return #p
endfunction
function share_folder_function()
	value p#1
	return #p
endfunction

function cat_absolute_verif(sd mem,sd v,sd v2,sd v3)
	sd s
	setcall s strlen(v)
	inc s
	addcall s strlen(v2)
	inc s
	addcall s strlen(v3)
	if s<(PATH_MAX)
		sd n
		setcall n sprintf(mem,"%s/%s",v,v2)
		add mem n
		call sprintf(mem,"/%s",v3)
		return (TRUE)
	endif
	call texter("path max error.")
	return (FALSE)
endfunction


function ulltoa(sd low,sd high,sd str)
	call sprintf(str,"%llu",low,high)
endfunction


importx "gdk_x11_drawable_get_xid" gdk_x11_drawable_get_xid
importx "gst_video_overlay_get_type" gst_video_overlay_get_type
importx "g_type_check_instance_cast" g_type_check_instance_cast
importx "gst_video_overlay_set_window_handle" gst_video_overlay_set_window_handle

import "getplaybin2ptr" getplaybin2ptr
import "widget_gdk_window_native_get" widget_gdk_window_native_get

function video_realize(sd widget)
	sd window
	setcall window widget_gdk_window_native_get(widget)
	if window!=(NULL)
		sd windraw
		setcall windraw gdk_x11_drawable_get_xid(window)

		sd g_type
		setcall g_type gst_video_overlay_get_type()

		sv playbin2
		setcall playbin2 getplaybin2ptr()
		set playbin2 playbin2#

		sd c_type
		setcall c_type g_type_check_instance_cast(playbin2,g_type)

		call gst_video_overlay_set_window_handle(c_type,windraw)
	endif
endfunction


#1.0 function
function get_new_buffer(sd mem,sd framesize)
	importx "gst_buffer_new_wrapped" gst_buffer_new_wrapped
	#const GST_MEMORY_FLAG_READONLY=2
	sd buffer
	#setcall buffer gst_buffer_new_wrapped_full(0,mem,framesize,0,framesize,(NULL),(NULL)) #The memory will be freed with g_free and will be marked writable.
	setcall buffer gst_buffer_new_wrapped(mem,framesize)
	sd timestamp;set timestamp buffer
	#go to pts member from GstBuffer
	#cannot be GST_CLOCK_TIME_NONE_lowhigh
	add timestamp 40;set timestamp# 0;add timestamp (DWORD);set timestamp# 0
	return buffer
endfunction

function get_playbin_str()
	return "playbin"
endfunction

function get_mxf_caps()
	import "stage_nthwidgetFromcontainer" stage_nthwidgetFromcontainer
	import "stage_file_frame_main_set" stage_file_frame_main_set
    sd firstframe
    setcall firstframe stage_nthwidgetFromcontainer(0)
    sd pixbuf
    sd w
    sd h
    sd ptr_pack^pixbuf
    call stage_file_frame_main_set(ptr_pack,firstframe)
	ss capsformat="caps=video/x-raw,format=(string)RGBA,width=%u,height=%u,bpp=%u,endianness=4321,red_mask=0xFF000000,green_mask=0xFF0000,blue_mask=0xFF00,framerate=%u/1"
	char capsdata#4*10+150+1-4-4
	str gstcaps^capsdata
	sd bpp=stage_bpp
	sd fps
	import "stage_file_options_fps" stage_file_options_fps
	setcall fps stage_file_options_fps()
	call sprintf(gstcaps,capsformat,w,h,bpp,fps)
	return gstcaps
endfunction

function get_mxf_inputformat()
	return "videoconvert"
endfunction

function get_decodebin_str()
	return "decodebin"
endfunction

importx "gst_iterator_next" gst_iterator_next
importx "g_value_get_object" g_value_get_object
importx "g_value_unset" g_value_unset
function iterate_next_forward_free(sd iter,sv forward)
	#gvalue = one GType ul(QWORD) and two pointers
	const gvalue_stacks=:&DWORD/DWORD*3+3
	sd elem#gvalue_stacks
	sd ptr_elem^elem
	const gvalue_sz=gvalue_stacks*:
	call setmemzero(ptr_elem,(gvalue_sz)) #this is G_VALUE_INIT,elem must have been initialized to the type of the iterator or initialized to zeroes
	sd ret
	setcall ret gst_iterator_next(iter,ptr_elem)
	if ret=(GST_ITERATOR_OK)
		sd obj
		setcall obj g_value_get_object(ptr_elem)
		call forward(obj)
		call g_value_unset(ptr_elem)
		return (void)
	endif
	call texter("Iterator error")
endfunction

function stage_sound_caps()
	char out#65-2-2+(dword_max*2)+1
	vstr format="audio/x-raw,format=S16LE,channels=%u,rate=%u,signed=(boolean)true"
	sd channels
	setcall channels stage_sound_channels((value_get))
	sd rate
	setcall rate stage_sound_rate((value_get))
	call sprintf(#out,format,channels,rate)
	return #out
endfunction

function stage_sound_sample(sd appsink)
	#new buffer signal
	import "connect_signal" connect_signal
	call connect_signal(appsink,"new-sample",stage_sound_buffer)
endfunction
#flow
function stage_sound_buffer(sd gstappsink,sd *user_data)
	#call sleepMs(5000)
	sd ret
	importx "gst_app_sink_pull_sample" gst_app_sink_pull_sample
	sd s
	setcall s gst_app_sink_pull_sample(gstappsink)
	importx "gst_sample_get_buffer" gst_sample_get_buffer
	sd b
	setcall b gst_sample_get_buffer(s)
	importx "gst_buffer_map" gst_buffer_map
	sd map#13 #with sizeof
	const GST_MAP_READ=1
	sd bool
	setcall bool gst_buffer_map(b,#map,(GST_MAP_READ)) #this is bool, but
	if bool=(TRUE)
		import "stage_sound_expand" stage_sound_expand
		call stage_sound_expand(#map,(2*:),(3*:))
		importx "gst_buffer_unmap" gst_buffer_unmap
		call gst_buffer_unmap(b,#map)
		set ret (GST_FLOW_OK)
	else
		const GST_FLOW_ERROR=-5
		set ret (GST_FLOW_ERROR)
		call texter("Failed to map buffer")
	endelse
	importx "gst_mini_object_unref" gst_mini_object_unref
	call gst_mini_object_unref(s)
	return ret
endfunction
