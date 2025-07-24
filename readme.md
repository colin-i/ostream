# O Video

## Install
On Ubuntu, <i>.deb</i> file from [releases](https://github.com/colin-i/ostream/releases)(jammy also working at noble).\
Or from PPA(i386)(xenial bionic focal jammy).
```sh
sudo add-apt-repository ppa:colin-i/ppa
```
Or the *manual installation step* from this link *https://gist.github.com/colin-i/e324e85e0438ed71219673fbcc661da6* \
Install:
```sh
sudo apt-get install ovideo
```
\
On openSUSE(i586), run the following as __root__:\
For openSUSE Tumbleweed:
```sh
zypper addrepo https://download.opensuse.org/repositories/home:costin/openSUSE_Tumbleweed/home:costin.repo
```
For openSUSE Leap:
```sh
zypper addrepo https://download.opensuse.org/repositories/home:costin/openSUSE_Leap_15.6/home:costin.repo
```
And:
```sh
zypper refresh
zypper install ovideo
```
\
On Windows, <i>.windows.zip</i> file from [releases](https://github.com/colin-i/ostream/releases).\
<i>Gstreamer sdk</i> x86 0.10 from [here](https://cgit.freedesktop.org/gstreamer/gstreamer/refs/heads).
\
\
On linux distributions(x86_64), <i>.AppImage</i> file from [releases](https://github.com/colin-i/ostream/releases).

## From source
Compile with [O Compiler](https://github.com/colin-i/o). At linux, for example: link with <i>lld</i> and having gstreamer1(with good/bad plugins), gtk2, libsoup2, libasound2, libjpeg8.

## Info
[Video tutorials](https://www.youtube.com/channel/UCBJPvGdXY5U3p8Fbl6HOFkQ).\
On Linux, follow ```ovideo --help``` to remove configuration data. On Windows, remove configuration with one argument at command line start.

## Donations
The *donations* section is here
*https://gist.github.com/colin-i/e324e85e0438ed71219673fbcc661da6*
