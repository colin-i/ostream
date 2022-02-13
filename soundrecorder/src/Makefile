
OCOMP=o
syms=-s
OFLAGS = inplace_reloc 0

projname=soundrecorder
objname=${projname}.o
srcname=${projname}.s
logname=${srcname}.log
wprojname=${projname}.exe

all: compile link

compile: ${projname} ounused

ounused:
	ounused ${logname}

lnk:
	i686-w64-mingw32-ld ${syms} ${objname} -o ${wprojname} -entry record --start-group \
		`dpkg -L mingw-w64-i686-dev | grep '\.a' | sed 's/..$$//' | grep -o '[^\/]*$$' | sed 's/lib/-l/' | xargs echo` \
		--end-group; \

%: %.s
	${OCOMP} $< ${OFLAGS}

clean:
	-rm -f ${logname}
	-rm -f ${objname}
	-rm -f ${wprojname}

distclean: clean

test:
	echo "Nothing"

.PHONY: all clean distclean test

