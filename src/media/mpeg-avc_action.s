


format elfobj

include "../_include/include.h"

import "array_get_int" array_get_int
import "get_lower" get_lower
import "shl" shl
import "sar32" sar
import "avc_cabac_bypass" avc_cabac_bypass

function avc_residual_write(sd residual,sd ctxBlockCat,sd count,sd idx)
    sd coeff=0
    sd value
    sd array
    sd last=0
    data coeff_abs_m1_data#64
    data i_coeff_abs_m1^coeff_abs_m1_data
    data coeff_sign_data#64
    data i_coeff_sign^coeff_sign_data

    sd coeff_abs_m1^coeff_abs_m1_data
    sd coeff_sign^coeff_sign_data
    set array residual
    sd i=0
    while i!=count
        set value array#
        if value!=0
            set coeff_abs_m1# value
            if value<0
                mult coeff_abs_m1# -1
            endif
            dec coeff_abs_m1#
            if value<0
                set coeff_sign# 1
            else
                set coeff_sign# 0
            endelse

            add coeff_sign (DWORD)
            add coeff_abs_m1 (DWORD)
            inc coeff
            set last i
        endif
        add array (DWORD)
        inc i
    endwhile

    #if count!=64
    set value 85
    addcall value avc_cabac_mb_cbf_ctxidxinc(ctxBlockCat,idx)
    sd b
    if coeff!=0
        set b 1
    else
        set b 0
    endelse
    import "avc_cabac_decision" avc_cabac_decision
    call avc_cabac_decision(value,b)
    if coeff==0
        return 0
    endif

    sd index
    set index count
    dec index
    set array residual
    set i 0
    while i!=index
        sd sig_ctx
        sd last_ctx
        if ctxBlockCat==5
            setcall sig_ctx avc_significant_coeff_flag_offset_8x8(i)
            setcall last_ctx avc_last_significant_coeff_flag_offset_8x8(i)
        else
            set sig_ctx i
            set last_ctx i
        endelse
        if array#!=0
            setcall value avc_significant_coeff_flag_offset(ctxBlockCat)
            add value sig_ctx
            add value 105
            call avc_cabac_decision(value,1)
            setcall value avc_last_significant_coeff_flag_offset(ctxBlockCat)
            add value last_ctx
            add value 166
            if i==last
                call avc_cabac_decision(value,1)
            else
                call avc_cabac_decision(value,0)
            endelse
        else
            setcall value avc_significant_coeff_flag_offset(ctxBlockCat)
            add value sig_ctx
            add value 105
            call avc_cabac_decision(value,0)
        endelse
        if i==last
            set i index
        else
            add array (DWORD)
            inc i
        endelse
    endwhile

    sd abslevelgt1=0
    sd abslevel1=0
    set i coeff
    dec i
    while i>=0
        sd ctxIdxInc
        sd abs_m1
        setcall abs_m1 array_get_int(i_coeff_abs_m1,i)

        sd prefix
        set prefix abs_m1
        if prefix>14
            set prefix 14
        endif
        if abslevelgt1!=0
            set ctxIdxInc 0
        else
            set value abslevel1
            inc value
            setcall ctxIdxInc get_lower(4,value)
        endelse
        addcall ctxIdxInc avc_coeff_abs_level_m1_offset(ctxBlockCat)
        sd ctx
        set ctx ctxIdxInc
        add ctx 227
        if prefix==0
            call avc_cabac_decision(ctx,0)
        else
            call avc_cabac_decision(ctx,1)
            set ctxIdxInc 5
            addcall ctxIdxInc get_lower(4,abslevelgt1)
            addcall ctxIdxInc avc_coeff_abs_level_m1_offset(ctxBlockCat)
            set ctx ctxIdxInc
            add ctx 227
            sd j=0
            sd max
            set max prefix
            dec max
            while j!=max
                call avc_cabac_decision(ctx,1)
                inc j
            endwhile
            if prefix<14
                call avc_cabac_decision(ctx,0)
            endif
        endelse

        sd sufix
        if abs_m1>=14
            sd k=0
            set sufix abs_m1
            sub sufix 14
            sd loop=1
            while loop==1
                setcall value shl(1,k)
                if sufix>=value
                    call avc_cabac_bypass(1)
                    sub sufix value
                    inc k
                else
                    set loop 0
                endelse
            endwhile
            call avc_cabac_bypass(0)
            while k!=0
                dec k
                setcall value sar(sufix,k)
                and value 1
                call avc_cabac_bypass(value)
            endwhile
        endif

        #write sign
        setcall value array_get_int(i_coeff_sign,i)

        call avc_cabac_bypass(value)
        if abs_m1==0
            inc abslevel1
        else
            inc abslevelgt1
        endelse
        dec i
    endwhile
endfunction

function avc_significant_coeff_flag_offset_8x8(sd i)
    #[63]
    data flag_offset={0, 1, 2, 3, 4, 5, 5, 4, 4, 3, 3, 4, 4, 4, 5, 5}
    data *          ={4, 4, 4, 4, 3, 3, 6, 7, 7, 7, 8, 9,10, 9, 8, 7}
    data *          ={7, 6,11,12,13,11, 6, 7, 8, 9,14,10, 9, 8, 6,11}
    data *          ={12,13,11, 6, 9,14,10, 9,11,12,13,11,14,10,12}
    sd offset^flag_offset
    mult i 4
    add offset i
    return offset#
endfunction
function avc_last_significant_coeff_flag_offset_8x8(sd i)
    #[63]
    data flag_offset={0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}
    data *          ={2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2}
    data *          ={3, 3, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4}
    data *          ={5, 5, 5, 5, 6, 6, 6, 6, 7, 7, 7, 7, 8, 8, 8}
    sd offset^flag_offset
    mult i 4
    add offset i
    return offset#
endfunction
function avc_coeff_abs_level_m1_offset(sd i)
    #[6]
    data m1_offset={0, 10, 20, 30, 39, 199}
    sd offset^m1_offset
    mult i 4
    add offset i
    return offset#
endfunction
function avc_significant_coeff_flag_offset(sd i)
    #[6]
    data s_offset={0, 15, 29, 44, 47, 297}
    sd offset^s_offset
    mult i 4
    add offset i
    return offset#
endfunction
function avc_last_significant_coeff_flag_offset(sd i)
    #[6]
    data l_offset={0, 15, 29, 44, 47, 251}
    sd offset^l_offset
    mult i 4
    add offset i
    return offset#
endfunction

#return ctxidxinc
function avc_cabac_mb_cbf_ctxidxinc(sd ctxBlockCat,sd idx)
    sd mba_xy=-1
    sd mbb_xy=-1
    sd nza=-1
    sd nzb=-1
    sd ctx=0
    sd left_nr
    sd top_nr
    sd left
    sd top
    sd mb_stride
    sd type
    sd value
    import "avc_mb_nr_left" avc_mb_nr_left
    import "avc_mb_nr_top" avc_mb_nr_top
    import "avc_mb_width" avc_mb_width
    import "avc_mb_data" avc_mb_data
    setcall left_nr avc_mb_nr_left((value_get))
    setcall top_nr avc_mb_nr_top((value_get))
    setcall mb_stride avc_mb_width((value_get))
    import "avc_block_idx_x" avc_block_idx_x
    import "avc_block_idx_y" avc_block_idx_y
    import "avc_block_idx_xy" avc_block_idx_xy
    import "avc_mb_non_zero" avc_mb_non_zero
    sd x
    sd y
    sd i8x8a
    sd i8x8b
    sd idx_x
    sd idx_y
    sd cbp
    if ctxBlockCat==0
        if left_nr>0
            #i_mba_xy = h->mb.i_mb_xy -1; or not -1
            set mba_xy 0

            set left left_nr
            dec left
            setcall type avc_mb_data((value_item),(avc_mb_type_offset),left,top_nr)
            if type==(avc_I_16x16)
                setcall nza avc_mb_data((value_item),(avc_mb_cbp_offset),left,top_nr)
                and nza 0x100
            endif
        endif
        if top_nr>0
            #i_mbb_xy = h->mb.i_mb_xy - h->mb.i_mb_stride; or not -1
            set mbb_xy 0

            set top top_nr
            dec top
            setcall type avc_mb_data((value_item),(avc_mb_type_offset),left_nr,top)
            if type==(avc_I_16x16)
                setcall nzb avc_mb_data((value_item),(avc_mb_cbp_offset),left_nr,top)
                and nzb 0x100
            endif
        endif
    elseif ctxBlockCat<3
        setcall x avc_block_idx_x(idx)
        setcall y avc_block_idx_y(idx)
        set left left_nr
        if x>0
            set mba_xy 0
        elseif left_nr!=0
            set mba_xy 0
            dec left
        endelseif
        set top top_nr
        if y>0
            set mbb_xy 0
        elseif top_nr!=0
            set mbb_xy 0
            dec top
        endelseif
        if mba_xy!=-1
            set idx_x x
            dec idx_x
            and idx_x 0x03
            setcall i8x8a avc_block_idx_xy(idx_x,y)
            div i8x8a 4
            setcall cbp avc_mb_data((value_item),(avc_mb_cbp_offset),left,top_nr)
            and cbp 0x0f
            setcall cbp sar(cbp,i8x8a)
            if cbp!=0
                setcall nza avc_scan8(idx)
                dec nza
                setcall nza avc_mb_non_zero((value_get),nza)
            endif
        endif
        if mbb_xy!=-1
            set idx_y y
            dec idx_y
            and idx_y 0x03
            setcall i8x8b avc_block_idx_xy(x,idx_y)
            div i8x8b 4
            setcall cbp avc_mb_data((value_item),(avc_mb_cbp_offset),left_nr,top)
            and cbp 0x0f
            setcall cbp sar(cbp,i8x8b)
            if cbp!=0
                setcall nzb avc_scan8(idx)
                sub nzb 8
                setcall nzb avc_mb_non_zero((value_get),nzb)
            endif
        endif
    elseif ctxBlockCat==3
        if left_nr!=0
            set mba_xy 0
            set left left_nr
            dec left
            setcall cbp avc_mb_data((value_item),(avc_mb_cbp_offset),left,top_nr)
            set value cbp
            and value 0x30
            if value!=0
                set value idx
                add value 8
                setcall value shl(0x02,value)
                and cbp value
                set nza cbp
            endif
        endif
        if top_nr!=0
            set mbb_xy 0
            set top top_nr
            dec top
            setcall cbp avc_mb_data((value_item),(avc_mb_cbp_offset),left_nr,top)
            set value cbp
            and value 0x30
            if value!=0
                set value idx
                add value 8
                setcall value shl(0x02,value)
                and cbp value
                set nzb cbp
            endif
        endif
    else
        #if ctxBlockCat==4
        import "rest" rest
        sd idx_c
        setcall idx_c rest(idx,4)

        set left left_nr
        if idx_c==1
            set mba_xy 0
        elseif idx_c==3
            set mba_xy 0
        elseif left_nr!=0
            set mba_xy 0
            dec left
        endelseif

        set top top_nr
        if idx_c==2
            set mbb_xy 0
        elseif idx_c==3
            set mbb_xy 0
        elseif top_nr!=0
            set mbb_xy 0
            dec top
        endelseif

        if mba_xy!=-1
            setcall cbp avc_mb_data((value_item),(avc_mb_cbp_offset),left,top_nr)
            and cbp 0x30
            if cbp==0x20
                set idx_x idx
                add idx_x 16
                setcall nza avc_scan8(idx_x)
                dec nza
                setcall nza avc_mb_non_zero((value_get),nza)
            endif
        endif
        if mbb_xy!=-1
            setcall cbp avc_mb_data((value_item),(avc_mb_cbp_offset),left_nr,top)
            and cbp 0x30
            if cbp==0x20
                set idx_y idx
                add idx_y 16
                setcall nzb avc_scan8(idx_y)
                sub nzb 8
                setcall nzb avc_mb_non_zero((value_get),nzb)
            endif
        endif
    endelse
    sd ctx_add=0
    if mba_xy<0
        set ctx_add 1
    elseif nza>0
        set ctx_add 1
    endelseif
    if ctx_add==1
        inc ctx
    endif
    set ctx_add 0
    if mbb_xy<0
        set ctx_add 1
    elseif nzb>0
        set ctx_add 1
    endelseif
    if ctx_add==1
        add ctx 2
    endif
    set value ctxBlockCat
    mult value 4
    add value ctx
    return value
endfunction

function avc_scan8(sd index)
    data x264_scan8={1*8+4,1*8+5,2*8+4,2*8+5}
    data *              ={1*8+6,1*8+7,2*8+6,2*8+7}
    data *              ={3*8+4,3*8+5,4*8+4,4*8+5}
    data *              ={3*8+6,3*8+7,4*8+6,4*8+7}
    data *Cb            ={1*8+1,1*8+2}
    data *              ={2*8+1,2*8+2}
    data *Cr            ={4*8+1,4*8+2}
    data *              ={5*8+1,5*8+2}
    #   0 1 2 3 4 5 6 7
    # 0
    # 1   B B   L L L L
    # 2   B B   L L L L
    # 3         L L L L
    # 4   R R   L L L L
    # 5   R R

    sd scan8^x264_scan8
    mult index 4
    add scan8 index
    return scan8#
endfunction

function avc_mb_cache_init(sd x,sd y,sd type)
    sd index
    sd i
    sd cache_value
    sd pos

    call avc_mb_data((value_write),(avc_mb_type_offset),x,y,type)

    if type==(avc_P_SKIP)
        call avc_mb_data((value_write),(avc_mb_cbp_offset),x,y,0)
        set i 0
        while i!=(avc_mb_cache_units)
            setcall pos avc_scan8(i)
            call avc_mb_non_zero((value_set),pos,0)
            inc i
        endwhile
        return (void)
    endif

    sd left
    set left x
    dec left
    sd top
    set top y
    dec top

    data prev_top_values={10,11,14,15,16+2,16+3,16+4+2,16+4+3}
    sd prev_top_cache^prev_top_values
    data top_values={0,1,4,5,16+0,16+1,16+4+0,16+4+1}
    sd top_cache^top_values
    set cache_value 0x80
    set i 0
    while i!=8
        setcall index avc_scan8(top_cache#)
        sub index 8

        if y>0
            set pos prev_top_cache#
            add prev_top_cache (DWORD)
            setcall cache_value avc_mb_data((value_item),(avc_mb_cache_offset),x,top,pos)
        endif
        call avc_mb_non_zero((value_set),index,cache_value)

        add top_cache (DWORD)
        inc i
    endwhile

    data prev_left_values={5,7,13,15,16+1,16+3,16+4+1,16+4+3}
    sd prev_left_cache^prev_left_values
    data left_values={0,2,8,10,16+0,16+2,16+4+0,16+4+2}
    sd left_cache^left_values
    set cache_value 0x80
    set i 0
    while i!=8
        setcall index avc_scan8(left_cache#)
        dec index

        if x>0
            set pos prev_left_cache#
            add prev_left_cache (DWORD)
            setcall cache_value avc_mb_data((value_item),(avc_mb_cache_offset),left,y,pos)
        endif
        call avc_mb_non_zero((value_set),index,cache_value)

        add left_cache (DWORD)
        inc i
    endwhile
endfunction

function avc_mb_cache_save(sd x,sd y)
    sd pos
    sd i=0
    while i!=(avc_mb_cache_units)
        setcall pos avc_scan8(i)
        sd nz
        setcall nz avc_mb_non_zero((value_get),pos)
        call avc_mb_data((value_write),(avc_mb_cache_offset),x,y,i,nz)
        inc i
    endwhile
endfunction
