
::use Makefile
exit

copy html\readme-win.html build\readme.html
mkdir build\html
copy html\html\ build\html\
copy _fix\launch.bat build\
copy version.txt build\sys\

cd src

cmd.exe /c "..\win_make_objects.bat"
cmd.exe /c "..\win_link_objects.bat"

cd..