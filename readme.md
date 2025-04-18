# O Video

## Install
On Ubuntu, <i>.deb</i> file from [releases](https://github.com/colin-i/ostream/releases).\
Or from PPA.
```sh
sudo add-apt-repository ppa:colin-i/ppa
```
Or the *manual installation step* from this link *https://gist.github.com/colin-i/e324e85e0438ed71219673fbcc661da6* \
Install:
```sh
sudo apt-get install ovideo
```
\
On linux distributions, <i>.AppImage</i> file from [releases](https://github.com/colin-i/ostream/releases).\
\
On Fedora, <i>.rpm</i> file from [releases](https://github.com/colin-i/ostream/releases).\
Missing libjpeg.so.8? https://download.copr.fedorainfracloud.org/results/aflyhorse/libjpeg/fedora-36-i386/ \
Unacceptable TLS certificate? `bionic release glib-networking:i386 libgiognutls.so` can do it with environment GIO_EXTRA_MODULES variable for the `dirname` part.
```sh
dnf install ovideo-*.*.rpm
```
\
On Windows, <i>.windows.zip</i> file from [releases](https://github.com/colin-i/ostream/releases).\
<i>Gstreamer sdk</i> x86 0.10 from [here](https://cgit.freedesktop.org/gstreamer/gstreamer/refs/heads).

## From source
Compile with [O Compiler](https://github.com/colin-i/o) and link with
<i>binutils</i> and see the <i>Makefile</i> for requirements.

## Info
[Video tutorials](https://www.youtube.com/channel/UCBJPvGdXY5U3p8Fbl6HOFkQ).\
On Linux, follow ```ovideo --help``` to remove configuration data. On Windows, remove configuration with one argument at command line start.

## Donations
The *donations* section is here
*https://gist.github.com/colin-i/e324e85e0438ed71219673fbcc661da6*
