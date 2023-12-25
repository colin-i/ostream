o.exe "src/record.oc"
ld -mi386pe -e record -s -o ./soundrec.exe ./src/record.o -lmsvcrt -lkernel32 -lwinmm -luser32
