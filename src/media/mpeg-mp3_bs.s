


format elfobj

include "../_include/include.h"

import "mp3_output" mp3_output
import "mp3_allsize" mp3_allsize
import "mp3_output_size" mp3_output_size
import "mp3_output_pos" mp3_output_pos

import "shl" shl

function mp3_bs_write(sd value,sd len)
    sd size
    setcall size mp3_output_size((value_get))
    sd allsize
    setcall allsize mp3_allsize((value_get))
    sd pos
    setcall pos mp3_output_pos((value_get))
    while len!=0
        if size>=allsize
            call mp3_output_size((value_set),size)
            call mp3_output_pos((value_set),pos)
            return 0
        endif

        ss mem
        setcall mem mp3_output((value_get))
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
    call mp3_output_size((value_set),size)
    call mp3_output_pos((value_set),pos)
endfunction
