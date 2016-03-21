# RUN ON WEB SERVER

cd $SWDIR/kent/src
make clean
make cgi
make blatSuite

#post-build tasks
rm -f $CGI_BIN/webBlat
cp -f $SWDIR/kent/src/webBlat/webBlat $CGI_BIN
rm -f $CGI_BIN/webBlat.cfg
cp -f $SWDIR/kent/src/webBlat/webBlat.cfg $CGI_BIN

chown -R apache:apache $WEBROOT #cgis copied from source compilaton owned by root
