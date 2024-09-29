
ifndef OCOMP
OCOMP=o
endif

ifndef linkerflags
linkerflags=-O3 -s
#             1
endif

OFLAGS = inplace_reloc 0

projname=soundrecorder
objname=${projname}.o
srcname=${projname}.oc
logname=${srcname}.log
wprojname=${projname}.exe

all: compile link

compile: ${projname} ounused

ounused:
	ounused ${logname}

link:
	i686-w64-mingw32-ld ${linkerflags} ${objname} -o ${wprojname} -entry record \
		 -lmsvcrt -lkernel32 -lwinmm -luser32

%: %.oc
	${OCOMP} $< ${OFLAGS}

clean:
	-rm -f ${logname}
	-rm -f ${objname}
	-rm -f ${wprojname}

distclean: clean

test:
	echo "Nothing"

.PHONY: all compile ounused link clean distclean test
.NOTPARALLEL:
