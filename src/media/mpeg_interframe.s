

format elfobj

include "../_include/include.h"

#?_VOP
function me_analyze()
    #at the moment, only P_VOP analyzation is supported
    return (P_VOP)
endfunction

const compare=0
const copy=1

#mode: INTRA=0 or SKIP=1
function mpeg_compare_block(sd mb_x,sd mb_y)
    sd y_current
    sd y_prev
    sd u_current
    sd u_prev
    sd v_current
    sd v_prev

    import "mpeg_input_y" mpeg_input_y
    import "mpeg_input_u" mpeg_input_u
    import "mpeg_input_v" mpeg_input_v
    setcall y_current mpeg_input_y((value_get))
    setcall y_prev mpeg_input_y((value_get_prev))
    setcall u_current mpeg_input_u((value_get))
    setcall u_prev mpeg_input_u((value_get_prev))
    setcall v_current mpeg_input_v((value_get))
    setcall v_prev mpeg_input_v((value_get_prev))

    import "mpeg_input_lumstride" mpeg_input_lumstride
    import "mpeg_input_cromstride" mpeg_input_cromstride
    sd lumstride
    sd cromstride
    setcall lumstride mpeg_input_lumstride((value_get))
    setcall cromstride mpeg_input_cromstride((value_get))

    sd mode
    setcall mode mpeg_block_iteration_compare(y_current,y_prev,u_current,u_prev,v_current,v_prev,lumstride,cromstride,mb_x,mb_y)
    if mode==(INTRA)
        return (INTRA)
    endif

    call mpeg_block_iteration_copy(y_current,y_prev,u_current,u_prev,v_current,v_prev,lumstride,cromstride,mb_x,mb_y)
    return (SKIP)
endfunction

#mode
function mpeg_block_iteration_compare(sd y_current,sd y_prev,sd u_current,sd u_prev,sd v_current,sd v_prev,sd lumstride,sd cromstride,sd mb_x,sd mb_y)
    sd mode
    setcall mode mpeg_block_iteration((compare),y_current,y_prev,lumstride,mb_x,mb_y,16)
    if mode==(INTRA)
        return (INTRA)
    endif
    setcall mode mpeg_block_iteration((compare),u_current,u_prev,cromstride,mb_x,mb_y,8)
    if mode==(INTRA)
        return (INTRA)
    endif
    setcall mode mpeg_block_iteration((compare),v_current,v_prev,cromstride,mb_x,mb_y,8)
    if mode==(INTRA)
        return (INTRA)
    endif
    return (SKIP)
endfunction

function mpeg_block_iteration_copy(sd y_current,sd y_prev,sd u_current,sd u_prev,sd v_current,sd v_prev,sd lumstride,sd cromstride,sd mb_x,sd mb_y)
    call mpeg_block_iteration((copy),y_current,y_prev,lumstride,mb_x,mb_y,16)
    call mpeg_block_iteration((copy),u_current,u_prev,cromstride,mb_x,mb_y,8)
    call mpeg_block_iteration((copy),v_current,v_prev,cromstride,mb_x,mb_y,8)
endfunction

#mode: INTRA or SKIP
function mpeg_block_iteration(sd action,ss current,ss prev,sd stride,sd x,sd y,sd compareunit)
    mult y stride
    mult y compareunit

    mult x compareunit

    add current y
    add current x
    add prev y
    add prev x

    sd group_tol_index=0

    sd current_rowstart
    sd prev_rowstart
    set current_rowstart current
    set prev_rowstart prev

    import "mpeg_single_tolerance" mpeg_single_tolerance
    sd single_tolerance
    setcall single_tolerance mpeg_single_tolerance((value_get))
    import "mpeg_group_tolerance" mpeg_group_tolerance
    sd group_tolerance
    setcall group_tolerance mpeg_group_tolerance((value_get))

    sd j=0
    while j!=compareunit
        sd i=0
        set current current_rowstart
        set prev prev_rowstart
        while i!=compareunit
            if action==(compare)
                sd dif
                set dif current#
                sub dif prev#

                if dif!=0
                    if dif<0
                        mult dif -1
                    endif
                    if dif>single_tolerance
                        inc group_tol_index
                        if group_tol_index>group_tolerance
                            return (INTRA)
                        endif
                    endif
                endif
            else
            #if action==(copy)
                set current# prev#
            endelse

            inc current
            inc prev
            inc i
        endwhile
        add current_rowstart stride
        add prev_rowstart stride
        inc j
    endwhile

    return (SKIP)
endfunction

