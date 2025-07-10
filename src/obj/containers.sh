
#echo -e '#include <gtk/gtk.h>\nvoid main(){printf("%u %u",sizeof(GtkEventBox),sizeof(GtkEventBoxClass));}' | gcc `PKG_CONFIG_PATH=/usr/lib/i386-linux-gnu/pkgconfig pkg-config --cflags gtk+-2.0` -x c -m32 -g - `PKG_CONFIG_PATH=/usr/lib/i386-linux-gnu/pkgconfig pkg-config --libs gtk+-2.0`
touch containers.oh
