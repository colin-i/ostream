
OCOMP=o
syms=-s
OFLAGS = inplace_reloc 0

projname=soundrecorder
objname=${projname}.o
srcname=${projname}.s
logname=${srcname}.log
wprojname=${projname}.exe

all: ${objname} ${wprojname}

%.o: %.s
	${OCOMP} $< ${OFLAGS}

${wprojname}:
	ounused ${logname}
	@echo
	i686-w64-mingw32-ld ${syms} ${objname} -o ${wprojname} -entry record \
		 -lmsvcrt -lkernel32 -lwinmm -luser32

clean:
	-rm -f ${logname}
	-rm -f ${objname}
	-rm -f ${wprojname}

distclean: clean

test:
	echo "Nothing"

.PHONY: all clean distclean test

