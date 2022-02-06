


format elfobj

include "../_include/include.h"

import "mp3_gr_info" mp3_gr_info
import "mp3_gr_info_itemSet" mp3_gr_info_itemSet
import "mp3_gr_info_itemGet" mp3_gr_info_itemGet
import "l3_enc" l3_enc
import "mp3_xrabs" mp3_xrabs
import "mult64_highint_rounded" mult64_highint_rounded

function mp3_iteration(sd mdct_freq,sd mean_bits)
    sd ResvSize=0
    sd ResvMax=0
    sd xr
    sd channel=mp3_channels
    while channel>0
        dec channel
        set xr (mdct_freq_channel_size)
        mult xr channel
        add xr mdct_freq
        sd granule=0
        while granule<2
            #abs,  and maximum
            sd xrmax=0
            sd i=samp_per_frame2
            sd xrabs
            setcall xrabs mp3_xrabs()
            #sd xrsq
            #setcall xrsq mp3_xrsq()
            add xrabs (samp_per_frame2*DWORD)
            #add xrsq (samp_per_frame2*DWORD)
            add xr (samp_per_frame2*DWORD)
            while i!=0
                dec i
                sub xrabs (DWORD)
                #sub xrsq (DWORD)
                sub xr (DWORD)
                #
                #setcall xrsq# mult64_highint_rounded(xr#,xr#)
                #
                set xrabs# xr#
                if xrabs#<0
                    mult xrabs# -1
                endif
                if xrabs#>xrmax
                    set xrmax xrabs#
                endif
            endwhile
            import "mp3_xrmax_set" mp3_xrmax_set
            call mp3_xrmax_set(xrmax)
            #
            sd l3enc_tt
            setcall l3enc_tt l3_enc(granule,channel)
            sd gr_info
            setcall gr_info mp3_gr_info(granule,channel)
            #
            sd max_bits
            setcall max_bits mp3_ResvMaxBits(mean_bits)
            #
            import "setmemzero" setmemzero
            call setmemzero(gr_info,(gr_info_channelSize))
            #
            if xrmax!=0
                sd part2_3_length
                setcall part2_3_length mp3_outer_loop(l3enc_tt,gr_info,max_bits)
                call mp3_gr_info_itemSet(gr_info,(gr_info_part2_3_length),part2_3_length)
            endif
            #
            sd value
            set value mean_bits
            div value (mp3_channels)
            subcall value mp3_gr_info_itemGet(gr_info,(gr_info_part2_3_length))
            add ResvSize value
            #
            sd quantizerStepSize
            setcall quantizerStepSize mp3_gr_info_itemGet(gr_info,(gr_info_quantizerStepSize))
            add quantizerStepSize 210
            call mp3_gr_info_itemSet(gr_info,(gr_info_global_gain),quantizerStepSize)
            #
            add xr (mdct_freq_granule_size)
            inc granule
        endwhile
    endwhile
    call mp3_ResvFrameEnd(ResvSize,ResvMax,mean_bits)
endfunction

#from main here
#max_bits
function mp3_ResvMaxBits(sd mean_bits)
    sd max_bits
    div mean_bits (mp3_channels)
    set max_bits mean_bits
    if max_bits>4095
        set max_bits 4095
    endif
    return max_bits
endfunction

#from main here
#bits
function mp3_outer_loop(sd l3enc_tt,sd gr_info,sd max_bits)
    call mp3_search_StepSize(l3enc_tt,gr_info,max_bits)
    sd value
    setcall value mp3_inner_loop(l3enc_tt,gr_info,max_bits)
    return value
endfunction

function mp3_ResvFrameEnd(sd ResvSize,sd ResvMax,sd mean_bits)
    #just in case mean_bits is odd, this is necessary...
    sd value
    if (mp3_channels)==2
        set value mean_bits
        and value 1
        if value!=0
            inc ResvSize
        endif
    endif
    sd over_bits
    set over_bits ResvSize
    sub over_bits ResvMax
    if over_bits<0
        set over_bits 0
    endif
    sub ResvSize over_bits
    sd ancillary_pad=0
    sd stuffingBits
    set stuffingBits over_bits
    add stuffingBits ancillary_pad
    if stuffingBits!=0
        sd gr_info
        setcall gr_info mp3_gr_info(0,0)
        sd part2_3_length
        setcall part2_3_length mp3_gr_info_itemGet(gr_info,(gr_info_part2_3_length))
        add part2_3_length stuffingBits
        call mp3_gr_info_itemSet(gr_info,(gr_info_part2_3_length),part2_3_length)
    endif
endfunction

import "mp3_iteration_code" mp3_iteration_code
import "sar32" sar

#from outer_loop

function mp3_search_StepSize(sd l3enc_tt,sd gr_info,sd desired_rate)
    sd top=-120
    sd next
    sd last
    sd bot=0
    sd value
    sd bit

    set next top
    sd loop=1
    while loop==1
        set last next
        set next top
        add next bot
        setcall next sar(next,1)
        setcall value mp3_quantize(l3enc_tt,next)
        if value>8192
            #fail
            set bit 100000
        else
            setcall bit mp3_iteration_code(l3enc_tt,gr_info)
        endelse
        if bit>desired_rate
            set top next
        else
            set bot next
        endelse
        set loop 0
        if bit!=desired_rate
            set value last
            sub value next
            if value<0
                mult value -1
            endif
            if value>1
                set loop 1
            endif
        endif
    endwhile
    call mp3_gr_info_itemSet(gr_info,(gr_info_quantizerStepSize),next)
endfunction

import "mp3_steptabi_get" mp3_steptabi_get
import "mp3_int2idx_get" mp3_int2idx_get

#near mp3_iteration_code

#maximum value of l3enc_tt
function mp3_quantize(sd l3enc_tt,sd stepsize)
    sd i=127
    add i stepsize
    sd scalei
    setcall scalei mp3_steptabi_get(i)
    sd value
    #a quick check to see if max will be less than 8192
    #  this speeds up the early calls to mp3_search_StepSize
    import "mp3_xrmax_get" mp3_xrmax_get
    sd xrmax
    setcall xrmax mp3_xrmax_get()
    setcall value mult64_highint_rounded(xrmax,scalei)
    if value>165140
        #no point in continuing, stepsize not big enough
        return 16384
    endif
    sd ln
    sd max=0
    set i 0
    while i<(samp_per_frame2)
        import "mp3_xrabs_get" mp3_xrabs_get
        sd abs_value
        setcall abs_value mp3_xrabs_get(i)
        setcall ln mult64_highint_rounded(abs_value,scalei)
        if ln<10000
            setcall l3enc_tt# mp3_int2idx_get(ln)
        else
            #outside table range so have to do it using floats
            import "mp3_steptab_double_get_p" mp3_steptab_double_get_p
            set value stepsize
            add value 127
            sd scale
            setcall scale mp3_steptab_double_get_p(value)
            import "fmul_quad" fmul_quad
            import "fild_value" fild_value
            import "fstp_quad" fstp_quad
            importx "_sqrt" sqrt
            import "double_to_int" double_to_int
            call fild_value(abs_value)
            call fmul_quad(scale)
            setcall value mp3_quantize_const1()
            call fmul_quad(value)
            data double_low#1
            data double_high#1
            data double^double_low
            call fstp_quad(double)
            call sqrt(double_low,double_high)
            call fmul_quad(double)
            call fstp_quad(double)
            call sqrt(double_low,double_high)
            call fstp_quad(double)
            setcall l3enc_tt# double_to_int(double)
        endelse
        #
        if max<l3enc_tt#
            set max l3enc_tt#
        endif
        #
        add l3enc_tt (DWORD)
        inc i
    endwhile
    return max
endfunction
function mp3_quantize_const1()
    data double#2
    data p^double
    return p
endfunction
function mp3_quantize_init()
    sd c1
    setcall c1 mp3_quantize_const1()
    import "str_to_double" str_to_double
    str s1="4.656612875e-10"
    call str_to_double(s1,c1)
endfunction

#from mp3_outer_loop
#bits
function mp3_inner_loop(sd l3enc_tt,sd gr_info,sd max_bits)
    sd quantizerStepSize
    setcall quantizerStepSize mp3_gr_info_itemGet(gr_info,(gr_info_quantizerStepSize))
    if max_bits<0
        dec quantizerStepSize
        call mp3_gr_info_itemSet(gr_info,(gr_info_quantizerStepSize),quantizerStepSize)
    endif
    sd loop=1
    while loop==1
        sd value=8192+1
        while value>8192
            setcall quantizerStepSize mp3_gr_info_itemGet(gr_info,(gr_info_quantizerStepSize))
            inc quantizerStepSize
            call mp3_gr_info_itemSet(gr_info,(gr_info_quantizerStepSize),quantizerStepSize)
            setcall value mp3_quantize(l3enc_tt,quantizerStepSize)
        endwhile
        sd bits
        setcall bits mp3_iteration_code(l3enc_tt,gr_info)
        if bits<=max_bits
            set loop 0
        endif
    endwhile
    return bits
endfunction


