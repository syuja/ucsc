rsync -az rsync://hgdownload.cse.ucsc.edu/cgi-bin/ $CGI_BIN
rsync -az rsync://hgdownload.cse.ucsc.edu/htdocs/ $WEBROOT/

cd $SWDIR/kent
git pull

cd $SWDIR/kent/src
make clean
make
