
entryraw _start(sd argc,sv argv)


import "init_args" init_args
sd bool;setcall bool init_args(argc,#argv)
if bool!=(FALSE)
	importx "access" access
	import "move_to_share_core" move_to_share_core
	ss testfile="regforkoff"
	call move_to_share_core(#testfile)
	sd is
	setcall is access(testfile,(F_OK))
	if is=-1
		call gst_init(0,(NULL))
	else
		#this is because fedora will wrong all plugin cache on 64 for 32
		sd argv0
		ss *argv1="--gst-disable-registry-fork"
		set argv0 argv
		set argc 2
		set argv #argv0
		call gst_init(#argc,#argv)
	endelse
