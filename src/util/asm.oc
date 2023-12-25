

format elfobj

include "../_include/include.h"

function getoneax(sd value)
    return value
endfunction

#SAR 32
function sar32(sd value,sd *count)
    sd p_value^value
    call getoneax(p_value)
    #ecx eax
    hex 0x8b,ecx*to_regopcode|mod_reg|eax
    #ecx +4
    hex 0x81,mod_reg|ecx,4,0,0,0
    #ecx [ecx]
    hex 0x8b,ecx*to_regopcode|ecx
    #sar @ [eax]
    hex 0xd3,7*to_regopcode
    return value
endfunction

function shl(sd value,sd *count)
    sd p_value^value
    call getoneax(p_value)
    #ecx eax
    hex 0x8b,ecx*to_regopcode|mod_reg|eax
    #ecx +4
    hex 0x81,mod_reg|ecx,4,0,0,0
    #ecx [ecx]
    hex 0x8b,ecx*to_regopcode|ecx
    #shl @ [eax]
    hex 0xd3,4*to_regopcode
    return value
endfunction

function shr(sd value,sd *count)
    sd p_value^value
    call getoneax(p_value)
    #ecx eax
    hex 0x8b,ecx*to_regopcode|mod_reg|eax
    #ecx +4
    hex 0x81,mod_reg|ecx,4,0,0,0
    #ecx [ecx]
    hex 0x8b,ecx*to_regopcode|ecx
    #shr @ [eax]
    hex 0xd3,5*to_regopcode
    return value
endfunction
