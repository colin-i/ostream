
format elfobj

include "../_include/include.h"

function mp4_sizes(sd way,sd arg)
    data w#1
    data h#1
    data wh^w
    if way==(value_set)
        import "pixbuf_get_wh" pixbuf_get_wh
        call pixbuf_get_wh(arg,wh)
    else
        set arg# w
        add arg 4
        set arg# h
    endelse
endfunction

#208284480
const GF_ISOM_MAC_TIME_OFFSET=2082758400
import "dword_reverse" dword_reverse

function mp4_times(sd way,sd p_time)
    import "timeNode" time
    data f_time#1
    if way==(value_set)
        setcall f_time time(0)
        add f_time (GF_ISOM_MAC_TIME_OFFSET)
        setcall f_time dword_reverse(f_time)
    else
        set p_time# f_time
        add p_time 4
        set p_time# f_time
    endelse
endfunction

import "stage_file_options_fps" stage_file_options_fps
import "rule3" rule3

function mp4_tscale()
    #600 is our default movie TimeScale
    data t=600
    return t
endfunction
function mp4_duration(sd way)
    data duration#1
    if way==(value_set)
        sd dur
        setcall dur mp4_SampleCount((value_get))
        sd timescale
        setcall timescale mp4_tscale((value_get))
        sd fps
        setcall fps stage_file_options_fps()
        setcall duration rule3(dur,fps,timescale)
    else
        return duration
    endelse
endfunction

function mp4_timescale(sd way)
    data timescale#1
    if way==(value_set)
        sd fps_1000
        setcall fps_1000 stage_file_options_fps()
        #u32 fps_1000 = (u32) (fps*+ 0.5);
        mult fps_1000 1000
        if fps_1000==29970
            set timescale 30000
        elseif fps_1000==23976
            set timescale 24000
        elseif fps_1000==59940
            set timescale 60000
        else
            set timescale fps_1000
        endelse
    else
        return timescale
    endelse
endfunction
function mp4_duration_1000(sd way)
    data duration#1
    if way==(value_set)
        sd dur
        setcall dur mp4_SampleCount((value_get))
        sd ts
        setcall ts mp4_timescale((value_get))
        sd fps
        setcall fps stage_file_options_fps()
        setcall duration rule3(dur,fps,ts)
    else
        return duration
    endelse
endfunction


#function mp4_AVCProfileIndication(sd way,sd value)
#    data AVCProfileIndication#1
#    if way==(value_set)
#        set AVCProfileIndication value
#    else
#        return AVCProfileIndication
#    endelse
#endfunction
#function mp4_profile_compatibility(sd way,sd value)
#    data profile_compatibility#1
#    if way==(value_set)
#        set profile_compatibility value
#    else
#        return profile_compatibility
#    endelse
#endfunction
#function mp4_AVCLevelIndication(sd way,sd value)
#    data AVCLevelIndication#1
#    if way==(value_set)
#        set AVCLevelIndication value
#    else
#        return AVCLevelIndication
#    endelse
#endfunction

function mp4_SampleCount(sd way)
    data SampleCount#1
    if way==(value_set)
        import "stage_frame_time_numbers" stage_frame_time_numbers
        setcall SampleCount stage_frame_time_numbers((stage_frame_time_total_sum))
        addcall SampleCount mp4_video_samples_get()
    else
        return SampleCount
    endelse
endfunction
function mp4_samplesOffset(sd way,sd value)
    data samplesOffset#1
    if way==(value_set)
        set samplesOffset value
    else
        return samplesOffset
    endelse
endfunction
function mp4_bufferSzOffset(sd way,sd value)
    data bufferSzOffset#1
    if way==(value_set)
        set bufferSzOffset value
    else
        return bufferSzOffset
    endelse
endfunction
function mp4_avgbitrateOffset(sd way,sd value)
    data avgbitrateOffset#1
    if way==(value_set)
        set avgbitrateOffset value
    else
        return avgbitrateOffset
    endelse
endfunction
function mp4_chunksOffset(sd way,sd value)
    data chunkOffsets#1
    if way==(value_set)
        set chunkOffsets value
    else
        return chunkOffsets
    endelse
endfunction

#

function mp4_longest_duration()
    data longest_duration#1
    data p^longest_duration
    return p
endfunction

function mp4_next_track()
    data next_track#1
    data p^next_track
    return p
endfunction
function mp4_next_track_set(sd value)
    sd nt
    setcall nt mp4_next_track()
    set nt# value
endfunction

function mp4_audio_profile()
    data profile#1
    data p^profile
    return p
endfunction
function mp4_audio_profile_set(sd value)
    sd profile
    setcall profile mp4_audio_profile()
    set profile# value
endfunction
#

#sound

function mp4_all_samples()
    data nr#1
    data p^nr
    return p
endfunction

function mp4_sound_duration()
    data duration#1
    data p^duration
    return p
endfunction

function mp4_sample_count()
    data sample_count#1
    data p^sample_count
    return p
endfunction

function mp4_entrysize_offset()
    data offset#1
    data p^offset
    return p
endfunction

function mp4_chunkoff()
    data offset#1
    data p^offset
    return p
endfunction


########expand

function mp4_sound_presence()
    data sound_presence#1
    return #sound_presence
endfunction
function mp4_sound_presence_get()
    sd x
    setcall x mp4_sound_presence()
    return x#
endfunction
#
function mp4_write_expand()
    data write_expand#1
    return #write_expand
endfunction
function mp4_write_expand_set(sd value)
    sd x
    setcall x mp4_write_expand()
    set x# value
endfunction
function mp4_write_expand_get()
    sd x
    setcall x mp4_write_expand()
    return x#
endfunction
#
function mp4_expand_startfile()
    data startfile#1
    return #startfile
endfunction
function mp4_expand_startfile_set(sd value)
    sd x
    setcall x mp4_expand_startfile()
    set x# value
endfunction
function mp4_expand_startfile_get()
    sd x
    setcall x mp4_expand_startfile()
    return x#
endfunction
#
function mp4_info()
    data info#1
    return #info
endfunction
function mp4_info_set(sd value)
    sd x
    setcall x mp4_info()
    set x# value
endfunction
function mp4_info_get()
    sd x
    setcall x mp4_info()
    return x#
endfunction

#

function mp4_video_samples()
    data video_samples#1
    return #video_samples
endfunction
function mp4_video_samples_set(sd value)
    sd x
    setcall x mp4_video_samples()
    set x# value
endfunction
function mp4_video_samples_get()
    sd x
    setcall x mp4_video_samples()
    return x#
endfunction
#
function mp4_video_bufferSz()
    data bufferSz#1
    return #bufferSz
endfunction
function mp4_video_bufferSz_set(sd value)
    sd x
    setcall x mp4_video_bufferSz()
    set x# value
endfunction
function mp4_video_bufferSz_get()
    sd x
    setcall x mp4_video_bufferSz()
    return x#
endfunction
#
function mp4_video_offset()
    data video#1
    return #video
endfunction
function mp4_video_offset_set(sd value)
    sd x
    setcall x mp4_video_offset()
    set x# value
endfunction
function mp4_video_offset_get()
    sd x
    setcall x mp4_video_offset()
    return x#
endfunction

#

function mp4_audio_samples()
    data audio_samples#1
    return #audio_samples
endfunction
function mp4_audio_samples_set(sd value)
    sd x
    setcall x mp4_audio_samples()
    set x# value
endfunction
function mp4_audio_samples_get()
    sd x
    setcall x mp4_audio_samples()
    return x#
endfunction
#
function mp4_audio_bufferSz()
    data bufferSz#1
    return #bufferSz
endfunction
function mp4_audio_bufferSz_set(sd value)
    sd x
    setcall x mp4_audio_bufferSz()
    set x# value
endfunction
function mp4_audio_bufferSz_get()
    sd x
    setcall x mp4_audio_bufferSz()
    return x#
endfunction
#
function mp4_audio_maxBitrate()
    data maxBitrate#1
    return #maxBitrate
endfunction
function mp4_audio_maxBitrate_set(sd value)
    sd x
    setcall x mp4_audio_maxBitrate()
    set x# value
endfunction
function mp4_audio_maxBitrate_get()
    sd x
    setcall x mp4_audio_maxBitrate()
    return x#
endfunction
#
function mp4_audio_offset()
    data offset#1
    return #offset
endfunction
function mp4_audio_offset_set(sd value)
    sd x
    setcall x mp4_audio_offset()
    set x# value
endfunction
function mp4_audio_offset_get()
    sd x
    setcall x mp4_audio_offset()
    return x#
endfunction
