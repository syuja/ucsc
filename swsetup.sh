#make software directory
mkdir -p $SWDIR
mkdir -p $SWDIR/bin/$MACHTYPE
ln -s $SWDIR/bin ~/bin

#grab and compile samtabix
git clone http://genome-source.cse.ucsc.edu/samtabix.git $SWDIR/samtabix
cd $SWDIR/samtabix
make

#grab and compile kent source
git clone https://github.com/ucscGenomeBrowser/kent $SWDIR/kent
cd $SWDIR/kent
git checkout -t -b beta origin/beta
git pull
sed -i 's/hgBeacon//g' $SWDIR/kent/src/hg/makefile
sed -i 's/hgMirror//g' $SWDIR/kent/src/hg/makefile #hgMirror makefile breaks cgi make - -${USER} issue
