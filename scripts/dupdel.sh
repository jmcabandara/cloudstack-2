for f in $(find 6.? -type f -name \*.rpm -exec basename {} \; | sort | uniq -d); do
  for d in $(find . -mindepth 1 -maxdepth 1 -type d -name \[5-7\].*); do
    if [ -f $d/$f ]; then
      if [ ! -f $f ]; then mv $d/$f .; fi
      rm -f $d/$f
      (cd $d; ln -s ../$f)
    fi
  done
done
for f in *.rpm; do
  for d in $(find . -mindepth 1 -maxdepth 1 -type d -name \[5-7\].*); do
    if [ -f $d/$f ]; then
      rm -f $d/$f
      (cd $d; ln -s ../$f)
    fi
  done
done
