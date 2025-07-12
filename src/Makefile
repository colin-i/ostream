
ifndef OCOMP
OCOMP=o
endif

ifndef linkerflags
linkerflags=-O3 -s
#           -O1
endif

platform = lin

cap = _capture/capture
err = err/err
eve = event/event
e=_exec/
exe = ${e}capture/save ${e}debug ${e}help ${e}init ${e}mainhandles ${e}mediainfo ${e}mix ${e}ostream ${e}start ${e}uri ${e}uristream
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
items_prefix=

$(eval obs = )
$(foreach var,$(items),$(eval obs += ${items_prefix}${var}.o))
$(eval logs = )
$(foreach var,$(items),$(eval logs += ${items_prefix}${var}.oc.log))

extra=${o}containers.oh

ifeq (${platform},lin)

OFLAGS = underscore_pref 1 ${OFLAGSEXTRA}
projname=ovideo
lshare=_dif/share.txt
sharefolderpackage=$(prefix)/share/ovideo
sharefolder=$(DESTDIR)${sharefolderpackage}
all: ${projname}
${projname}: ${lshare} ${extra} ${obs}
	ounused ${logs}
	$(CC) -nostdlib ${linkerflags} ${obs} -o ${items_prefix}${projname} `pkg-config --libs gtk+-2.0 gstreamer-pbutils-0.10 gstreamer-interfaces-0.10 gstreamer-app-0.10` -lsoup-2.4 -ljpeg -lasound -lm -lpthread -lc
${lshare}:
	echo return \"${sharefolderpackage}\" > ${lshare}
platform-clean:
	-rm -f ${projname}
	-rm -f ${lshare}
install-proc:
	cd ../build; \
	find ./img -type f ! -name 1616.png -exec install -Dm 664 {} ${sharefolder}/{} \;
	#is with ! name can try in debian/rules override_dh_auto_clean maybe
	install -d ${sharefolder}/html
	cd ../html; \
	install -Dm 664 html/use.html ${sharefolder}/html/
	cd ..; \
	install -m 664 ./version.txt ${sharefolder}/
	install -D ${projname} \
		$(DESTDIR)$(prefix)/bin/${projname}
uninstall:
	-rm -f $(DESTDIR)$(prefix)/bin/${projname}
	-rm -r ${sharefolder}

else

OFLAGS = inplace_reloc 0 include_sec 1 ${OFLAGSEXTRA}
wprojname=ovideo.exe
all: ${wprojname}
${wprojname}: ${extra} ${obs}
	ounused ${logs}
	i686-w64-mingw32-ld --large-address-aware ${linkerflags} ${obs} -o ${wprojname} -entry _start --start-group \
	`dpkg -L mingw-w64-i686-dev | grep '\.a' | sed 's/..$$//' | grep -o '[^\/]*$$' | sed 's/^lib/-l/' | xargs echo` \
	--end-group -L`echo ~`/.wine/drive_c/gstreamer-sdk/0.10/x86/lib/ \
	-lgtk-win32-2.0 -lgdk-win32-2.0 -lgdk_pixbuf-2.0 -lglib-2.0 -lgobject-2.0 -lgio-2.0 -lgthread-2.0 \
	-lgstreamer-0.10 -lgstapp-0.10 -lgstinterfaces-0.10 -lgstpbutils-0.10 \
	-lcairo -lpango-1.0 -lsoup-2.4 -ljpeg;
platform-clean:
	-rm -f ${wprojname}
install-proc:
	echo use wmake
uninstall: install-proc

endif

${extra}:
	a='int main(){printf("charx GtkTypeInfo#%u;data s=%u;data a=%u;data b=%u;data bb=%u;data c=%u;data cc=%u;data d=%u;",sizeof(GtkTypeInfo),sizeof(GtkTypeInfo),offsetof(GtkTypeInfo,type_name),offsetof(GtkTypeInfo,object_size),sizeof(GtkEventBox),offsetof(GtkTypeInfo,class_size),sizeof(GtkEventBoxClass),offsetof(GtkTypeInfo,class_init_func));return 0;}'; \
	printf '#include <gtk/gtk.h>\n%s' "$${a}" | gcc `pkg-config --cflags gtk+-2.0` -x c -m32 - `pkg-config --libs gtk+-2.0`
	echo -n '#function ov_frame();' > $@
	./a.out >> $@
	echo -n 'call setmemzero(#GtkTypeInfo,s);end' >> $@
	rm a.out

#at jammy libgtk2.0-dev:i386,libgstreamer-plugins-base1.0-dev:i386,libsoup2.4-dev:i386,libasound2-dev:i386

#at bionic
#libgtk2.0-dev:i386	libgtk2.0-0:i386 is already
#libgstreamer-plugins-base1.0-dev:i386	libgstreamer-plugins-base1.0-0:i386 is already
#	gst_app_buffer_new	stage_file_need_fn
#no apt-file search libgstinterfaces 0.10 in xenial
#	gst_x_overlay_get_type	video_realize
#	gst_x_overlay_set_window_handle	video_realize
#libsoup2.4-1:i386 is already
#libasound2-dev:i386	libasound2:i386 is already

#at xenial
#dev gtk libgstreamer-plugins-base0.10-dev  soup jpeg asound
#gtk gstreamer0.10-plugins-good
#for mxf, gstreamer0.10-plugins-bad was deleted at ubuntu

#		export PKG_CONFIG_PATH=/usr/lib/i386-linux-gnu/pkgconfig/:${PKG_CONFIG_PATH}; \
#		$(LD) ${linkerflags} -melf_i386 --dynamic-linker=/lib/ld-linux.so.2 ${obs} -o ${projname} -lc -lm `pkg-config --libs gtk+-2.0 gstreamer-pbutils-1.0 gstreamer-app-1.0` -ljpeg -lsoup-2.4 -lasound -lgthread-2.0; \
#cc because -pthread not for ld
#nostdlib because is complaining about main

#fast:
#	$(eval obs = `printf ' ${items_prefix}%s.o' ${items}`)
#link: fast lnk
#snprintf with circular unresolved requirements
#cos is in -lmingwex that will work with -lmingw32 -lmsvcrt
#on win msvcr100 is old and at here is from old java-i586

%.o: %.oc
	${OCOMP} $< ${OFLAGS}
#	$(eval logs += $@.oc.log)
#	$(eval obs += $@.o)

clean: platform-clean
	-printf ' %s.oc.log' ${items} | xargs rm -f
	-printf ' %s.o' ${items} | xargs rm -f
	-rm -f ${extra}

distclean: clean

test:
	echo "Nothing"

install: all install-proc

.PHONY: all install install-proc clean platform-clean distclean uninstall test

.NOTPARALLEL:
