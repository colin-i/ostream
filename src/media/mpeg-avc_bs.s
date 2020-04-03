
format elfobj

include "../_include/include.h"

import "avc_output" avc_output
import "avc_output_pos" avc_output_pos
import "avc_output_size" avc_output_size
import "avc_allsize" avc_allsize

import "shl" shl
import "sar32" sar
import "array_get_int" array_get_int

function avc_bs_write(sd value,sd len)
    sd size
    setcall size avc_output_size((value_get))
    sd allsize
    setcall allsize avc_allsize((value_get))
    sd pos
    setcall pos avc_output_pos((value_get))
    while len!=0
        if size>=allsize
            call avc_output_size((value_set),size)
            call avc_output_pos((value_set),pos)
            return 0
        endif

        ss mem
        setcall mem avc_output((value_get))
        add mem size

        dec len
        dec pos
        sd test=1
        setcall test shl(test,len)
        and test value
        sd unit=1
        setcall unit shl(unit,pos)
        if test!=0
            or mem# unit
        else
            xor unit -1
            and mem# unit
        endelse
        if pos==0
            inc size
            set pos 8
        endif
    endwhile
    call avc_output_size((value_set),size)
    call avc_output_pos((value_set),pos)
endfunction

function avc_bs_write_ue(sd value)
    sd i_size=0
    #i_size0_255[256]
    data i_size_tab_data={1,1,2,2,3,3,3,3,4,4,4,4,4,4,4,4,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5}
    data *              ={6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6}
    data *              ={7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7}
    data *              ={7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7}
    data *              ={8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8}
    data *              ={8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8}
    data *              ={8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8}
    data i_size_tab^i_size_tab_data
    if value==0
        call avc_bs_write(1,1)
    else
        #unsigned int temp
        inc value
        sd temp
        set temp value
        sd enter=0
        if temp<0
            set enter 1
        elseif temp>=0x00010000
            set enter 1
        endelseif
        if enter==1
            add i_size 16
            setcall temp sar(temp,16)
        endif
        if temp>=0x100
            add i_size 8
            setcall temp sar(temp,8)
        endif
        addcall i_size array_get_int(i_size_tab,temp)
        mult i_size 2
        dec i_size
        call avc_bs_write(value,i_size)
    endelse
endfunction

function avc_bs_write_se(sd value)
    if value<=0
        mult value -2
        call avc_bs_write_ue(value)
    else
        mult value 2
        dec value
        call avc_bs_write_ue(value)
    endelse
endfunction

function avc_bs_write_byte(sd value)
    call avc_bs_write(value,8)
endfunction

function avc_bs_trailing()
    call avc_bs_write(1,1)
    sd pos
    setcall pos avc_output_pos((value_get))
    if pos!=8
        call avc_bs_write(0,pos)
    endif
endfunction
function avc_bs_align_byte()
    sd pos
    setcall pos avc_output_pos((value_get))
    if pos!=8
        call avc_bs_write(-1,pos)
    endif
endfunction
function avc_bs_align_byte_with_0()
    sd pos
    setcall pos avc_output_pos((value_get))
    if pos!=8
        call avc_bs_write(0,pos)
    endif
endfunction

function avc_bs_write_data(ss bytes,sd count)
    while count!=0
        call avc_bs_write_byte(bytes#)
        inc bytes
        dec count
    endwhile
endfunction

function avc_bs_write_bit(sd value)
    call avc_bs_write(value,1)
endfunction
