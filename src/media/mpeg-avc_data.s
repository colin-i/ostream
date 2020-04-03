

format elfobj

include "../_include/include.h"

const X264_SCAN8_SIZE=6*8

function avc_pre_input(sd action,sd value)
    data mem#1
    if action==(value_set)
        set mem value
    else
        return mem
    endelse
endfunction
function avc_input(sd action,sd value)
    data mem#1
    if action==(value_set)
        set mem value
    else
        return mem
    endelse
endfunction
function avc_input_dequant(sd action,sd value)
    data mem#1
    if action==(value_set)
        set mem value
    else
        return mem
    endelse
endfunction
function avc_output(sd action,sd value)
    data mem#1
    if action==(value_set)
        set mem value
    else
        return mem
    endelse
endfunction
function avc_output_size(sd action,sd value)
    data size#1
    if action==(value_set)
        set size value
    else
        return size
    endelse
endfunction
function avc_allsize(sd action,sd value)
    data allsize#1
    if action==(value_set)
        set allsize value
    else
        return allsize
    endelse
endfunction
function avc_output_pos(sd action,sd value)
    data pos#1
    if action==(value_set)
        set pos value
    else
        return pos
    endelse
endfunction
function avc_nal_output(sd action,sd value)
    data mem#1
    if action==(value_set)
        set mem value
    else
        return mem
    endelse
endfunction

#cabac bs

function avc_cabac_range(sd way,sd value)
    data range#1
    if way==(value_set)
        set range value
    else
        return range
    endelse
endfunction
function avc_cabac_low(sd way,sd value)
    data range#1
    if way==(value_set)
        set range value
    else
        return range
    endelse
endfunction
function avc_cabac_sym_cnt(sd way,sd value)
    data sym_cnt#1
    if way==(value_set)
        set sym_cnt value
    else
        return sym_cnt
    endelse
endfunction
function avc_cabac_bits_outstanding(sd way,sd value)
    data bits_outstanding#1
    if way==(value_set)
        set bits_outstanding value
    else
        return bits_outstanding
    endelse
endfunction
function avc_cabac_first_bit(sd way,sd value)
    data first_bit#1
    if way==(value_set)
        set first_bit value
    else
        return first_bit
    endelse
endfunction

function avc_mb_nr_left(sd way,sd value)
    data nr_left#1
    if way==(value_set)
        set nr_left value
    else
        return nr_left
    endelse
endfunction
function avc_mb_nr_top(sd way,sd value)
    data nr_top#1
    if way==(value_set)
        set nr_top value
    else
        return nr_top
    endelse
endfunction
function avc_mb_width(sd action,sd value)
    data mb_width#1
    if action==(value_set)
        set mb_width value
    else
        return mb_width
    endelse
endfunction
function avc_mb_height(sd action,sd value)
    data mb_height#1
    if action==(value_set)
        set mb_height value
    else
        return mb_height
    endelse
endfunction
function avc_width(sd action,sd value)
    data width#1
    if action==(value_set)
        set width value
    else
        return width
    endelse
endfunction
function avc_height(sd action,sd value)
    data height#1
    if action==(value_set)
        set height value
    else
        return height
    endelse
endfunction
#
function avc_cbp_luma(sd way,sd value)
    data cbp_luma#1
    if way==(value_set)
        set cbp_luma value
    else
        return cbp_luma
    endelse
endfunction
function avc_cbp_chroma(sd way,sd value)
    data cbp_chroma#1
    if way==(value_set)
        set cbp_chroma value
    else
        return cbp_chroma
    endelse
endfunction
#
function avc_ProfileIndication(sd action,sd value)
    data ProfileIndication#1
    if action==(value_set)
        set ProfileIndication value
    else
        return ProfileIndication
    endelse
endfunction
function avc_profile_compatibility(sd action,sd value)
    data profile_compatibility#1
    if action==(value_set)
        set profile_compatibility value
    else
        return profile_compatibility
    endelse
endfunction
function avc_LevelIndication(sd action,sd value)
    data LevelIndication#1
    if action==(value_set)
        set LevelIndication value
    else
        return LevelIndication
    endelse
endfunction

function avc_dct_sub_pred_index(sd way,sd value)
    data pred_index#1
    if way==(value_set)
        set pred_index value
    else
        return pred_index
    endelse
endfunction

function avc_frame_num(sd way,sd value)
    data frame_num#1
    if way==(value_set)
        set frame_num value
    else
        return frame_num
    endelse
endfunction
function avc_log2_max_frame_num(sd way,sd value)
    data log2_max_frame_num#1
    if way==(value_set)
        set log2_max_frame_num value
    else
        return log2_max_frame_num
    endelse
endfunction
function avc_idr_pic_id(sd way,sd value)
    data idr_pic_id#1
    if way==(value_set)
        set idr_pic_id value
    else
        return idr_pic_id
    endelse
endfunction
function avc_log2_max_poc_lsb(sd way,sd value)
    data log2_max_poc_lsb#1
    if way==(value_set)
        set log2_max_poc_lsb value
    else
        return log2_max_poc_lsb
    endelse
endfunction

function avc_qp_I()
    #i_qp_constant=26
    #f_ip_factor = 1.4
    #x264_clip3( (int)( qscale2qp( qp2qscale( h->param.rc.i_qp_constant ) / fabs( h->param.rc.f_ip_factor )) + 0.5 ), 0, 51 )
    #0x17
    return 0x17
endfunction

function avc_slice_type(sd way,sd value)
    data slice_type#1
    if way==(value_set)
        set slice_type value
    else
        return slice_type
    endelse
endfunction

#cabac state

function avc_cabac_ctxstate()
    data ctxstate#avc_ctxstate_total*avc_ctxstate_size
    #int i_state;
    #int i_mps;
    #int i_count;
    data c_ctxstate^ctxstate
    return c_ctxstate
endfunction
function avc_cabac_ctxstate_value_get(sd i,sd item)
    mult i (avc_ctxstate_size)
    add i item
    mult i 4
    addcall i avc_cabac_ctxstate()
    return i
endfunction
function avc_cabac_ctxstate_value(sd i,sd item)
    setcall i avc_cabac_ctxstate_value_get(i,item)
    return i#
endfunction
function avc_cabac_ctxstate_value_set(sd i,sd item,sd value)
    setcall i avc_cabac_ctxstate_value_get(i,item)
    set i# value
endfunction

#

#luma ac
function avc_residual_ac()
    data residual_ac_data#16*15
    data residual_ac^residual_ac_data
    return residual_ac
endfunction
#luma dc
function avc_residual_luma()
    data residual_luma_data#1*16
    data res^residual_luma_data
    return res
endfunction
#chroma ac
function avc_residual_ac_ch()
    data residual_ac_ch_data#8*15
    data residual_ac_ch^residual_ac_ch_data
    return residual_ac_ch
endfunction
function avc_residual_ac_u()
    sd residual_ac_u
    setcall residual_ac_u avc_residual_ac_ch()
    return residual_ac_u
endfunction
function avc_residual_ac_v()
    sd residual_ac_v
    setcall residual_ac_v avc_residual_ac_ch()
    add residual_ac_v (4*15*DWORD)
    return residual_ac_v
endfunction
#chroma dc
function avc_chroma_dc()
    data chroma_dc_data#2*4
    data chroma_dc^chroma_dc_data
    return chroma_dc
endfunction
function avc_chroma_dc_u()
    sd res
    setcall res avc_chroma_dc()
    return res
endfunction
function avc_chroma_dc_v()
    sd res
    setcall res avc_chroma_dc()
    add res (4*DWORD)
    return res
endfunction

function avc_mb_non_zero(sd way,sd index,sd value)
    data non_zero#X264_SCAN8_SIZE
    sd non_zero_count^non_zero
    mult index (DWORD)
    add non_zero_count index
    if way==(value_set)
        set non_zero_count# value
    else
        return non_zero_count#
    endelse
endfunction

function avc_mb_data(sd way,sd arg,sd x,sd y,sd value,sd opt)
    data mem#1
    if way==(value_set)
        set mem arg
    elseif way==(value_get)
        return mem
    else
        sd item
        set item mem
        sd item_value
        sd mb_stride
        setcall mb_stride avc_mb_width((value_get))
        mult y mb_stride
        set item_value y
        add item_value x
        mult item_value (avc_mb_size)
        add item_value arg
        add item item_value
        if arg==(avc_mb_cache_offset)
            mult value (DWORD)
            add item value
            if way==(value_write)
                set value opt
            endif
        endif
        if way==(value_write)
            set item# value
        else
            return item#
        endelse
    endelse
endfunction
