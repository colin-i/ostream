

format elfobj

include "../_include/include.h"

#bool
function mp3_init()
    import "mp3_output" mp3_output
    import "mp3_allsize" mp3_allsize
    sd output
    const BUFFER_SIZE=4096
    sd size=BUFFER_SIZE
    import "memalloc" memalloc
    setcall output memalloc(size)
    if output==0
        return 0
    endif
    call mp3_output((value_set),output)
    call mp3_allsize((value_set),size)

    import "l3_subband_init" l3_subband_init
    call l3_subband_init()
    import "l3_mdct_init" l3_mdct_init
    call l3_mdct_init()
    call l3_loop_init()

    import "mp3_encode_init" mp3_encode_init
    call mp3_encode_init()

    return 1
endfunction

importx "_free" free

function mp3_free()
    sd output
    setcall output mp3_output((value_get))
    call free(output)
endfunction

import "fild" fild
import "fstp_quad" fstp_quad
importx "_sqrt" sqrt
import "str_to_double" str_to_double
import "fimul" fimul
import "fsub_quad" fsub_quad
import "fadd_quad" fadd_quad
import "fdiv_quad" fdiv_quad
importx "_pow" pow
import "fst_quad" fst_quad
import "fcom_quad_greater" fcom_quad_greater

function l3_loop_init()
    call mp3_steptab_init()
    call mp3_int2idx_init()
    import "mp3_quantize_init" mp3_quantize_init
    call mp3_quantize_init()
endfunction

import "double_to_int" double_to_int

function mp3_steptab_init()
    import "mp3_steptab_double" mp3_steptab_double
    import "mp3_steptabi" mp3_steptabi
    sd steptab_double
    sd steptabi
    setcall steptab_double mp3_steptab_double()
    setcall steptabi mp3_steptabi()
    add steptab_double (128*QWORD)
    add steptabi (128*DWORD)
    sd value
    sd p_value^value
    #
    data double_low#1
    data double_high#1
    data double^double_low
    data const1_low#1
    data *const1_high#1
    data const1^const1_low
    str str_const1="4"
    call str_to_double(str_const1,const1)
    data const2_low#1
    data const2_high#1
    data const2^const2_low
    str str_const2="2.0"
    call str_to_double(str_const2,const2)
    data const3_low#1
    data *const3_high#1
    data const3^const3_low
    #0x7fFFffFF
    str str_const3="2147483647"
    call str_to_double(str_const3,const3)
    data const4_low#1
    data *const4_high#1
    data const4^const4_low
    str str_const4="0.5"
    call str_to_double(str_const4,const4)
    #
    sd i=128
    while i!=0
        dec i
        sub steptab_double (QWORD)
        sub steptabi (DWORD)
        #
        set value 127
        sub value i
        call fild(p_value)
        call fdiv_quad(const1)
        call fstp_quad(double)
        call pow(const2_low,const2_high,double_low,double_high)
        call fst_quad(double)
        call fst_quad(steptab_double)
        call fadd_quad(double)
        sd bool
        setcall bool fcom_quad_greater(const3)
        if bool==1
            set steptabi# 0x7fFFffFF
        else
            call fadd_quad(const4)
            #call fistp(steptabi)
            call fstp_quad(double)
            setcall steptabi# double_to_int(double)
        endelse
    endwhile
endfunction

function mp3_int2idx_init()
    data double_low#1
    data double_high#1
    data double^double_low
    data const1_low#1
    data *const1_high#1
    data const2_low#1
    data *const2_high#1
    data const1^const1_low
    data const2^const2_low
    str str_const1="0.0946"
    str str_const2="0.5"
    call str_to_double(str_const1,const1)
    call str_to_double(str_const2,const2)
    import "mp3_int2idx" mp3_int2idx
    sd int2idx
    setcall int2idx mp3_int2idx()
    add int2idx (10000*DWORD)
    sd i=10000
    sd p_i^i
    while i!=0
        sub int2idx (DWORD)
        dec i
        #
        call fild(p_i)
        call fstp_quad(double)
        call sqrt(double_low,double_high)
        call fimul(p_i)
        call fstp_quad(double)
        call sqrt(double_low,double_high)
        call fsub_quad(const1)
        call fadd_quad(const2)
        #call fistp(int2idx)
        call fstp_quad(double)
        setcall int2idx# double_to_int(double)
    endwhile
endfunction
