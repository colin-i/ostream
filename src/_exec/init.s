
format elfobj

include "../_include/include.h" #files/olang.h

importx "_strlen" strlen
importx "_access" access
importx "_mkdir" mkdir
importx "_getcwd" getcwd
importx "_free" free
importx "_open" open
importx "_write" write
importx "_close" close
importx "_sprintf" sprintf

import "capture_location" capture_location
import "sys_folder" sys_folder
import "chdr" chdr
import "move_to_home" move_to_home

#err
function init_user()
	sd err
	setcall err move_to_home()
	if err==(noerror)
		sd d
		setcall d capture_location()
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
						setcall err init_user_sys((NULL))
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
	endif
	return err
endfunction
#e
function init_user_sys(sv forward)
	const start=!
	char a="capture"
	const biggest_string=7
	const d1=!
	char *={0x00,0x00,0x00,0x00,0x00,0x01,0x00,0x00,0x00,0x01,0x00,0x00,0x00,0x01,0x00,0x00,0x00}
	const d11=!-d1
	char *="jpeg"
	const d2=!
	char *={0x20,0x03,0x00,0x00}
	const d22=!-d2
	char *="mpeg"
	const d3=!
	char *={0x03,0x00,0x00,0x00,0x03,0x00,0x00,0x00}
	const d33=!-d3
	char *="search"
	const d4=!
	char *={0x73,0x72,0x63,0x3d,0x22,0x00,0x22,0x00,0x00,0x00}
	const d44=!-d4
	char *="sound"
	const d5=!
	char *={0x02,0x00,0x00,0x00,0x80,0xbb,0x00,0x00,0x10,0x00,0x00,0x00}
	const d55=!-d5
	char *="stage"
	const d6=!
	char *={0x0a,0x00,0x00,0x00,0x01,0x00,0x00,0x00,0x01,0x00,0x00,0x00}
	const d66=!-d6
	char *="update"
	const d7=!
	char *={0x01,0x00,0x00,0x00}
	const d77=!-d7
	sd b=!-start
	sd c^a
	add b c
	char e={d11,d22,d33,d44,d55,d66,d77}
	ss f^e
	sd err=noerror
	while c!=b
		setcall c init_sys(c,f#,#err,forward)
		if err!=(noerror)
			return err
		endif
		inc f
	endwhile
	return (noerror)
endfunction

function init_sys(sd c,sd sz,sd perr,sv forward)
	sd len
	setcall len strlen(c)
	sd f
	set f c
	add c len
	inc c
	call init_sys_file(f,c,sz,perr,forward)
	add c sz
	return c
endfunction

#er
function init_dir(sd f)
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

function init_sys_file(sd f,sd data,sd sz,sv perr,sv forward)
	char buf#biggest_string+1+4+1
	call sprintf(#buf,"%s.data",f)
	sd is
	setcall is access(#buf,(F_OK))
	if forward==(NULL)
		if is==-1
			#open
			const O_WRONLY=0x0001
			sd fd
			setcall fd open(#buf,(O_WRONLY|flag_O_BINARY|flag_O_CREAT),(flag_fmode))
			#write
			sd len
			setcall len write(fd,data,sz)
			#close
			call close(fd)
			if len!=sz
				set perr# "write error at init user"
			endif
		endif
	else
		if is==0
			call forward(#buf)
		endif
	endelse
endfunction


#d
function uninit_folder(sd fn)
	sd d;sd a
	setcall d fn()
	setcall a access(d,(F_OK))
	if a==0
		return d
	endif
	return (NULL)
endfunction

importx "_printf" printf
import "sys_folder_enterleave" sys_folder_enterleave

function uninit_sys_print()
	call init_user_sys(uninit_print_entry)
endfunction
import "real_path" real_path
function uninit_print_entry(sd f)
	sd p;setcall p real_path(f)
	if p!=(NULL)
		call printf(p)
		call printf("\n")
		call free(p)
	endif
endfunction
#sys folder
function uninit_print(sv p_c)
	call printf("Would remove:\n") #on linux there is main folder already
	sd c;setcall c uninit_folder(capture_location)
	sd s;setcall s uninit_folder(sys_folder)
	if c!=(NULL)
		call uninit_print_entry(c)
	endif
	if s!=(NULL)
		call uninit_print_entry(s)
		call sys_folder_enterleave(uninit_sys_print)
	endif
	set p_c# c
	return s
endfunction
