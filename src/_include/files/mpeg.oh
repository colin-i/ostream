

#####asp

const quant_base=100
const DEFAULT_QUANT=400/quant_base


const default_scaler=8

const VLC_code=0
const VLC_len=4
const VLC_size=4+1


const ESCAPE1=6
const ESCAPE2=14
const ESCAPE3=15


const if_needed=0
const always=1


const I_VOP=0
const P_VOP=1
const B_VOP=2


const value_get_prev=value_custom

const INTRA=0
const SKIP=1


#####avc
const avc_sequence_param=0
const avc_picture_param=1
const avc_frame0_headers=2
const avc_frame=3

const avc_keyint_max=250
const avc_pic_init_qp=26

const avc_ctxstate_size=3
const avc_ctxstate_total=436
const avc_ctxstate_state=0
const avc_ctxstate_mps=1
const avc_ctxstate_count=2

const SLICE_TYPE_P=0
#    SLICE_TYPE_B  = 1,
const SLICE_TYPE_I=2

const avc_mb_cache_units=16+4+4
const avc_mb_cache_size=avc_mb_cache_units*DWORD
#type+cbp
const avc_mb_type_offset=0
const avc_mb_cbp_offset=avc_mb_type_offset+DWORD
const avc_mb_cache_offset=avc_mb_cbp_offset+DWORD
const avc_mb_size=avc_mb_cache_offset+avc_mb_cache_size

const avc_I_16x16=2
const avc_P_SKIP=6


#mp3
const mp3_channels_stereo=2
#const mp3_channels_mono=1
const mp3_chans=2
const mp3_samplerate=48000
const mp3_bitspersample=16
const mp3_bytespersample=mp3_bitspersample/8
const mp3_blockalign=mp3_chans*mp3_bytespersample
const samp_per_frame=1152
const samp_per_frame2=576
const mp3_max_supported_bitrate=128
const mp3_BUFFER_SIZE=mp3_max_supported_bitrate*1000*144/mp3_samplerate  ;# + padding

const gr_info_part2_3_length=0
const gr_info_big_values=gr_info_part2_3_length+DWORD
const gr_info_global_gain=gr_info_big_values+DWORD
#scalefac_compress
const gr_info_table_select_0=gr_info_global_gain+DWORD
const gr_info_table_select_1=gr_info_table_select_0+DWORD
const gr_info_table_select_2=gr_info_table_select_1+DWORD
const gr_info_region0_count=gr_info_table_select_2+DWORD
const gr_info_region1_count=gr_info_region0_count+DWORD
const gr_info_count1table_select=gr_info_region1_count+DWORD
        #
const gr_info_count1=gr_info_count1table_select+DWORD
const gr_info_quantizerStepSize=gr_info_count1+DWORD
        #
const gr_info_channelSize=gr_info_quantizerStepSize+DWORD

const SBLIMIT=32

const l3_sb_sample_band_size=SBLIMIT*DWORD
const l3_sb_sample_granule_size=18*l3_sb_sample_band_size
const l3_sb_sample_channel_size=3*l3_sb_sample_granule_size
const l3_sb_sample_size=mp3_chans*l3_sb_sample_channel_size
const l3_sb_sample_units=l3_sb_sample_size/DWORD

const mdct_freq_channel_size=samp_per_frame2*DWORD
const mdct_freq_granule_size=mdct_freq_channel_size*mp3_chans

const huffman_xlen=0
const huffman_ylen=huffman_xlen+DWORD
const huffman_linbits=huffman_ylen+DWORD
const huffman_linmax=huffman_linbits+DWORD
const huffman_entry=huffman_linmax+DWORD

const buffer_channel_size=samp_per_frame*WORD
const buffer_size=mp3_chans*buffer_channel_size
