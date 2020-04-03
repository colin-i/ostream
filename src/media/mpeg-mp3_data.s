

format elfobj

include "../_include/include.h"

function mp3_output(sd way,sd value)
    data output#1
    if way==(value_set)
        set output value
    else
        return output
    endelse
endfunction
function mp3_allsize(sd way,sd value)
    data allsize#1
    if way==(value_set)
        set allsize value
    else
        return allsize
    endelse
endfunction
function mp3_output_size(sd way,sd value)
    data output_size#1
    if way==(value_set)
        set output_size value
    else
        return output_size
    endelse
endfunction
function mp3_output_pos(sd way,sd value)
    data output_pos#1
    if way==(value_set)
        set output_pos value
    else
        return output_pos
    endelse
endfunction

#l3 inits

function mp3_steptab_double()
    data steptab_data#128*QWORD
    data steptab^steptab_data
    return steptab
endfunction
function mp3_steptab_double_get_p(sd index)
    sd tab
    setcall tab mp3_steptab_double()
    mult index (QWORD)
    add tab index
    return tab
endfunction
function mp3_steptabi()
    data steptabi_data#128*DWORD
    data steptabi^steptabi_data
    return steptabi
endfunction
function mp3_steptabi_get(sd index)
    sd tab
    setcall tab mp3_steptabi()
    mult index (DWORD)
    add tab index
    return tab#
endfunction

function mp3_int2idx()
    data int2idx#10000
    data p_int2idx^int2idx
    return p_int2idx
endfunction
function mp3_int2idx_get(sd index)
    sd i
    setcall i mp3_int2idx()
    mult index (DWORD)
    add i index
    return i#
endfunction


#l3_enc

const l3_enc_channelSize=samp_per_frame2*DWORD
const l3_enc_granuleSize=mp3_channels*l3_enc_channelSize
#pointer
function l3_enc(sd granule,sd channel)
    data l3_enc_data#2*mp3_channels*samp_per_frame2
    sd l3^l3_enc_data
    mult granule (l3_enc_granuleSize)
    add l3 granule
    mult channel (l3_enc_channelSize)
    add l3 channel
    return l3
endfunction
#value
function l3_enc_sample_get(sd set,sd samp_nr)
    mult samp_nr (DWORD)
    add set samp_nr
    return set#
endfunction

#gr info

const gr_info_items=gr_info_channelSize/DWORD
const gr_info_granuleSize=mp3_channels*gr_info_channelSize
#pointer
function mp3_gr_info(sd granule,sd channel)
    #side informations
    data gr_info_data#2*mp3_channels*gr_info_items
    sd gr_info^gr_info_data
    mult granule (gr_info_granuleSize)
    add gr_info granule
    mult channel (gr_info_channelSize)
    add gr_info channel
    return gr_info
endfunction
#value
function mp3_gr_info_itemGet(sd pack,sd item)
    add pack item
    return pack#
endfunction
#
function mp3_gr_info_itemSet(sd pack,sd item,sd value)
    add pack item
    set pack# value
endfunction


function mp3_xrabs()
    data xrabs#samp_per_frame2
    data p^xrabs
    return p
endfunction
function mp3_xrabs_get(sd index)
    sd tab
    setcall tab mp3_xrabs()
    mult index (DWORD)
    add tab index
    return tab#
endfunction
#
function mp3_xrmax()
    data xrmax#1
    data p_xrmax^xrmax
    return p_xrmax
endfunction
function mp3_xrmax_get()
    sd x
    setcall x mp3_xrmax()
    return x#
endfunction
function mp3_xrmax_set(sd value)
    sd x
    setcall x mp3_xrmax()
    set x# value
endfunction


function mp3_l3_sb_sample()
    data l3_sb_sample_data#l3_sb_sample_units
    data l3_sb_sample^l3_sb_sample_data
    return l3_sb_sample
endfunction

function mp3_mean_bits()
    data mean_bits#1
    data p^mean_bits
    return p
endfunction
