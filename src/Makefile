
platform = lin
OCOMP=o
syms=-s

ifeq (${platform},win)
	OFLAGS = inplace_reloc 0 include_sec 1
else
	OFLAGS =
	# underscore_pref 1
endif

cap = _capture/capture
err = err/err
eve = event/event
e=_exec/
exe = ${e}capture/save ${e}help ${e}mainhandles ${e}mediainfo ${e}mix ${e}ostream ${e}start ${e}uri ${e}uristream
f=file-folder/
ffl = ${f}file-base ${f}folder-base
gnu = gnu/gst
int = interface/buttons
m=media/
med = ${m}audiovideo ${m}mp4 ${m}mpeg-avc_data ${m}mpeg_code ${m}mpeg-mp3_bs ${m}mpeg-mp3_input ${m}mpeg-mp3_tables \
${m}jpeg_enc ${m}mpeg-avc_action ${m}mpeg-avc_encode ${m}mpeg_enc ${m}mpeg-mp3_data ${m}mpeg-mp3_iteration_code ${m}mpeg-mp3_wrap \
${m}jpeg ${m}mpeg-avc_block ${m}mpeg-avc_mb ${m}mpeg_init ${m}mpeg-mp3_encode ${m}mpeg-mp3_iteration ${m}mpeg_pred \
${m}mp4_data ${m}mpeg-avc_bs ${m}mpeg-avc_wrap ${m}mpeg_interframe ${m}mpeg-mp3_huffman ${m}mpeg-mp3_mdct ${m}mpeg
mem = mem/alloc mem/op
net = net/net-base
o=obj/
obj = ${o}containers ${o}images ${o}items ${o}tool
p=_prepare/
pe=${p}effect/
pf=${p}frame/
po=${p}output/
pre = ${pe}base ${pe}fade ${pe}move ${pe}reveal_diagonal ${pe}reveal ${pe}reveal_shape ${pe}scale_effect \
${pf}add ${pf}brightness ${pf}crop ${pf}frame ${pf}frametime ${pf}imagetools ${pf}overlay ${pf}pencil ${pf}remove ${pf}rotate ${pf}scale ${pf}screenshot \
${po}all ${po}avi ${po}mkv ${po}sound ${po}stagefileoptions \
${p}paint ${p}pipe ${p}prevw ${p}sel ${p}stagempeg ${p}view
s=_search/
sea = ${s}dialog_fns ${s}dialog ${s}parse ${s}previews
str = str/str
u=util/
uti = ${u}asm ${u}floating ${u}lists ${u}numbers ${u}update ${u}util
items = _dif/dif~${platform} ${cap} ${err} ${eve} ${exe} ${ffl} ${gnu} ${int} ${med} ${mem} ${net} ${obj} ${pre} ${sea} ${str} ${uti}

projname=ovideo
wprojname=ovideo.exe
logs :=
obs :=

all: ${items} ounused lnk

ounused:
	ounused ${logs}

lnk:
	if [ "${platform}" = "lin" ]; then \
		$(LD) ${syms} -melf_i386 --dynamic-linker=/lib/ld-linux.so.2 ${obs} -lc -o ${projname}; \
	else \
		i686-w64-mingw32-ld ${syms} ${obs} -lmsvcrt -o ${wprojname}; \
	fi


%: %.s
	${OCOMP} $< ${OFLAGS}
	$(eval logs += $@.s.log)
	$(eval obs += $@.o)

clean:
	-printf ' %s.s.log' ${items} | xargs rm -f
	-printf ' %s.o' ${items} | xargs rm -f
	-rm -f ${projname}
	-rm -f ${wprojname}

distclean: clean

test:
	echo "Nothing"

install-lib:
	install -D ${name} \
		$(DESTDIR)$(prefix)/bin/${projname}

install: all install-lib

uninstall:
	-rm -f $(DESTDIR)$(prefix)/bin/${projname}

.PHONY: all install clean distclean uninstall test

.NOTPARALLEL:
