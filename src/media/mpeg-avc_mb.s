

format elfobj

include "../_include/include.h"

const I_PRED_16x16_DC=2
#const I_PRED_CHROMA_DC=0

import "array_get_int" array_get_int
import "sar32" sar
import "shl" shl
import "avc_cabac_ctxstate" avc_cabac_ctxstate

function avc_cabac_context_init()
    sd cabac
    import "avc_slice_type" avc_slice_type
    sd slice_type
    setcall slice_type avc_slice_type((value_get))
    if slice_type==(SLICE_TYPE_I)
        setcall cabac avc_cabac_context_init_I()
    else
        setcall cabac avc_cabac_context_init_P()
    endelse
    sd i=0
    import "avc_qp_I" avc_qp_I
    sd qp
    setcall qp avc_qp_I()
    sd ctxstate
    setcall ctxstate avc_cabac_ctxstate()
    while i<(avc_ctxstate_total)
        sd pre_state
        sd a_value
        sd b_value
        sd pos=2
        mult pos i
        setcall a_value array_get_int(cabac,pos)
        inc pos
        setcall b_value array_get_int(cabac,pos)
        mult a_value qp
        setcall a_value sar(a_value,4)
        add a_value b_value
        setcall pre_state avc_clip3(a_value,1,126)
        if pre_state<=63
            set ctxstate# 63
            sub ctxstate# pre_state
            add ctxstate 4
            set ctxstate# 0
            add ctxstate 4
        else
            set ctxstate# pre_state
            sub ctxstate# 64
            add ctxstate 4
            set ctxstate# 1
            add ctxstate 4
        endelse
        set ctxstate# 0
        add ctxstate 4
        inc i
    endwhile
endfunction

function avc_clip3(sd x,sd min,sd max)
    if x<min
        return min
    else
        if x>max
            return max
        else
            return x
        endelse
    endelse
endfunction

function avc_cabac_context_init_I()
    #[460][2]
    data    context_0_10={20, -15,    2, 54,     3,  74,     20, -15}
    data *              ={2,  54,     3, 74,     -28,127,    -23,104}
    data *              ={-6, 53,     -1,54,     7,  51}
    data *11-23 not at I={0,  0,      0, 0,      0,  0,      0,  0}
    data *              ={0,  0,      0, 0,      0,  0,      0,  0}
    data *              ={0,  0,      0, 0,      0,  0,      0,  0}
    data *              ={0,  0}
    data *24-39         ={0,  0,      0, 0,      0,  0,      0,  0}
    data *              ={0,  0,      0, 0,      0,  0,      0,  0}
    data *              ={0,  0,      0, 0,      0,  0,      0,  0}
    data *              ={0,  0,      0, 0,      0,  0,      0,  0}
    data *40-53         ={0,  0,      0, 0,      0,  0,      0,  0}
    data *              ={0,  0,      0, 0,      0,  0,      0,  0}
    data *              ={0,  0,      0, 0,      0,  0,      0,  0}
    data *              ={0,  0,      0, 0}
    data *54-59         ={0,  0,      0, 0,      0,  0,      0,  0}
    data *              ={0,  0,      0, 0}
    data *60-69         ={0,  41,     0, 63,     0,  63,     0,  63}
    data *              ={-9, 83,     4, 86,     0,  97,     -7, 72}
    data *              ={13, 41,     3, 62}
    data *70-87         ={0,  11,     1, 55,     0,  69,     -17,127}
    data *              ={-13,102,    0, 82,     -7, 74,     -21,107}
    data *              ={-27,127,   -31,127,    -24,127,    -18,95}
    data *              ={-27,127,   -21,114,    -30,127,    -17,123}
    data *              ={-12,115,   -16,122}
    data *88-104        ={-11,115,   -12,63,     -2, 68,     -15,84}
    data *              ={-13,104,   -3, 70,     -8, 93,     -10,90}
    data *              ={-30,127,   -1, 74,     -6, 97,     -7, 91}
    data *              ={-20,127,   -4, 56,     -5, 82,     -7, 76}
    data *              ={-22,125}
    data *105-135       ={-7, 93,    -11,87,     -3, 77,     -5, 71}
    data *              ={-4, 63,    -4, 68,     -12,84,     -7, 62}
    data *              ={-7, 65,    8,  61,     5,  56,     -2, 66}
    data *              ={1,  64,    0,  61,     -2, 78,     1,  50}
    data *              ={7,  52,    10, 35,     0,  44,     11, 38}
    data *              ={1,  45,    0,  46,     5,  44,     31, 17}
    data *              ={1,  51,    7,  50,     28, 19,     16, 33}
    data *              ={14, 62,    -13,108,    -15,100}
    data *136-165       ={-13, 101, -13, 91,  -12, 94,    -10, 88}
    data *              ={-16, 84,  -10, 86,  -7, 83,     -13, 87}
    data *              ={-19, 94,  1, 70,    0, 72,      -5, 74}
    data *              ={18, 59,   -8, 102,  -15, 100,   0, 95}
    data *              ={-4, 75,   2, 72,    -11, 75,    -3, 71}
    data *              ={15, 46,   -13, 69,  0, 62,      0, 65}
    data *              ={21, 37,   -15, 72,  9, 57,      16, 54}
    data *              ={0, 62,    12, 72}
    data *166-196       ={24, 0,   15, 9,   8, 25,     13, 18}
    data *              ={15, 9,   13, 19,  10, 37,    12, 18}
    data *              ={6, 29,   20, 33,  15, 30,    4, 45}
    data *              ={1, 58,   0, 62,   7, 61,     12, 38}
    data *              ={11, 45,  15, 39,  11, 42,    13, 44}
    data *              ={16, 45,  12, 41,  10, 49,    30, 34}
    data *              ={18, 42,  10, 55,  17, 51,    17, 46}
    data *              ={0, 89,   26, -19, 22, -17}
    data *197-226       ={26, -17, 30, -25, 28, -20,   33, -23}
    data *              ={37, -27, 33, -23, 40, -28,   38, -17}
    data *              ={33, -11, 40, -15, 41, -6,    38, 1}
    data *              ={41, 17,  30, -6,  27, 3,     26, 22}
    data *              ={37, -16, 35, -4,  38, -8,    38, -3}
    data *              ={37, 3,   38, 5,   42, 0,     35, 16}
    data *              ={39, 22,  14, 48,  27, 37,    21, 60}
    data *              ={12, 68,  2, 97}
    data *227-251       ={-3, 71,  -6, 42,  -5, 50,    -3, 54}
    data *              ={-2, 62,  0, 58,   1, 63,     -2, 72}
    data *              ={-1, 74,  -9, 91,  -5, 67,    -5, 27}
    data *              ={-3, 39,  -2, 44,  0, 46,     -16, 64}
    data *              ={-8, 68,  -10, 78, -6, 77,    -10, 86}
    data *              ={-12, 92, -15, 55, -10, 60,   -6, 62}
    data *              ={-4, 65}
    data *252-275       ={-12, 73, -8, 76,  -7, 80,    -9, 88}
    data *              ={-17, 110,-11, 97, -20, 84,   -11, 79}
    data *              ={-6, 73,  -4, 74,  -13, 86,   -13, 96}
    data *              ={-11, 97, -19, 117,-8, 78,    -5, 33}
    data *              ={-4, 48,  -2, 53,  -3, 62,    -13, 71}
    data *              ={-10, 79, -12, 86, -13, 90,   -14, 97}
    #276 is special (not used, x264_cabac_encode_bypass is used instead)
    data *              ={0, 0}
    data *277-307       ={-6, 93,  -6, 84,  -8, 79,    0, 66}
    data *              ={-1, 71,  0, 62,   -2, 60,    -2, 59}
    data *              ={-5, 75,  -3, 62,  -4, 58,    -9, 66}
    data *              ={-1, 79,  0, 71,   3, 68,     10, 44}
    data *              ={-7, 62,  15, 36,  14, 40,    16, 27}
    data *              ={12, 29,  1, 44,   20, 36,    18, 32}
    data *              ={5, 42,   1, 48,   10, 62,    17, 46}
    data *              ={9, 64,   -12, 104,-11, 97}
    data *308-337       ={-16, 96, -7, 88,  -8, 85,    -7, 85}
    data *              ={-9, 85,  -13, 88, 4, 66,     -3, 77}
    data *              ={-3, 76,  -6, 76,  10, 58,    -1, 76}
    data *              ={-1, 83,  -7, 99,  -14, 95,   2, 95}
    data *              ={0, 76,   -5, 74,  0, 70,     -11, 75}
    data *              ={1, 68,   0, 65,   -14, 73,   3, 62}
    data *              ={4, 62,   -1, 68,  -13, 75,   11, 55}
    data *              ={5, 64,   12, 70}
    data *338-368       ={15, 6,   6, 19,   7, 16,     12, 14}
    data *              ={18, 13,  13, 11,  13, 15,    15, 16}
    data *              ={12, 23,  13, 23,  15, 20,    14, 26}
    data *              ={14, 44,  17, 40,  17, 47,    24, 17}
    data *              ={21, 21,  25, 22,  31, 27,    22, 29}
    data *              ={19, 35,  14, 50,  10, 57,    7, 63}
    data *              ={-2, 77,  -4, 82,  -3, 94,    9, 69}
    data *              ={-12, 109,36, -35, 36, -34}
    data *369-398       ={32, -26, 37, -30, 44, -32,   34, -18}
    data *              ={34, -15, 40, -15, 33, -7,    35, -5}
    data *              ={33, 0,   38, 2,   33, 13,    23, 35}
    data *              ={13, 58,  29, -3,  26, 0,     22, 30}
    data *              ={31, -7,  35, -15, 34, -3,    34, 3}
    data *              ={36, -1,  34, 5,   32, 11,    35, 5}
    data *              ={34, 12,  39, 11,  30, 29,    34, 26}
    data *              ={29, 39,  19, 66}
    data *399-435       ={31,  21,  31,  31,  25,  50}
    data *              ={-17, 120, -20, 112, -18, 114, -11,  85}
    data *              ={-15,  92, -14,  89, -26,  71, -15,  81}
    data *              ={-14,  80,   0,  68, -14,  70, -24,  56}
    data *              ={-23,  68, -24,  50, -11,  74,  23, -13}
    data *              ={26, -13,  40, -15,  49, -14,  44,   3}
    data *              ={45,   6,  44,  34,  33,  54,  19,  82}
    data *              ={-3,  75,  -1,  23,   1,  34,   1,  43}
    data *              ={0,  54,  -2,  55,   0,  61,   1,  64}
    data *              ={0,  68,  -9,  92}
    data *436-459       ={-14, 106, -13,  97, -15,  90, -12,  90}
    data *              ={-18,  88, -10,  73, -9,  79, -14,  86}
    data *              ={-10,  73, -10,  70, -10,  69, -5,  66}
    data *              ={-9,  64, -5,  58,  2,  59, 21, -10}
    data *              ={24, -11, 28,  -8, 28,  -1, 29,   3}
    data *              ={29,   9, 35,  20, 29,  36, 14,  67}
    data cabac_I^context_0_10
    return cabac_I
endfunction

function avc_cabac_context_init_P()
    #[460][2]
    data context_0_10={20, -15,    2,  54,    3,  74,   20, -15}
    data *           ={2,  54,    3,  74,  -28, 127,  -23, 104}
    data *           ={-6,  53,   -1,  54,    7,  51}
    data *11-23      ={23,  33,   23,   2,   21,   0,    1,   9}
    data *           ={0,  49,  -37, 118,    5,  57,  -13,  78}
    data *           ={-11,  65,    1,  62,   12,  49,   -4,  73}
    data *           ={17,  50}
    data *24-39      ={18,  64,    9,  43,   29,   0,   26,  67}
    data *           ={16,  90,    9, 104,  -46, 127,  -20, 104}
    data *           ={1,  67,  -13,  78,  -11,  65,    1,  62}
    data *           ={-6,  86,  -17,  95,   -6,  61,    9,  45}
    data *40-53      ={-3,  69,   -6,  81,  -11,  96,    6,  55}
    data *           ={7,  67,   -5,  86,    2,  88,    0,  58}
    data *           ={-3,  76,  -10,  94,    5,  54,    4,  69}
    data *           ={-3,  81,    0,  88}
    data *54-59      ={-7,  67,   -5,  74,   -4,  74,   -5,  80}
    data *           ={-7,  72,    1,  58}
    data *60-69      ={0,  41,    0,  63,    0,  63,  0, 63}
    data *           ={-9,  83,    4,  86,    0,  97,  -7, 72}
    data *           ={13,  41,    3,  62}
    data *70-87      ={0,  45,   -4,  78,   -3,  96,  -27,  126}
    data *           ={-28,  98,  -25, 101,  -23,  67,  -28,  82}
    data *           ={-20,  94,  -16,  83,  -22, 110,  -21,  91}
    data *           ={-18, 102,  -13,  93,  -29, 127,   -7,  92}
    data *           ={-5,  89,   -7,  96,  -13, 108,   -3,  46}
    data *           ={-1,  65,   -1,  57,   -9,  93,   -3,  74}
    data *           ={-9,  92,   -8,  87,  -23, 126,    5,  54}
    data *           ={6,  60,    6,  59,    6,  69,   -1,  48}
    data *           ={0,  68,   -4,  69,   -8,  88}
    data *105-165    ={-2,  85,   -6,  78,   -1,  75,   -7,  77}
    data *           ={2,  54,    5,  50,   -3,  68,    1,  50}
    data *           ={6,  42,   -4,  81,    1,  63,   -4,  70}
    data *           ={0,  67,    2,  57,   -2,  76,   11,  35}
    data *           ={4,  64,    1,  61,   11,  35,   18,  25}
    data *           ={12,  24,   13,  29,   13,  36,  -10,  93}
    data *           ={-7,  73,   -2,  73,   13,  46,    9,  49}
    data *           ={-7, 100,    9,  53,    2,  53,    5,  53}
    data *           ={-2,  61,    0,  56,    0,  56,  -13,  63}
    data *           ={-5,  60,   -1,  62,    4,  57,   -6,  69}
    data *           ={4,  57,   14,  39,    4,  51,   13,  68}
    data *           ={3,  64,    1,  61,    9,  63,   7,  50}
    data *           ={16,  39,    5,  44,    4,  52,   11,  48}
    data *           ={-5,  60,   -1,  59,   0,  59,   22,  33}
    data *           ={5,  44,   14,  43,   -1,  78,    0,  60}
    data *           ={9,  69}
    data *166 - 226  ={11,  28,    2,  40,    3,  44,    0,  49}
    data *           ={0,  46,    2,  44,    2,  51,    0,  47}
    data *           ={4,  39,    2,  62,    6,  46,    0,  54}
    data *           ={3,  54,    2,  58,    4,  63,    6,  51}
    data *           ={6,  57,    7,  53,    6,  52,    6,  55}
    data *           ={11,  45,  14,  36,    8,  53,   -1,  82}
    data *           ={7,  55,   -3,  78,   15,  46,   22,  31}
    data *           ={-1,  84,   25,   7,   30,  -7,   28,   3}
    data *           ={28,   4,   32,   0,   34,  -1,   30,   6}
    data *           ={30,   6,   32,   9,   31,  19,   26,  27}
    data *           ={26,  30,   37,  20,   28,  34,   17,  70}
    data *           ={1,  67,    5,  59,    9,  67,   16,  30}
    data *           ={18,  32,   18,  35,   22,  29,   24,  31}
    data *           ={23,  38,   18,  43,   20,  41,   11,  63}
    data *           ={9,  59,    9,  64,   -1,  94,   -2,  89}
    data *           ={-9, 108}
    data *227 - 275  ={-6,  76,   -2,  44,    0,  45,    0,  52}
    data *           ={-3,  64,   -2,  59,   -4,  70,   -4,  75}
    data *           ={-8,  82,  -17, 102,   -9,  77,    3,  24}
    data *           ={0,  42,    0,  48,    0,  55,   -6,  59}
    data *           ={-7,  71,  -12,  83,  -11,  87,  -30, 119}
    data *           ={1,  58,   -3,  29,   -1,  36,    1,  38}
    data *           ={2,  43,   -6,  55,    0,  58,    0,  64}
    data *           ={-3,  74,  -10,  90,    0,  70,   -4,  29}
    data *           ={5,  31,    7,  42,    1,  59,   -2,  58}
    data *           ={-3,  72,   -3,  81,  -11,  97,    0,  58}
    data *           ={8,   5,  10,  14,   14,  18,   13,  27}
    data *           ={2,  40,    0,  58,   -3,  70,   -6,  79}
    data *           ={-8,  85}
    #276 (not used, x264_cabac_encode_bypass is used instead)
    data *           ={0, 0}
    data *277 - 337  ={-13, 106,  -16, 106,  -10,  87,  -21, 114}
    data *           ={-18, 110,  -14,  98,  -22, 110,  -21, 106}
    data *           ={-18, 103,  -21, 107,  -23, 108,  -26, 112}
    data *           ={-10,  96,  -12,  95,   -5,  91,   -9,  93}
    data *           ={-22,  94,   -5,  86,    9,  67,   -4,  80}
    data *           ={-10,  85,   -1,  70,    7,  60,    9,  58}
    data *           ={5,  61,   12,  50,   15,  50,   18,  49}
    data *           ={17,  54,   10,  41,    7,  46,   -1,  51}
    data *           ={7,  49,    8,  52,    9,  41,    6,  47}
    data *           ={2,  55,   13,  41,   10,  44,    6,  50}
    data *           ={5,  53,   13,  49,    4,  63,    6,  64}
    data *           ={-2,  69,   -2,  59,    6,  70,   10,  44}
    data *           ={9,  31,   12,  43,    3,  53,   14,  34}
    data *           ={10,  38,   -3,  52,   13,  40,   17,  32}
    data *           ={7,  44,    7,  38,   13,  50,   10,  57}
    data *           ={26,  43}
    data *338 - 398  ={14,  11,   11,  14,    9,  11,   18,  11}
    data *           ={21,   9,   23,  -2,   32, -15,   32, -15}
    data *           ={34, -21,   39, -23,   42, -33,   41, -31}
    data *           ={46, -28,   38, -12,   21,  29,   45, -24}
    data *           ={53, -45,   48, -26,   65, -43,   43, -19}
    data *           ={39, -10,   30,   9,   18,  26,   20,  27}
    data *           ={0,  57,  -14,  82,   -5,  75,  -19,  97}
    data *           ={-35, 125,   27,   0,   28,   0,   31,  -4}
    data *           ={27,   6,   34,   8,   30,  10,   24,  22}
    data *           ={33,  19,   22,  32,   26,  31,   21,  41}
    data *           ={26,  44,   23,  47,   16,  65,   14,  71}
    data *           ={8,  60,    6,  63,   17,  65,   21,  24}
    data *           ={23,  20,   26,  23,   27,  32,   28,  23}
    data *           ={28,  24,   23,  40,   24,  32,   28,  29}
    data *           ={23,  42,   19,  57,   22,  53,   22,  61}
    data *           ={11,  86}
    data *399 - 435  ={12,  40,   11,  51,   14,  59}
    data *           ={-4,  79,   -7,  71,   -5,  69,   -9,  70}
    data *           ={-8,  66,  -10,  68,  -19,  73,  -12,  69}
    data *           ={-16,  70,  -15,  67,  -20,  62,  -19,  70}
    data *           ={-16,  66,  -22,  65,  -20,  63,    9,  -2}
    data *           ={26,  -9,   33,  -9,   39,  -7,   41,  -2}
    data *           ={45,   3,   49,   9,   45,  27,   36,  59}
    data *           ={-6,  66,   -7,  35,   -7,  42,   -8,  45}
    data *           ={-5,  48,  -12,  56,   -6,  60,   -5,  62}
    data *           ={-8,  66,   -8,  76}
    data *436 - 459  ={-5,  85,   -6,  81,  -10,  77,   -7,  81}
    data *           ={-17,  80,  -18,  73,   -4,  74,  -10,  83}
    data *           ={-9,  71,   -9,  67,   -1,  61,   -8,  66}
    data *           ={-14,  66,    0,  59,    2,  59,   21, -13}
    data *           ={33, -14,   39,  -7,   46,  -2,   51,   2}
    data *           ={60,   6,   61,  17,   55,  34,   42,  62}
    data cabac_P^context_0_10
    return cabac_P
endfunction


function avc_cabac_range_lps(sd a,sd b)
    #[64][4]
    data cabac_range={128, 176, 208, 240, 128, 167, 197, 227, 128, 158, 187, 216}
    data *          ={123, 150, 178, 205, 116, 142, 169, 195, 111, 135, 160, 185}
    data *          ={105, 128, 152, 175, 100, 122, 144, 166,  95, 116, 137, 158}
    data *          ={90, 110, 130, 150,  85, 104, 123, 142,  81,  99, 117, 135}
    data *          ={77,  94, 111, 128,  73,  89, 105, 122,  69,  85, 100, 116}
    data *          ={66,  80,  95, 110,  62,  76,  90, 104,  59,  72,  86,  99}
    data *          ={56,  69,  81,  94,  53,  65,  77,  89,  51,  62,  73,  85}
    data *          ={48,  59,  69,  80,  46,  56,  66,  76,  43,  53,  63,  72}
    data *          ={41,  50,  59,  69,  39,  48,  56,  65,  37,  45,  54,  62}
    data *          ={35,  43,  51,  59,  33,  41,  48,  56,  32,  39,  46,  53}
    data *          ={30,  37,  43,  50,  29,  35,  41,  48,  27,  33,  39,  45}
    data *          ={26,  31,  37,  43,  24,  30,  35,  41,  23,  28,  33,  39}
    data *          ={22,  27,  32,  37,  21,  26,  30,  35,  20,  24,  29,  33}
    data *          ={19,  23,  27,  31,  18,  22,  26,  30,  17,  21,  25,  28}
    data *          ={16,  20,  23,  27,  15,  19,  22,  25,  14,  18,  21,  24}
    data *          ={14,  17,  20,  23,  13,  16,  19,  22,  12,  15,  18,  21}
    data *          ={12,  14,  17,  20,  11,  14,  16,  19,  11,  13,  15,  18}
    data *          ={10,  12,  15,  17,  10,  12,  14,  16,   9,  11,  13,  15}
    data *          ={9,  11,  12,  14,   8,  10,  12,  14,   8,   9,  11,  13}
    data *          ={7,   9,  11,  12,   7,   9,  10,  12,   7,   8,  10,  11}
    data *          ={6,   8,   9,  11,   6,   7,   9,  10,   6,   7,   8,   9}
    data *          ={2,   2,   2,   2}
    sd cabac^cabac_range
    mult a (4*4)
    mult b 4
    add cabac a
    add cabac b
    return cabac#
endfunction

function avc_transition_lps(sd a)
    #[64]
    data transition={0, 0, 1, 2, 2, 4, 4, 5, 6, 7, 8, 9, 9,11,11,12}
    data *         ={13,13,15,15,16,16,18,18,19,19,21,21,22,22,23,24}
    data *         ={24,25,26,26,27,27,28,29,29,30,30,30,31,32,32,33}
    data *         ={33,33,34,34,35,35,35,36,36,36,37,37,37,38,38,63}
    sd trans^transition
    mult a 4
    add trans a
    return trans#
endfunction

function avc_transition_mps(sd a)
    #[64]
    data transition={1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14,15,16}
    data *         ={17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32}
    data *         ={33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48}
    data *         ={49,50,51,52,53,54,55,56,57,58,59,60,61,62,62,63}
    sd trans^transition
    mult a 4
    add trans a
    return trans#
endfunction

import "avc_mb_nr_left" avc_mb_nr_left
import "avc_mb_nr_top" avc_mb_nr_top

function avc_mb_write_cabac(sd slice_type)
    #Write the MB type
    call avc_mb_type(slice_type)

    #write chroma pred mode
    call avc_mb_intra_chroma_pred_mode()

    #i_cbp_luma > 0 || i_cbp_chroma > 0 || i_mb_type == I_16x16
    import "avc_residual_luma" avc_residual_luma
    import "avc_residual_write" avc_residual_write
    import "avc_cbp_luma" avc_cbp_luma
    call avc_mb_qp_delta()
    #dc luma
    sd residual_luma
    setcall residual_luma avc_residual_luma()
                                             #,idx=0
    call avc_residual_write(residual_luma,0,16)
    #ac luma
    sd i
    sd cbp_luma
    setcall cbp_luma avc_cbp_luma((value_get))
    if cbp_luma!=0
        import "avc_residual_ac" avc_residual_ac
        sd residual_ac
        setcall residual_ac avc_residual_ac((value_get))
        set i 0
        while i!=16
            call avc_residual_write(residual_ac,1,15,i)
            add residual_ac (15*DWORD)
            inc i
        endwhile
    endif

    #Chroma DC residual present
    import "avc_cbp_chroma" avc_cbp_chroma
    sd cbp_chroma
    setcall cbp_chroma avc_cbp_chroma((value_get))
    sd value
    set value cbp_chroma
    and value 3
    if value!=0
        import "avc_chroma_dc_u" avc_chroma_dc_u
        import "avc_chroma_dc_v" avc_chroma_dc_v
        sd chroma_dc_u
        sd chroma_dc_v
        setcall chroma_dc_u avc_chroma_dc_u()
        setcall chroma_dc_v avc_chroma_dc_v()
        call avc_residual_write(chroma_dc_u,3,4,0)
        call avc_residual_write(chroma_dc_v,3,4,1)
    endif

    #Chroma AC residual present
    set value cbp_chroma
    and value 2
    if value!=0
        import "avc_residual_ac_ch" avc_residual_ac_ch
        sd residual_ac_ch
        setcall residual_ac_ch avc_residual_ac_ch()
        set i 0
        while i<8
            call avc_residual_write(residual_ac_ch,4,15,i)
            add residual_ac_ch (15*DWORD)
            inc i
        endwhile
    endif
endfunction

function avc_mb_type(sd slice_type)
    sd mb_nr_left
    sd mb_nr_top
    if slice_type==(SLICE_TYPE_I)
        setcall mb_nr_left avc_mb_nr_left((value_get))
        setcall mb_nr_top avc_mb_nr_top((value_get))
        sd ctx=0
        if mb_nr_left>0
            inc ctx
        endif
        if mb_nr_top>0
            inc ctx
        endif
        sd value
        set value ctx
        add value 3
        call avc_mb_type_intra(value,(3+3),(3+4),(3+5),(3+6),(3+7))
    else
        #prefix
        call avc_cabac_decision(14,1)
        #suffix
        call avc_mb_type_intra((17+0),(17+1),(17+2),(17+2),(17+3),(17+3))
    endelse
endfunction

function avc_mb_type_intra(sd ctx0,sd ctx1,sd ctx2,sd ctx3,sd ctx4,sd ctx5)
    call avc_cabac_decision(ctx0,1)
    call avc_cabac_terminal(0)
    sd cbp_luma
    setcall cbp_luma avc_cbp_luma((value_get))
    if cbp_luma==0
        call avc_cabac_decision(ctx1,0)
    else
        call avc_cabac_decision(ctx1,1)
    endelse

    sd cbp_chroma
    setcall cbp_chroma avc_cbp_chroma((value_get))
    if cbp_chroma==0
        call avc_cabac_decision(ctx2,0)
    else
        call avc_cabac_decision(ctx2,1)
        if cbp_chroma==1
            call avc_cabac_decision(ctx3,0)
        else
            call avc_cabac_decision(ctx3,1)
        endelse
    endelse

    sd i_intra16x16_pred_mode=I_PRED_16x16_DC
    import "rest" rest
    sd pred_mode_rest
    setcall pred_mode_rest rest(i_intra16x16_pred_mode,2)
    div i_intra16x16_pred_mode 2
    if i_intra16x16_pred_mode!=0
        call avc_cabac_decision(ctx4,1)
    else
        call avc_cabac_decision(ctx4,0)
    endelse
    call avc_cabac_decision(ctx5,pred_mode_rest)
endfunction

import "avc_cabac_ctxstate_value" avc_cabac_ctxstate_value
import "avc_cabac_ctxstate_value_set" avc_cabac_ctxstate_value_set
import "avc_cabac_range" avc_cabac_range
import "avc_cabac_low" avc_cabac_low
import "avc_cabac_sym_cnt" avc_cabac_sym_cnt

function avc_cabac_decision(sd ctx,sd b)
    sd state
    setcall state avc_cabac_ctxstate_value(ctx,(avc_ctxstate_state))
    sd mps
    setcall mps avc_cabac_ctxstate_value(ctx,(avc_ctxstate_mps))
    sd range
    setcall range avc_cabac_range((value_get))
    sd i_range
    set i_range range
    setcall i_range sar(range,6)
    and i_range 0x03
    sd range_lps
    setcall range_lps avc_cabac_range_lps(state,i_range)

    sub range range_lps
    call avc_cabac_range((value_set),range)
    sd value
    if b!=mps
        sd low
        setcall low avc_cabac_low((value_get))
        add low range
        call avc_cabac_low((value_set),low)
        call avc_cabac_range((value_set),range_lps)
        if state==0
            set value 1
            sub value mps
            call avc_cabac_ctxstate_value_set(ctx,(avc_ctxstate_mps),value)
        endif
        setcall value avc_transition_lps(state)
        call avc_cabac_ctxstate_value_set(ctx,(avc_ctxstate_state),value)
    else
        setcall value avc_transition_mps(state)
        call avc_cabac_ctxstate_value_set(ctx,(avc_ctxstate_state),value)
    endelse
    setcall value avc_cabac_ctxstate_value(ctx,(avc_ctxstate_count))
    inc value
    call avc_cabac_ctxstate_value_set(ctx,(avc_ctxstate_count),value)

    call avc_cabac_encode_renorm()

    setcall value avc_cabac_sym_cnt((value_get))
    inc value
    call avc_cabac_sym_cnt((value_set),value)
endfunction

import "avc_cabac_bits_outstanding" avc_cabac_bits_outstanding

function avc_cabac_encode_renorm()
    sd range
    setcall range avc_cabac_range((value_get))
    sd low
    setcall low avc_cabac_low((value_get))
    while range<0x0100
        if low<0x100
            call avc_cabac_putbit(0)
        else
            if low>=0x200
                sub low 0x200
                call avc_cabac_low((value_set),low)
                call avc_cabac_putbit(1)
            else
                sub low 0x100
                call avc_cabac_low((value_set),low)
                sd bits
                setcall bits avc_cabac_bits_outstanding((value_get))
                inc bits
                call avc_cabac_bits_outstanding((value_set),bits)
            endelse
        endelse
        setcall range shl(range,1)
        call avc_cabac_range((value_set),range)
        setcall low shl(low,1)
        call avc_cabac_low((value_set),low)
    endwhile
endfunction

import "avc_bs_write_bit" avc_bs_write_bit

import "avc_cabac_first_bit" avc_cabac_first_bit

function avc_cabac_putbit(sd bit)
    sd first_bit
    setcall first_bit avc_cabac_first_bit((value_get))
    if first_bit!=0
        call avc_cabac_first_bit((value_set),0)
    else
        call avc_bs_write_bit(bit)
    endelse
    sd bits
    setcall bits avc_cabac_bits_outstanding((value_get))
    sd b
    set b 1
    sub b bit
    while bits>0
        call avc_bs_write_bit(b)
        dec bits
    endwhile
    call avc_cabac_bits_outstanding((value_set),bits)
endfunction
function avc_cabac_bypass(sd b)
    sd low
    setcall low avc_cabac_low((value_get))
    mult low 2
    call avc_cabac_low((value_set),low)
    if b!=0
        sd range
        setcall range avc_cabac_range((value_get))
        add low range
        call avc_cabac_low((value_set),low)
    endif

    if low>=0x400
        call avc_cabac_putbit(1)
        sub low 0x400
        call avc_cabac_low((value_set),low)
    else
        if low<0x200
            call avc_cabac_putbit(0)
        else
            sub low 0x200
            call avc_cabac_low((value_set),low)
            sd bits_outstanding
            setcall bits_outstanding avc_cabac_bits_outstanding((value_get))
            inc bits_outstanding
            call avc_cabac_bits_outstanding((value_set),bits_outstanding)
        endelse
    endelse
    sd sym
    setcall sym avc_cabac_sym_cnt((value_get))
    inc sym
    call avc_cabac_sym_cnt((value_set),sym)
endfunction
function avc_cabac_terminal(sd b)
    sd range
    setcall range avc_cabac_range((value_get))
    sub range 2
    call avc_cabac_range((value_set),range)
    if b!=0
        sd low
        setcall low avc_cabac_low((value_get))
        add low range
        call avc_cabac_low((value_set),low)
        call avc_cabac_range((value_set),2)
    endif
    call avc_cabac_encode_renorm()
    sd value
    setcall value avc_cabac_sym_cnt((value_get))
    inc value
    call avc_cabac_sym_cnt((value_set),value)
endfunction


#write chroma pred mode
function avc_mb_intra_chroma_pred_mode()
    #sd pred_mode8x8c=I_PRED_CHROMA_DC
    sd ctx=0
    sd value
    set value ctx
    add value 64
    call avc_cabac_decision(value,0)
endfunction

function avc_mb_qp_delta()
    sd ctx=0
    sd value
    set value 60
    add value ctx
    call avc_cabac_decision(value,0)
endfunction
