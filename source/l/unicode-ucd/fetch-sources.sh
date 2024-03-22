#!/bin/bash

VERSION=${VERSION:-15.1.0}

rm -f UCD*.zip Unihan*.zip license.txt
lftpget https://www.unicode.org/Public/zipped/$VERSION/UCD.zip
lftpget https://www.unicode.org/Public/zipped/$VERSION/Unihan.zip
lftpget https://www.unicode.org/license.txt

mv UCD.zip UCD-${VERSION}.zip
mv Unihan.zip Unihan-${VERSION}.zip
