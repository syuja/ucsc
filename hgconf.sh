######################
### HG.CONF ##########
######################

cp $SWDIR/kent/src/product/ex.hg.conf $CGI_BIN/hg.conf

sed -i 's/defaultGenome=.*/defaultGenome='"$DEFAULTGENOME"'/g' $CGI_BIN/hg.conf
sed -i 's/wiki\.host=.*/wiki\.host='"$HOST"'/g' $CGI_BIN/hg.conf
sed -i 's/login\.browserName=.*/login\.browserName='"$BROWSERNAME"'/g' $CGI_BIN/hg.conf
sed -i 's/login\.browserAddr=.*/login\.browserAddr=http:\/\/'"$HOST"'/g' $CGI_BIN/hg.conf
sed -i 's/login\.mailSignature=Greenome Browser Staff=.*/login\.mailSignature=Greenome Browser Staff/g' $CGI_BIN/hg.conf
sed -i 's/login\.mailReturnAddr=.*/login\.mailReturnAddr='"$EMAILADDRESS"'/g' $CGI_BIN/hg.conf
sed -i 's/custromTracks\.host=.*/custromTracks\.host=localhost/g' $CGI_BIN/hg.conf
sed -i 's/customTracks\.host=.*/customTracks\.host=localhost/g' $CGI_BIN/hg.conf
sed -i 's/customTracks\.user=.*/customTracks\.user=readwrite/g' $CGI_BIN/hg.conf
sed -i 's/customTracks\.password=.*/customTracks\.password=update/g' $CGI_BIN/hg.conf
sed -i 's#customTracks\.tmpdir=.*#customTracks\.tmpdir='$WEBROOT/trash/ct'#g' $CGI_BIN/hg.conf
sed -i 's#browser.documentRoot=.*#browser.documentRoot='$WEBROOT'#g' $CGI_BIN/hg.conf