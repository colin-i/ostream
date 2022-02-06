

format elfobj

include "../_include/include.h"

const PROFILE_MAIN=77

import "avc_pre_input" avc_pre_input
import "avc_input" avc_input
import "avc_output" avc_output
import "avc_allsize" avc_allsize
import "avc_nal_output" avc_nal_output
import "avc_mb_data" avc_mb_data
import "avc_input_dequant" avc_input_dequant

import "memalloc" memalloc
importx "_free" free

#bool
function avc_init(sd pixbuf)
    import "pixbuf_get_wh" pixbuf_get_wh
    import "rgb_get_size" rgb_get_size
    sd w
    sd h
    sd wh^w
    call pixbuf_get_wh(pixbuf,wh)
    sd boolSum
    setcall boolSum avc_rounding(w)
    addcall boolSum avc_rounding(h)
    if boolSum!=2
        return 0
    endif

    import "avc_mb_width" avc_mb_width
    import "avc_mb_height" avc_mb_height
    import "avc_width" avc_width
    import "avc_height" avc_height
    sd mb_w
    sd mb_h
    set mb_w w
    set mb_h h
    div mb_w 16
    div mb_h 16
    call avc_mb_width((value_set),mb_w)
    call avc_mb_height((value_set),mb_h)
    call avc_width((value_set),w)
    call avc_height((value_set),h)
    sd alloc_size=1000
    addcall alloc_size rgb_get_size(w,h)
    #call avc_pre_input((value_set),0)
    call avc_input((value_set),0)
    call avc_output((value_set),0)
    call avc_nal_output((value_set),0)
    call avc_mb_data((value_set),0)
    call avc_input_dequant((value_set),0)

    sd mem_pre_in
    setcall mem_pre_in memalloc(alloc_size)
    if mem_pre_in==0
        return 0
    endif
    call avc_pre_input((value_set),mem_pre_in)
    sd mem_in
    setcall mem_in memalloc(alloc_size)
    if mem_in==0
        call avc_free()
        return 0
    endif
    call avc_input((value_set),mem_in)
    sd mem_out
    setcall mem_out memalloc(alloc_size)
    if mem_out==0
        call avc_free()
        return 0
    endif
    call avc_output((value_set),mem_out)
    sd mem_nal_out
    setcall mem_nal_out memalloc(alloc_size)
    if mem_nal_out==0
        call avc_free()
        return 0
    endif
    call avc_nal_output((value_set),mem_nal_out)
    sd mem_mb
    set mem_mb mb_w
    mult mem_mb mb_h
    mult mem_mb (avc_mb_size)
    setcall mem_mb memalloc(mem_mb)
    if mem_mb==0
        call avc_free()
        return 0
    endif
    call avc_mb_data((value_set),mem_mb)
    sd mem_input_deq
    setcall mem_input_deq memalloc(alloc_size)
    if mem_input_deq==0
        call avc_free()
        return 0
    endif
    call avc_input_dequant((value_set),mem_input_deq)
    call avc_allsize((value_set),alloc_size)

    import "avc_ProfileIndication" avc_ProfileIndication
    import "avc_profile_compatibility" avc_profile_compatibility
    import "avc_LevelIndication" avc_LevelIndication
    call avc_ProfileIndication((value_set),(PROFILE_MAIN))
    #b_constraint_set0=0;b_constraint_set1=0;b_constraint_set2=0;5 bits reserved
    call avc_profile_compatibility((value_set),0)
    #level 4.0
    call avc_LevelIndication((value_set),40)

    import "avc_frame_num" avc_frame_num
    import "avc_idr_pic_id" avc_idr_pic_id
    call avc_frame_num((value_set),(avc_keyint_max))
    call avc_idr_pic_id((value_set),-1)

    import "avc_quant_mf_set" avc_quant_mf_set
    call avc_quant_mf_set()

    return 1
endfunction

#bool
function avc_rounding(sd value)
    import "rest" rest
    setcall value rest(value,16)
    if value!=0
        import "texter" texter
        str er="Width or height isn't a multiple of 16."
        call texter(er)
        return 0
    endif
    return 1
endfunction

function avc_free()
    sd mem
    setcall mem avc_pre_input((value_get))
    call free(mem)
    setcall mem avc_input((value_get))
    if mem!=0
        call free(mem)
    endif
    setcall mem avc_output((value_get))
    if mem!=0
        call free(mem)
    endif
    setcall mem avc_nal_output((value_get))
    if mem!=0
        call free(mem)
    endif
    setcall mem avc_mb_data((value_get))
    if mem!=0
        call free(mem)
    endif
    setcall mem avc_input_dequant((value_get))
    if mem!=0
        call free(mem)
    endif
endfunction
