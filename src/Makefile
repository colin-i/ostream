
ifndef OCOMP
OCOMP=o
endif

ifndef OLINK
OLINK=ounused
endif

ifndef platform
platform=lin
endif

ifndef linkerflags
linkerflags=-O3 -s
#             1
endif

ifndef prefix
prefix=/usr
endif
#at _dif/share.txt on launchpad prefix is not coming at make, only at make install

projname=ovideo
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
lshare=_dif/share.txt
sharefolderpackage=$(prefix)/share/ovideo
sharefolder=$(DESTDIR)${sharefolderpackage}
dynlink=/lib/ld-linux.so.2
all: ${projname}
${projname}: ${lshare} ${extra} ${obs}
	${OLINK} ${logs}
	export PKG_CONFIG_PATH=/usr/lib/i386-linux-gnu/pkgconfig:${PKG_CONFIG_PATH}; \
	$(LD) -melf_i386 --dynamic-linker=${dynlink} ${linkerflags} ${obs} -o ${items_prefix}${projname} ${Lc} -l:libc.so.6 -l:libm.so.6 ${Lg} `pkg-config --libs gtk+-2.0 gstreamer-pbutils-1.0 gstreamer-app-1.0` -ljpeg -lsoup-2.4 -lasound -lgthread-2.0 -lpthread;
#same CC problem like at actionswf # $(CC) -m32 ${linkerflagsextra}
#need to use LLVM lld to work
${lshare}:
	echo char prestart=0x2e\;char simplestart=\"${sharefolderpackage}\"\;return \#simplestart > ${lshare}
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
wprojname=${projname}.exe
all: ${wprojname}
${wprojname}: ${extra} ${obs}
	ounused ${logs}
	#this is also working
	#i686-w64-mingw32-gcc -Wl,--large-address-aware ${linkerflags} ${obs} -o ${wprojname} -Wl,--start-group \
	#-Wl,--end-group
	i686-w64-mingw32-ld --large-address-aware ${linkerflags} ${obs} -o ${wprojname} -entry _start --allow-multiple-definition --start-group \
	`dpkg -L mingw-w64-i686-dev | grep '\.a' | sed 's/..$$//' | grep -o '[^\/]*$$' | sed 's/^lib/-l/' | xargs echo` \
	--end-group -L`echo ~`/${wineroot}/drive_c/gstreamer-sdk/0.10/x86/lib \
	-lgtk-win32-2.0 -lgdk-win32-2.0 -lgdk_pixbuf-2.0 -lglib-2.0 -lgobject-2.0 -lgio-2.0 -lgthread-2.0 \
	-lgstreamer-0.10 -lgstapp-0.10 -lgstinterfaces-0.10 -lgstpbutils-0.10 \
	-lcairo -lpango-1.0 -lsoup-2.4 -ljpeg;
#--allow-multiple-definition is for _time
platform-clean:
	-rm -f ${wprojname}
install-proc:
	echo use wmake
uninstall: install-proc

endif

${extra}:
	a='int main(){printf("charx GtkTypeInfo#%u;data s=%u;data a=%u;data b=%u;data bb=%u;data c=%u;data cc=%u;data d=%u;",sizeof(GtkTypeInfo),sizeof(GtkTypeInfo),offsetof(GtkTypeInfo,type_name),offsetof(GtkTypeInfo,object_size),sizeof(GtkEventBox),offsetof(GtkTypeInfo,class_size),sizeof(GtkEventBoxClass),offsetof(GtkTypeInfo,class_init_func));return 0;}'; \
	export PKG_CONFIG_PATH=/usr/lib/i386-linux-gnu/pkgconfig:${PKG_CONFIG_PATH}; \
	printf '#include <gtk/gtk.h>\n%s' "$${a}" | gcc `pkg-config --cflags gtk+-2.0` -x c -m32 - `pkg-config --libs gtk+-2.0`
	echo -n 'function ov_frame();' > $@
	./a.out >> $@
	echo -n 'call setmemzero(#GtkTypeInfo,s);end' >> $@
	rm a.out

#at jammy libgtk2.0-dev:i386,libgstreamer-plugins-base1.0-dev:i386,libsoup2.4-dev:i386,libasound2-dev:i386

#at bionic
#libgtk2.0-dev:i386	libgtk2.0-0:i386 is already
#libgstreamer-plugins-base1.0-dev:i386	libgstreamer-plugins-base1.0-0:i386 is already
#no apt-file search libgstinterfaces 0.10 in xenial
#libsoup2.4-dev:i386      libsoup2.4-1:i386 is already
#libasound2-dev:i386	libasound2:i386 is already
#libjpeg8-dev:i386	libjpeg8:i386 is already
#libgstreamer1.0-dev:i386 is already	libgstreamer1.0-0:i386 is already

#without -pthread, at launchpad runner: _dif/dif~lin.o: undefined reference to symbol 'sem_init@@GLIBC_2.1'

#fast:
#	$(eval obs = `printf ' ${items_prefix}%s.o' ${items}`)
#linkapp: fast lnkapp
#link: fast lnk
#snprintf with circular unresolved requirements
#cos is in -lmingwex that will work with -lmingw32 -lmsvcrt
#on win msvcr100 is old and at here is from old java-i586
#linkapp:
#	LD_LIBRARY_PATH=/home/bc/v/ovideo-1/AppDir/usr/lib/i386-linux-gnu:/home/bc/v/ovideo-1/AppDir/lib/i386-linux-gnu \
#		$(LD) ${linkerflags} -melf_i386 --dynamic-linker=${dynlink} ${obs} -o ${lprojname} \
#			-L/home/bc/v/ovideo-1/AppDir/usr/lib/i386-linux-gnu \
#			-l:libc.so.6 -l:libm.so.6 -l:libgtk-x11-2.0.so.0 -l:libgdk-x11-2.0.so.0 -l:libpangocairo-1.0.so.0 -l:libatk-1.0.so.0 -l:libcairo.so.2 -l:libgdk_pixbuf-2.0.so.0 -l:libgio-2.0.so.0 -l:libpangoft2-1.0.so.0 -l:libpango-1.0.so.0 -l:libfontconfig.so.1 -l:libfreetype.so.6 -l:libgstpbutils-1.0.so.0 -l:libgstaudio-1.0.so.0 -l:libgstvideo-1.0.so.0 -l:libgstapp-1.0.so.0 -l:libgstbase-1.0.so.0 -l:libgstreamer-1.0.so.0 -l:libgobject-2.0.so.0 -l:libglib-2.0.so.0 -l:libjpeg.so.8 -l:libsoup-2.4.so.1 -l:libasound.so.2 -l:libpthread.so.0 -l:libgthread-2.0.so.0

%.o: %.oc
	${OCOMP} $< ${OFLAGS}
#	$(eval logs += $@.oc.log)
#	$(eval obs += $@.o)

clean: platform-clean
	-rm -f ${obs}
	-rm -f ${logs}
	-rm -f ${extra}

distclean: clean

test:
	echo "Nothing"

install: all install-proc

.PHONY: all install install-proc clean platform-clean distclean uninstall test

.NOTPARALLEL:
