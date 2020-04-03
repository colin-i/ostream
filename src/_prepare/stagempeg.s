
##mpeg for stage

format elfobj

include "../_include/include.h"

##encode

#bool
function stage_mpeg_init(sd file)
    import "av_frames" av_frames
    sd pixbuf
    setcall pixbuf av_frames((get_buffer))

    import "stage_get_frames" stage_get_frames
    sd totalframes
    setcall totalframes stage_get_frames()

    import "mpeg_init" mpeg_init
    sd bool
    setcall bool mpeg_init(file,pixbuf,totalframes)
    return bool
endfunction

#bool
function stage_mpeg_encode(sd pixbuf,sd currentframe,sd p_is_keyframe)
    import "stage_frame_time_numbers" stage_frame_time_numbers
    sd position
    setcall position stage_frame_time_numbers((stage_frame_time_sum_at_index),currentframe)

    import "mpeg_encode" mpeg_encode
    sd bool
    setcall bool mpeg_encode(pixbuf,position,p_is_keyframe)
    return bool
endfunction


##decode
