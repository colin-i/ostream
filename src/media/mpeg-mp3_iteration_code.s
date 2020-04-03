


format elfobj

include "../_include/include.h"

import "mp3_gr_info_itemSet" mp3_gr_info_itemSet

#bits
function mp3_iteration_code(sd l3enc_tt,sd gr_info)
    data addresses#3
    data p_addresses^addresses
    data table_select_0#1
    data table_select_1#1
    data table_select_2#1
    data p_table_select^table_select_0
    sd bits
    #
    call mp3_calc_runlen(l3enc_tt,gr_info)
    setcall bits count1_bitcount(l3enc_tt,gr_info)
    call subdivide(gr_info,p_addresses)
    call bigv_tab_select(l3enc_tt,gr_info,p_addresses,p_table_select)
    addcall bits bigv_bitcount(l3enc_tt,p_addresses,p_table_select)
    #
    call mp3_gr_info_itemSet(gr_info,(gr_info_table_select_0),table_select_0)
    call mp3_gr_info_itemSet(gr_info,(gr_info_table_select_1),table_select_1)
    call mp3_gr_info_itemSet(gr_info,(gr_info_table_select_2),table_select_2)

    return bits
endfunction
#######
import "l3_enc_sample_get" l3_enc_sample_get
import "mp3_gr_info_itemGet" mp3_gr_info_itemGet
function mp3_calc_runlen(sd l3enc_tt,sd gr_info)
    sd i=samp_per_frame2
    #int rzero = 0;
    sd value
    sd loop=1
    while loop==1
        set loop 0
        if i>1
            set value i
            sub value 1
            setcall value l3_enc_sample_get(l3enc_tt,value)
            if value==0
                set value i
                sub value 2
                setcall value l3_enc_sample_get(l3enc_tt,value)
                if value==0
                    #rzero++
                    sub i 2
                    set loop 1
                endif
            endif
        endif
    endwhile
    sd index
    call mp3_gr_info_itemSet(gr_info,(gr_info_count1),0)
    set loop 1
    while loop==1
        set loop 0
        if i>3
            set index i
            #-1
            dec index
            setcall value l3_enc_sample_get(l3enc_tt,index)
            if value<=1
                #-2
                dec index
                setcall value l3_enc_sample_get(l3enc_tt,index)
                if value<=1
                    #-3
                    dec index
                    setcall value l3_enc_sample_get(l3enc_tt,index)
                    if value<=1
                        #-4
                        dec index
                        setcall value l3_enc_sample_get(l3enc_tt,index)
                        if value<=1
                            sd count1
                            setcall count1 mp3_gr_info_itemGet(gr_info,(gr_info_count1))
                            inc count1
                            call mp3_gr_info_itemSet(gr_info,(gr_info_count1),count1)
                            #
                            sub i 4
                            set loop 1
                        endif
                    endif
                endif
            endif
        endif
    endwhile
    import "sar32" sar
    setcall i sar(i,1)
    call mp3_gr_info_itemSet(gr_info,(gr_info_big_values),i)
endfunction
#bits
function count1_bitcount(sd l3enc_tt,sd gr_info)
    sd sum0=0
    sd sum1=0
    sd v
    sd w
    sd x
    sd y
    sd p
    sd i
    setcall i mp3_gr_info_itemGet(gr_info,(gr_info_big_values))
    import "shl" shl
    setcall i shl(i,1)
    sd k=0
    sd count1
    setcall count1 mp3_gr_info_itemGet(gr_info,(gr_info_count1))
    while k<count1
        setcall v l3_enc_sample_get(l3enc_tt,i)
        inc i
        setcall w l3_enc_sample_get(l3enc_tt,i)
        inc i
        setcall x l3_enc_sample_get(l3enc_tt,i)
        inc i
        setcall y l3_enc_sample_get(l3enc_tt,i)
        inc i

        set p v
        addcall p shl(w,1)
        addcall p shl(x,2)
        addcall p shl(y,3)

        sd signbits=0
        if v!=0
            inc signbits
        endif
        if w!=0
            inc signbits
        endif
        if x!=0
            inc signbits
        endif
        if y!=0
            inc signbits
        endif

        add sum0 signbits
        add sum1 signbits
        import "huffman_hlen" huffman_hlen
        addcall sum0 huffman_hlen(32,p)
        addcall sum1 huffman_hlen(33,p)

        inc k
    endwhile
    if sum0<sum1
        call mp3_gr_info_itemSet(gr_info,(gr_info_count1table_select),0)
        return sum0
    endif
    call mp3_gr_info_itemSet(gr_info,(gr_info_count1table_select),1)
    return sum1
endfunction
import "scalefac_band_long" scalefac_band_long
import "subdv_table" subdv_table
function subdivide(sd gr_info,sd p_addresses)
    sd big_values
    setcall big_values mp3_gr_info_itemGet(gr_info,(gr_info_big_values))
    sd bigvalues_region
    sd scfb_anz=0
    set bigvalues_region big_values
    mult bigvalues_region 2
    sd scalefac_band
    setcall scalefac_band scalefac_band_long()
    while scalefac_band#<bigvalues_region
        inc scfb_anz
        add scalefac_band (DWORD)
    endwhile
    #
    sd region0_count
    setcall region0_count subdv_table(scfb_anz,0)
    sd thiscount
    sd index
    set thiscount region0_count
    set index thiscount
    inc index
    setcall scalefac_band scalefac_band_long()
    sd sizeadd=DWORD
    mult sizeadd index
    add scalefac_band sizeadd
    sd loop=1
    while loop==1
        set loop 0
        if thiscount!=0
            if scalefac_band#>bigvalues_region
                dec thiscount
                dec index
                sub scalefac_band (DWORD)
                set loop 1
            endif
        endif
    endwhile
    set region0_count thiscount
    call mp3_gr_info_itemSet(gr_info,(gr_info_region0_count),region0_count)
    #
    sd region1_count
    setcall region1_count subdv_table(scfb_anz,1)
    set thiscount region1_count
    set index region0_count
    add index region1_count
    add index 2
    setcall scalefac_band scalefac_band_long()
    set sizeadd (DWORD)
    mult sizeadd index
    add scalefac_band sizeadd
    set loop 1
    while loop==1
        set loop 0
        if thiscount!=0
            if scalefac_band#>bigvalues_region
                dec thiscount
                dec index
                sub scalefac_band (DWORD)
                set loop 1
            endif
        endif
    endwhile
    set region1_count thiscount
    call mp3_gr_info_itemSet(gr_info,(gr_info_region1_count),region1_count)
    #
    import "scalefac_band_long_get" scalefac_band_long_get
    set index region0_count
    inc index
    setcall p_addresses# scalefac_band_long_get(index)
    #
    add p_addresses (DWORD)
    set index region0_count
    add index region1_count
    add index 2
    setcall p_addresses# scalefac_band_long_get(index)
    #
    add p_addresses (DWORD)
    set p_addresses# bigvalues_region
endfunction
function bigv_tab_select(sd l3enc_tt,sd gr_info,sd p_addresses,sd p_table_select)
    #Select huffman code tables for bigvalues regions
    sd address_1
    sd address_2
    sd big_values
    set address_1 p_addresses#
    add p_addresses (DWORD)
    set address_2 p_addresses#
    setcall big_values mp3_gr_info_itemGet(gr_info,(gr_info_big_values))
    #
    set p_table_select# 0
    if address_1>0
        setcall p_table_select# mp3_choose_table(l3enc_tt,0,address_1)
    endif
    add p_table_select (DWORD)
    set p_table_select# 0
    if address_2>address_1
        setcall p_table_select# mp3_choose_table(l3enc_tt,address_1,address_2)
    endif
    add p_table_select (DWORD)
    set p_table_select# 0
    mult big_values 2
    if big_values>address_2
        setcall p_table_select# mp3_choose_table(l3enc_tt,address_2,big_values)
    endif
endfunction
#bits
function bigv_bitcount(sd l3enc_tt,sd p_addresses,sd p_table_select)
    sd bits=0
    sd table
    sd addr_1
    sd addr_2
    sd addr_3
    set table p_table_select#
    set addr_1 p_addresses#
    if table!=0
        addcall bits mp3_count_bit(l3enc_tt,0,addr_1,table)
    endif
    add p_table_select (DWORD)
    add p_addresses (DWORD)
    set table p_table_select#
    set addr_2 p_addresses#
    if table!=0
        addcall bits mp3_count_bit(l3enc_tt,addr_1,addr_2,table)
    endif
    add p_table_select (DWORD)
    add p_addresses (DWORD)
    set table p_table_select#
    set addr_3 p_addresses#
    if table!=0
        addcall bits mp3_count_bit(l3enc_tt,addr_2,addr_3,table)
    endif
    return bits
endfunction
#########

import "huffman_tabs" huffman_tabs
#table_select
function mp3_choose_table(sd l3enc_tt,sd start,sd end)
    sd max
    setcall max mp3_int_max(l3enc_tt,start,end)
    if max==0
        return 0
    endif
    sd i
    sd value
    sd choice_0=0
    sd choice_1=0
    sd sum_0
    sd sum_1
    if max<15
        set i 14
        while i!=0
            dec i
            setcall value huffman_tabs(i,(huffman_xlen))
            if value>max
                set choice_0 i
                set i 0
            endif
        endwhile
        setcall sum_0 mp3_count_bit(l3enc_tt,start,end,choice_0)
        if choice_0==2
            setcall sum_1 mp3_count_bit(l3enc_tt,start,end,3)
            if sum_1<=sum_0
                set choice_0 3
            endif
        elseif choice_0==5
            setcall sum_1 mp3_count_bit(l3enc_tt,start,end,6)
            if sum_1<=sum_0
                set choice_0 6
            endif
        elseif choice_0==7
            setcall sum_1 mp3_count_bit(l3enc_tt,start,end,8)
            if sum_1<=sum_0
                set choice_0 8
                set sum_0 sum_1
            endif
            setcall sum_1 mp3_count_bit(l3enc_tt,start,end,9)
            if sum_1<=sum_0
                set choice_0 9
            endif
        elseif choice_0==10
            setcall sum_1 mp3_count_bit(l3enc_tt,start,end,11)
            if sum_1<=sum_0
                set choice_0 11
                set sum_0 sum_1
            endif
            setcall sum_1 mp3_count_bit(l3enc_tt,start,end,12)
            if sum_1<=sum_0
                set choice_0 12
            endif
        elseif choice_0==13
            setcall sum_1 mp3_count_bit(l3enc_tt,start,end,15)
            if sum_1<=sum_0
                set choice_0 15
            endif
        endelseif
    else
        #try tables with linbits
        sub max 15
        set i 15
        while i<24
            setcall value huffman_tabs(i,(huffman_linmax))
            if value>=max
                set choice_0 i
                set i 24
            else
                inc i
            endelse
        endwhile
        set i 24
        while i<32
            setcall value huffman_tabs(i,(huffman_linmax))
            if value>=max
                set choice_1 i
                set i 32
            else
                inc i
            endelse
        endwhile
        setcall sum_0 mp3_count_bit(l3enc_tt,start,end,choice_0)
        setcall sum_1 mp3_count_bit(l3enc_tt,start,end,choice_1)
        if sum_1<sum_0
            set choice_0 choice_1
        endif
    endelse
    return choice_0
endfunction

#bits
function mp3_count_bit(sd l3enc_tt,sd start,sd end,sd table)
    if table==0
        return 0
    endif
    sd ylen
    sd linbits
    sd i
    set i start
    mult i (DWORD)
    add l3enc_tt i
    sd x
    sd y
    sd sum=0
    sd index
    setcall ylen huffman_tabs(table,(huffman_ylen))
    setcall linbits huffman_tabs(table,(huffman_linbits))
    set i start
    if table>15
        #ESC-table is used
        while i<end
            set x l3enc_tt#
            add l3enc_tt (DWORD)
            set y l3enc_tt#
            add l3enc_tt (DWORD)
            if x>14
                set x 15
                add sum linbits
            endif
            if y>14
                set y 15
                add sum linbits
            endif
            set index x
            mult index ylen
            add index y
            addcall sum huffman_hlen(table,index)
            if x!=0
                inc sum
            endif
            if y!=0
                inc sum
            endif
            #
            add i 2
        endwhile
    else
        #No ESC-words
        while i<end
            set x l3enc_tt#
            add l3enc_tt (DWORD)
            set y l3enc_tt#
            add l3enc_tt (DWORD)
            set index x
            mult index ylen
            add index y
            addcall sum huffman_hlen(table,index)
            if x!=0
                inc sum
            endif
            if y!=0
                inc sum
            endif
            #
            add i 2
        endwhile
    endelse
    return sum
endfunction

#maximum
function mp3_int_max(sd array,sd start,sd end)
    sd max=0
    sd i
    set i start
    mult i (DWORD)
    add array i
    set i start
    while i<end
        if max<array#
            set max array#
        endif
        add array (DWORD)
        inc i
    endwhile
    return max
endfunction
