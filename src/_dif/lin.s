
#exit() do segmentation nowadays (in this context)

importx "getpid" getpid
importx "kill" kill
sd pid
setcall pid getpid()
call kill(pid,9)

