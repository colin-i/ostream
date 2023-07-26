
#entry _WinMain@16()
entry _start()

import "init_args" init_args

sd cmp;setcall cmp init_args()

if cmp!=0
	call gst_init(0,0)
