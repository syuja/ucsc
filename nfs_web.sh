######################
### TODO #############
######################

# clear from hgcentral: defaultDb, clade, genomeClade, dbDb, dbDbArch, liftOverChain, hubPublic, targetDb
# make sure host info is correct for custom tracks

######################
### INIT ############# replace with docker mounting to a static location
######################

# SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
# echo "source $SCRIPTDIR/config" >> ~/.bashrc
# source ~/.bashrc



mkdir -p $WEBROOT
#ln -s $WEBROOT /usr/local/apache # not needed anymore after docRoot fixed in hg.conf?
rmdir $WEBROOT/html || :
ln -s $WEBROOT $WEBROOT/html
ln -s $WEBROOT $WEBROOT/htdocs
ln -s $CGI_BIN /usr/lib/cgi-bin
ln -s $CGI_BIN $WEBROOT/cgi-bin- #if $USER not defined
ln -s $CGI_BIN $WEBROOT/cgi-bin-root

rsync --delete -az rsync://hgdownload.cse.ucsc.edu/cgi-bin/ $CGI_BIN
rsync --delete -az rsync://hgdownload.cse.ucsc.edu/htdocs/ $WEBROOT/

sed -i '/<TABLE WIDTH="100%" BORDER=0 CELLPADDING=0 CELLSPACING=0>/,/<\/TD><\/TR><\/TABLE>/d' $WEBROOT/index.html

rm -f $WEBROOT/trash
mkdir $WEBROOT/trash
chmod 777 $WEBROOT/trash
chown -R apache:apache $WEBROOT
chown -R 755 $WEBROOT
