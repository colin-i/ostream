
ar=( `find -name "*deb" | xargs echo` )
for var in "${ar[@]}"
do
 dpkg -x ${var} AppDir
done
