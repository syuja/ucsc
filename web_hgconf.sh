######################
### HG.CONF ##########
######################

echo -e 'db.host='${SQLHOST}'\ndb.user='$SQL_USER'\ndb.password='$SQL_PASSWORD > $HOME/.hg.conf && chmod 600 $HOME/.hg.conf
chmod 600 ~/.hg.conf

rm -f $HGCONF && cp -f $SWDIR/kent/src/product/ex.hg.conf $HGCONF
# set default genome
sed -i 's/defaultGenome=.*/defaultGenome='"$DEFAULTGENOME"'/g' $HGCONF
# set FQDN for http server serving hgLogin
#sed -i 's/wiki\.host=.*/wiki\.host='"$WEBHOST"'/g' $HGCONF
sed -i 's/wiki\.host=.*/wiki\.host=HTTPHOST/g' $HGCONF
#sed -i 's/login\.mailReturnAddr=.*/login\.mailReturnAddr='"$WIKIEMAIL"'/g' $HGCONF
# set FQDN for http server serving browser for cookies
#sed -i 's/central\.domain=.*/central\.domain='"$WEBHOST"'/g' $HGCONF
sed -i 's/central\.domain=.*/central\.domain=HTTPHOST/g' $HGCONF
# set hostname for mysql server serving hgcentral
sed -i 's/central\.host=.*/central\.host='"$SQLHOST"'/g' $HGCONF
sed -i 's/db\.host=.*/db\.host='"$SQLHOST"'/g' $HGCONF
sed -i 's/login\.browserName=.*/login\.browserName='"$BROWSERNAME"'/g' $HGCONF
sed -i 's/login\.browserAddr=.*/login\.browserAddr=http:\/\/'"$HOST"'/g' $HGCONF
sed -i 's/login\.mailSignature=Greenome Browser Staff=.*/login\.mailSignature=Greenome Browser Staff/g' $HGCONF
sed -i 's/login\.mailReturnAddr=.*/login\.mailReturnAddr='"$WIKIEMAIL"'/g' $HGCONF
sed -i 's/custromTracks\.host=.*/custromTracks\.host=localhost/g' $HGCONF
sed -i 's/customTracks\.host=.*/customTracks\.host='"$SQLHOST"'/g' $HGCONF
sed -i 's/customTracks\.user=.*/customTracks\.user=readwrite/g' $HGCONF
sed -i 's/customTracks\.password=.*/customTracks\.password=update/g' $HGCONF
sed -i 's#customTracks\.tmpdir=.*#customTracks\.tmpdir='$WEBROOT/trash/ct'#g' $HGCONF
sed -i 's#browser.documentRoot=.*#browser.documentRoot='$WEBROOT'#g' $HGCONF
