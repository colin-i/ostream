
format elf obj

include "../_include/include.h"

import "gtk_init" gtk_init
import "gst_init" gst_init
import "initfn" initfn
import "gtk_main" gtk_main
import "exit" exit

entry _start()

call gtk_init(0,0)
call gst_init(0,0)

const LC_NUMERIC=4
import "setlocale" setlocale
call setlocale((LC_NUMERIC),"English")

import "g_thread_init" g_thread_init
call g_thread_init(0)

import "gstset" gstset
call gstset()
import "link_mass_remove" link_mass_remove
call link_mass_remove((value_set),0)
import "capture_terminal" capture_terminal
call capture_terminal((value_set),0)
import "sound_preview_bool" sound_preview_bool
sd sound_prev
setcall sound_prev sound_preview_bool()
set sound_prev# 0

call initfn()

call gtk_main()

import "gstunset" gstunset
import "search_clear_memory" search_clear_memory
call gstunset()
call search_clear_memory()

#gtk_main reaction
call exit((TRUE))
return (TRUE)

