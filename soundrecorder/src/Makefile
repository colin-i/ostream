
ifndef OCOMP
OCOMP=o
endif

ifndef linkerflags
linkerflags=-O1 -s
endif

OFLAGS = inplace_reloc 0

projname=soundrecorder
objname=${projname}.o
srcname=${projname}.s
logname=${srcname}.log
wprojname=${projname}.exe

all: ${wprojname}

%.o: %.s
	${OCOMP} $< ${OFLAGS}

${wprojname}: ${objname}
	ounused ${logname}
	@echo
	i686-w64-mingw32-ld ${linkerflags} ${objname} -o ${wprojname} -entry record \
		 -lmsvcrt -lkernel32 -lwinmm -luser32

clean:
	-rm -f ${logname}
	-rm -f ${objname}
	-rm -f ${wprojname}

distclean: clean

test:
	echo "Nothing"

.PHONY: all clean distclean test

