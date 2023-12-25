
ifndef OCOMP
OCOMP=o
endif

ifndef linkerflags
linkerflags=-O3 -s
#             1
endif

OFLAGS = inplace_reloc 0 ${OFLAGSEXTRA}

projname=soundrecorder
objname=${projname}.o
srcname=${projname}.oc
logname=${srcname}.log
wprojname=${projname}.exe

all: ${wprojname}

%.o: %.oc
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

