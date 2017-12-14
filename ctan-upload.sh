#!/bin/sh
# This is copied with very minor modificaton from https://github.com/Witiko/ctan-upload

die() { EXITCODE=$1; shift; printf '%s\n' "$*"; exit $EXITCODE; }

# Source the passed file.
[ -e "$1" ] && . "$1"
VERS="$2 $(date +%Y-%m-%d)"

# Perform sanity checks.
[ -z "$PKG" ] && die 1 Undefined / empty PKG
[ -z "$VERS" ] && die 2 Undefined / empty VERS
[ -z "$AUTHOR" ] && die 3 Undefined / empty AUTHOR
[ -z "$FILENAME" ] && die 4 Undefined / empty FILENAME
[ ! -e "$FILENAME" ] && die 5 File "$FILENAME" does not exist
[ -z "$EMAIL" ] && die 6 Undefined / empty EMAIL
[ -z "$DESCRIPTION" ] && die 7 Undefined / empty DESCRIPTION
[ -z "$CTANPATH" ] && die 8 Undefined / empty CTANPATH
[ -z "$TYPE" ] && die 9 Undefined / empty TYPE
[ "$TYPE" = announce -a -z "$ANNOUNCEMENT" ] &&
  die 10 TYPE is announce, but ANNOUNCEMENT is undefined / empty

# Retrieve a ticket number from CTAN.
COOKIEJAR=`mktemp`
trap 'rm $COOKIEJAR' EXIT
TICKET="$(curl -c $COOKIEJAR -s 'https://ctan.org/upload' |
  xmllint --html --xpath "//input[@name='ticket']/@value" - 2>/dev/null |
	sed -n -r '/^ value=".*"$/s/^ value="(.*)"$/\1\n/p')"
[ -z "$TICKET" ] && die 11 Failed to download ticket number

echo $FILENAME

# Send the archive.
RESPONSE=./ctan-upload.response.html
curl --form-string ticket="$TICKET" \
     --form-string pkg="$PKG" \
     --form-string vers="$VERS" \
     --form-string author="$AUTHOR" \
     --form-string uploader="$UPLOADER" \
     --form-string email="$EMAIL" \
     --form-string description="$DESCRIPTION" \
     --form-string ctanPath="$CTANPATH" \
        --form-string type="$TYPE" \
     --form-string announcement="$ANNOUNCEMENT" \
     --form-string note="$NOTE" \
     --form-string licenses="$LICENSE" \
     --form-string home="$HOMEPAGE" \
     --form-string bugs="$BUGS" \
     --form-string support="$SUPPORT" \
     --form-string announce="$ANNOUNCEMENTS" \
     --form-string repository="$REPOSITORY" \
     --form-string development="$DEVELOPMENT" \
     -F file=@"$FILENAME" \
     --form-string SUBMIT='Submit contribution' \
     -b $COOKIEJAR https://ctan.org/upload/save >$RESPONSE
grep <$RESPONSE -qF 'Your contribution has been uploaded' ||
  die 12 Upload failed.
echo "Upload succeeded"
