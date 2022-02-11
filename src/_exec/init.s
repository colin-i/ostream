
format elfobj

include "../_include/include.h" #files/olang.h
include "../_include/lin.h" "../_include/win.h"

const F_OK=0

importx "_strlen" strlen
importx "_access" access
importx "_mkdir" mkdir
importx "_getcwd" getcwd
importx "_free" free

import "capture_location" capture_location
import "sys_folder" sys_folder
import "chdr" chdr

#err
function init_user()
	sd d
	setcall d capture_location()
	sd err
	setcall err init_dir(d)
	if err==(noerror)
		setcall d sys_folder()
		setcall err init_dir(d)
		if err==(noerror)
			sd p
			setcall p getcwd((NULL),0)
			if p!=(NULL)
				vstr cerr="chdir error at init user"
				sd x
				setcall x chdr(d)
				if x==0
					setcall err init_user_sys()
					setcall x chdr(p)
					if x!=0
						set err cerr
					endif
				else
					set err cerr
				endelse
				call free(p)
			else
				set err "getcwd error at init user"
			endelse
		endif
	endif
	return err
endfunction
#e
function init_user_sys()
	const start=!
	chars a="capture" #biggest
	const d1=!
	chars *={0x00,0x00,0x00,0x00,0x00,0x01,0x00,0x00,0x00,0x01,0x00,0x00,0x00,0x01,0x00,0x00,0x00}
	const d11=!-d1
	chars *="jpeg"
	const d2=!
	chars *={0x20,0x03,0x00,0x00}
	const d22=!-d2
	chars *="mpeg"
	const d3=!
	chars *={0x03,0x00,0x00,0x00,0x03,0x00,0x00,0x00}
	const d33=!-d3
	chars *="search"
	const d4=!
	chars *={0x73,0x72,0x63,0x3d,0x22,0x00,0x22,0x00,0x00,0x00}
	const d44=!-d4
	chars *="sound"
	const d5=!
	chars *={0x02,0x00,0x00,0x00,0x80,0xbb,0x00,0x00,0x10,0x00,0x00,0x00}
	const d55=!-d5
	chars *="stage"
	const d6=!
	chars *={0x0a,0x00,0x00,0x00,0x01,0x00,0x00,0x00,0x01,0x00,0x00,0x00}
	const d66=!-d6
	chars *="update"
	const d7=!
	chars *={0x01,0x00,0x00,0x00}
	const d77=!-d7
	sd b=!-start
	sd c^a
	add b c
	chars e={d11,d22,d33,d44,d55,d66,d77}
	ss f^e
	sd err=noerror
	while c!=b
		setcall c init_sys(c,f#,#err)
		if err!=(noerror)
			return err
		endif
		inc f
	endwhile
	return (noerror)
endfunction

function init_sys(sd c,sd sz,sd *perr)
	sd len
	setcall len strlen(c)
	add c len
	inc c
	add c sz
	return c
endfunction

#er
function init_dir(ss f)
	sd is
	setcall is access(f,(F_OK))
	#this looks useless check but we want mkdir to return success, then, it is ok, ignoring mkdir by others between these calls
	if is==-1
		setcall is mkdir(f,(flag_dmode))
		if is!=0
			return "mkdir error"
		endif
	endif
	return (noerror)
endfunction
