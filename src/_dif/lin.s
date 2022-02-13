
importx "getpid" getpid
importx "kill" kill
sd pid
setcall pid getpid()
call kill(pid,9)

