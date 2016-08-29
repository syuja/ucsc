yum update -y && yum install -y \
httpd \
rsync \
tcsh \
gcc \
libstdc++-devel.x86_64 \
libstdc++-static.x86_64 \
make \
perl \
git \
libpng-devel.x86_64 \
mariadb-devel.x86_64 \
mariadb-server.x86_64 # for mysql executable

echo -e 'db.host='${SQLHOST}'\ndb.user='$SQL_USER'\ndb.password='$SQL_PASSWORD > $HOME/.hg.conf && chmod 600 $HOME/.hg.conf
chmod 600 ~/.hg.conf

#make software directory
mkdir -p $SWDIR/bin/$MACHTYPE
ln -s $SWDIR/bin ~/bin

mkdir -p ${CGI_BIN}
ln -s ${CGI_BIN} ${CGI_BIN}-

#grab and compile samtabix
git clone http://genome-source.cse.ucsc.edu/samtabix.git $SWDIR/samtabix
cd $SWDIR/samtabix
make

#grab and compile kent source
git clone https://github.com/ucscGenomeBrowser/kent $SWDIR/kent
cd $SWDIR/kent
git checkout -t -b beta origin/beta
sed -i 's/hgBeacon//g' $SWDIR/kent/src/hg/makefile
sed -i 's/hgMirror//g' $SWDIR/kent/src/hg/makefile #hgMirror makefile breaks cgi make - -${USER} issue
echo 'L+= -lz' >> $SWDIR/kent/src/inc/common.mk
cd $SWDIR/kent/src
make utils
