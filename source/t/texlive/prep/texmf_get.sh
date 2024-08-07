#!/bin/bash

# texmf_get.sh
#
# Copyright 2016-2024  Johannes Schoepfer, Germany, slackbuilds@schoepfer.info
# All rights reserved.
#
# Redistribution and use of this script, with or without modification, is
# permitted provided that the following conditions are met:
#
# 1. Redistributions of this script must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#
#  THIS SOFTWARE IS PROVIDED BY THE AUTHOR ''AS IS'' AND ANY EXPRESS OR IMPLIED
#  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
#  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO
#  EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
#  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
#  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
#  OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
#  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
#  OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
#  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
#  version 15.1.2
#
#  Prepare xz-compressed tarballs of texlive-texmf-trees based on texlive.tlpdb
#  This script takes care of dependencies(as far as these are present in texlive.tlpdb)
#  of collections and packages, and that every texlive-package is included only once.
#  The editions(base/extra/docs) should contain no binaries
# -base: the most usefull stuff, most binaries/scripts,
#  manpages for binaries/scripts  65mb 2017-11-07
# -docs: -base documentation only, no manpages/GNU infofiles
# -extra: remaining stuff and corresponding docs
#
#  texlive netarchive policy: Every package is included as dependency 
#  in exactly one collection. A package may have dependencies on other
#  packages from any collection.

#set -e
# Official mirror
mirror="http://mirror.ctan.org/systems/texlive/tlnet/"
# Pre-test mirror for new releases
#mirror="http://ftp.cstug.cz/pub/tex/local/tlpretest/"
cd $(dirname $0) ; CWD=$(pwd)
TMP=${TMP:-$CWD/tmp}

usage () {
  echo
  echo "Generate texmf trees/editions based on collections/packages"
  echo "and their (hard)dependencies."
  echo "./texmf_get.sh [base|docs|extra|lint]"
  echo
  echo "-base:  texfiles, no docs"
  echo "-docs:  docs of -base"
  echo "-extra: remaining texfiles and docs"
  echo "[lint]: compare filename contents of all generated editions,"
  echo " to detect overlapping files"
  echo 
  echo "Only new/updated/missing tex packages are downloaded."
  echo "The first run takes \"long\", tex packages(about 3Gb)"
  echo "need to be downloaded."
  echo "To check out a new version/release, delete"
  echo "$db"
  echo "A new ascii index file/database(texlive.tlpdb) is will be"
  echo "pulled on the next run, and a new version yymmdd will be set."
  echo
  echo "All generated tarballs, logs etc. are going to"
  echo "$TMP"
  echo
}

collection_by_size () {
  # from collection $1, pull packages smaller $2 bytes 
  start_n="$(grep -n ^"name collection-$1"$ $db | cut -d':' -f1)"
  # find end of package/collection
  for emptyline in $emptylines
  do
    if [ "$emptyline" -gt "$start_n" ]
    then
      end_n=$emptyline
      break
    fi
  done
  extrapackages="$(sed "${start_n},${end_n}!d" $db | grep ^"depend " | grep -v ^"depend collection" | sed "s/^depend//g" )"
  
  # add if smaller than ...
  for checksize in $extrapackages
  do
    package_meta $checksize || exit 1
    size=$(grep ^"containersize " $texmf/$checksize.meta | cut -d' ' -f2)
    # for $2, e.g. 3000 means 3kb
    [ $size -lt $2 ] && echo $checksize
  done
}

package_meta () {
  if [ ! -s "$texmf/$1.meta" ]
  then
    # collection start linenumer
    start_n="$(grep -n ^"name ${1}"$ $db | cut -d':' -f1)"
    [ -z "$start_n" ] && echo "ERROR: \"$1\" is no package in $db, edit $CWD/packages.texmf !" && exit 1
    # find end of package/collection
    for emptyline in $emptylines
    do
      if [ "$emptyline" -gt "$start_n" ]
      then
        end_n=$emptyline
        break
      fi
    done
    # Don't handle collections as dependency of other collections
    sed "${start_n},${end_n}!d;/^depend collection/d" $db > $texmf/$1.meta 
  fi
}

download () {
  # Download packages, if not already available. Not every packages has a corresponding .doc package.
  # Try multiple times if package isn't present or checksum fails
  
  unset checksum_ok
  if [ "$flavour" = ".doc" ]
  then
    sha512="$(grep ^doccontainerchecksum $texmf/$1.meta | cut -d' ' -f2 )"
  else
    sha512="$(grep ^containerchecksum $texmf/$1.meta | cut -d' ' -f2 )"
  fi
  
  cd $texmf
 
  for run in {1..10}
  do
    [ ! -s "${1}${flavour}.tar.xz" ] && \
      wget -q --show-progress -t1 -c ${mirror}archive/${1}${flavour}.tar.xz
    [ ! -s "${1}${flavour}.tar.xz" ] && continue
    if [ "$(sha512sum ${1}${flavour}.tar.xz | cut -d' ' -f1 )" != "$sha512" ]
    then
      echo "sha512sum of ${1}${flavour}.tar.xz doesn't match $texmf/$1.meta"
      echo "deleting ${1}${flavour}.tar.xz"
      rm ${1}${flavour}.tar.xz
    else
      checksum_ok=yes
      break
    fi
  done
  
  # If no success by downloading, write error log
  if [ -z "$checksum_ok" ]
  then
    echo "Downloading ${1}${flavour}.tar.xz or sh512sum check was not successful,\\
    writing to $errorlog" 
    echo "Delete ${db}* and $TMP/VERSION, then try again, bye."
    echo "$VERSION" >> $errorlog
    echo "Error downloading ${1}${flavour}.tar.xz" >> $errorlog
    exit 1
  fi
}

untar () {
  # leave if $1 has no content
  if [ -s "$1" ]
  then
    while read package
    do
      echo "untar $package$flavour"
      # untar all packages, check for relocation, "relocate 1" -> untar in texmf-dist
      download $package || exit 1
      # untar package, relocate to texmf-dist if necessary, binary packages always need relocation
      relocated='.'
      [ -n "$(grep -w ^"relocated 1" $texmf/$package.meta)" -o -n "$(grep ^"binfiles " $texmf/$package.meta)" ] && relocated="texmf-dist" 
      # if not .doc package, investigate files for dependencies/provides
      if [ -n "$flavour" ]
      then
        tar xf ${package}${flavour}.tar.xz --exclude tlpkg -C $relocated || exit 1
      else
        tar vxf ${package}${flavour}.tar.xz \
	  --exclude tlpkg/tlpobj \
	  -C $relocated | grep -E '\.sty$|\.bbx$|\.cls$' > $texmf/$package.deps
        if [ -n "$texmf/$package.deps" ]
        then
          unset provide
          unset depends
          for depfile in $(cat $texmf/$package.deps)
          do
            filename="$( echo $depfile | rev | cut -d'.' -f2- | cut -d'/' -f1 | rev)"
            # always add $filename as "ProvidesPackage", if it's a .sty
            echo $depfile | grep '\.sty'$ &>/dev/null
            [ $? = 0 ] && provide+="${filename},"
            provide+="$(sed "s/%.*//g" $texmf/$relocated/$depfile | sed -z "s/\(Package\|ExplPackage\|File\|Class\)\n/\1/g" | sed "s/[[:space:]]//" | sed -n "s/.*\\\Provides\(Package\|ExplPackage\|File\|Class\){\([^}]*\)}.*/\2/p" | sed "s/\\\filename/$filename/g;s/\\\ExplFileName/$filename/g" | sed "s/\(\.sty$\|\.cls$\)//g" | sort -u | tr '\n' ',')"
            depends+="$(sed "s/%.*//g" $texmf/$relocated/$depfile | sed -n "s/.*\(\\\require\|\\\use\)package{\([^}]*\)}.*/\2/p" | sort -u | tr '\n' ',')"
          done
          if  [ -n "$provide" ]
          then
            echo "$package $provide" >> $TMP/provides.run.$edition
          fi
          if [ -n "$depends" ]
          then
            echo "$package $depends" >> $TMP/depends.run.$edition
          fi
        fi
      fi

      # Delete binaries, these are build by texlive.Slackbuild
      # Keep symlinks and scripts
      
      for arch in $platforms
      do
        if [ -d $texmf/texmf-dist/bin/$arch ]
        then
          [ ! -d $texmf/texmf-dist/linked_scripts ] && \
            mkdir $texmf/texmf-dist/linked_scripts
	  # remove the unfortunate "man" link
	  [ -L "$texmf/texmf-dist/bin/$arch/man" ] && \
	    rm $texmf/texmf-dist/bin/$arch/man 
          for link in $(find $texmf/texmf-dist/bin/$arch -type l)
          do
	    # if link has "../.." content, re-create link to match
	    # final destiantion /usr/share/texmf-dist
            a="$(readlink $link)"
	    b=${a/..\/../..\/share}
	    link_valid_dest=$texmf/texmf-dist/linked_scripts/${link##*/}
	    ln -sf $b $link_valid_dest
	    rm $link
          done
           
          # keep only precompiled binaries of special packages, see packages.texmf,
	  # these should only be in -extra.
          # remove xindy.mem(gzip compresses data) to prevent overwriting
	  # the one built from the source
          for bin in $(find $texmf/texmf-dist/bin/$arch -type f -exec file '{}' + | \
            grep -e "shared object" -e ELF -e "gzip compressed data" | cut -f 1 -d : ) 
          do
            binfile="$(echo $bin | rev | cut -d'/' -f1 | rev)"
            # might be already removed by a previous run
            if [ -s "$bin" ]
            then
              #echo "Deleting binary \"$arch/$binfile\""
	      rm $bin && echo "$package: $binfile" >> $binary_removed.$edition
            fi
          done
          # move scripts to linked-scripts
          for script in \
	    $(find $texmf/texmf-dist/bin/$arch -type f -exec file '{}' + | \
	    grep -wv ELF | cut -f 1 -d : )
          do
            mv $script $texmf/texmf-dist/linked_scripts/
          done
        fi
      done
     
      for tlpkg_dir in $texmf/tlpkg $texmf/texmf-dist/tlpkg
      do
        if [ -d $tlpkg_dir ]
        then
          for bin in $(find $tlpkg_dir -type f -exec file '{}' + | \
            grep -e "shared object" -e ELF -e "gzip compressed data" | cut -f 1 -d : ) 
          do
            rm $bin
            echo -n "$package:" >> $binary_removed.$edition
            echo $bin | rev | cut -d'/' -f1 | rev >> $binary_removed.$edition
          done
          find $tlpkg_dir -type d -empty -delete
          if [ -d $tlpkg_dir/TeXLive ]
          then
            mkdir -p $texmf/texmf-dist/scripts/texlive/TeXLive
            mv $tlpkg_dir/TeXLive/* $texmf/texmf-dist/scripts/texlive/TeXLive
	  fi
        fi
      done

      if [ "$flavour" = ".doc" ]
      then
        size=$(grep ^doccontainersize $texmf/$package.meta | cut -d' ' -f2) 
      else
        size=$(grep ^containersize $texmf/$package.meta | cut -d' ' -f2)
	# add maps to updmap.cfg, don't add special_packages map files to -base
	add_map=yes 
	if [ $edition = base ]
	then
	  for no_map in $special_packages
	  do
	    [ $no_map = $package ] && add_map=no && break 
          done
	fi
	[ $add_map = yes ] && grep ^'execute ' $texmf/$package.meta | grep Map | cut -d' ' -f2- | sed "s/^add//g" >> $updmap.$edition
      fi
      shortdesc="$(grep ^shortdesc $texmf/$package.meta | cut -d' ' -f2- )"
      echo "$size byte, $package$flavour: $shortdesc" >> $output.meta
      # make index of uncompressed size of each package
      echo "$(xz -l --verbose ${package}${flavour}.tar.xz | grep "Uncompressed size" | \
        cut -d'(' -f2 | cut -d' ' -f1 ) byte, $package$flavour: $shortdesc" >> $output.meta.uncompressed
    done < $1
    
    # add a path to updmap
    if [ -s "$texmf/texmf-dist/linked_scripts/updmap" ]
    then
      sed -i '/unshift.*@INC.*/a unshift(@INC, "$TEXMFROOT/texmf-dist/scripts/texlive");' $texmf/texmf-dist/linked_scripts/updmap || exit 1
    fi
    
    # copy packages index to texmf-dist, to have a list of included packages in the final installation
    # don't list binary packages, as the binaries itself are not contained,
    # only symlinks/scripts.
    cat $output.meta | grep -v '\-linux:'  >> $output.$edition.meta
    cat $output.meta.uncompressed | grep -v '\-linux:' >> $output.$edition.meta.uncompressed
    
    # cleanup
    [ -f $output.meta ] && rm $output.meta
    [ -f $output.meta.uncompressed ] && rm $output.meta.uncompressed
  fi
}

remove_cruft () {
  # Remove m$-stuff, ConTeXt single-user-system stuff, empty files/directories and pdf-manpages
  rm -rf $texmf/texmf-dist/source
  rm -rf $texmf/texmf-dist/scripts/context/stubs/source/
  find $texmf/texmf-dist/ -type d -name 'win32'         -exec rm -rf {} +
  find $texmf/texmf-dist/ -type d -name 'win64'         -exec rm -rf {} +
  find $texmf/texmf-dist/ -type d -name 'mswin'         -exec rm -rf {} +
  find $texmf/texmf-dist/ -type d -name 'win'           -exec rm -rf {} +
  find $texmf/texmf-dist/ -type d -name 'setup'         -exec rm -rf {} +
  find $texmf/texmf-dist/ -type d -name 'install'       -exec rm -rf {} +
  find $texmf/texmf-dist/ -type f -name 'uninstall*.sh' -delete
  find $texmf/texmf-dist/ -type f -name '*.bat'         -delete
  find $texmf/texmf-dist/ -type f -name '*.bat.w95'     -delete
  find $texmf/texmf-dist/ -type f -name '*.vbs'         -delete
  find $texmf/texmf-dist/ -type f -name '*win32*'       -delete
  find $texmf/texmf-dist/ -type f -name 'winansi*'      -delete
  find $texmf/texmf-dist/ -type f -name '*man1.pdf'     -delete
  find $texmf/texmf-dist/ -type f -name '*man5.pdf'     -delete
  find $texmf/texmf-dist/ -type f -name '*.man'         -delete
  find $texmf/texmf-dist/ -type f -empty -delete
  find $texmf/texmf-dist/ -type d -empty -delete

  echo "Replace duplicate files by symlinks, this may take a while ..."
  LASTSIZE=x
  find $texmf/texmf-dist/ -type f -printf '%s %p\n' | sort -n |
  while read -r SIZE FILE
  do
    # symlinks also need some bytes, start linking above the typical
    # symlink-size(depends on the filesystem though)
    if [ "$SIZE" -gt 128 -a "$SIZE" == "$LASTSIZE" ]
    then
      if [ "$(sha512sum $FILE | cut -d' ' -f1)" \
        == "$(sha512sum $LASTFILE | cut -d' ' -f1)" ]
      then
        echo "$FILE $LASTFILE $SIZE" >> $TMP/duplicates.$edition
        ln -srf $FILE $LASTFILE
      fi
    fi
    LASTSIZE="$SIZE"
    LASTFILE="$FILE"
  done 
}

texmfget () {
  # make sure no package is added more than once.
  echo "Preparing index of packages to be added to -${1} ..."
  echo "$PACKAGES" | sed "s/[[:space:]]//g;s/#.*$//;/^$/d" > $collections_tobedone
  # Remove outputfile if already present
  >$output
  >$output_doc
  
  # Only do something if $collection wasn't already done before
  while [ -s $collections_tobedone ]
  do
    collection=$(tail -n1 $collections_tobedone)
  
    # continue with next collection if collection was already done
    if [ -s "$collections_done" ]
    then
      grep -w "^${collection}$" $collections_done &> /dev/null
      if [ $? = 0 ]
      then
        # remove from $collections_tobedone
        sed -i "/^$collection$/d" $collections_tobedone
        if [ -n "$(grep "^${collection} added to" $logfile)" ]
        then
          echo "$collection already added " >> $logfile
        fi
        continue
      fi
    fi
    
    package_meta $collection || exit 1
 
    # If $collection is a singel package(not a collection-), add it here
    if [ -n "$(head -n1 $texmf/$collection.meta | grep -v "name collection" )" ]
    then
      unset addpackage 
      # if package contains docs, add to docs-packages
      if [ -n "$(grep ^docfiles $texmf/$collection.meta)" ]
      then
        echo "$collection" >> $output_doc
        echo "$collection added to docs $1" >> $logfile
        addpackage=yes 
      fi
      # if package contains runfiles, binfiles or depend, add to edition
      if [ \
	   -n "$(grep ^runfiles $texmf/$collection.meta)" -o \
           -n "$(grep ^binfiles $texmf/$collection.meta)" -o \
           -n "$(grep ^depend $texmf/$collection.meta)" \
	 ]
      then
        echo "$collection" >> $output
        echo "$collection added to -$1" >> $logfile
        addpackage=yes 
      fi
      # if package contains only srcfiles, don't add to a edition
      if [ -n "$(grep ^srcfiles $texmf/$collection.meta)" -a -z "$addpackage" ]
      then
        echo "$collection only contains srcfiles, added nowhere" >> $logfile
        addpackage=yes
      fi
      # abort if package seems broken
      if [ -z "$addpackage" ]
      then
        echo "$collection doesn't contain any docfiles/runfiles/binfiles/depends or srcfiles"
        echo "Please exclude package/report to upstream mailinglist tex-live@tug.org, bye."
        exit 1
      fi
    fi

    # Don't handle collections as dependency of other collections,
    # as this destroys control over packages to be added. 
    # Add dependend packages, but no binary(ARCH) and no packages
    # containing a '.'. Packages with dot indicate binary/texlive-manager/windows packages
    
    grep ^"depend " $texmf/$collection.meta | cut -d' ' -f2- > $dependencies
    
    if [ -s "$dependencies" ]
    then
      # check for .ARCH packages which may be binaries, scripts or links.
      # Binaries are provided by texlive.SlackBuild
      for dependency in $(cat $dependencies)
      do
        echo $dependency | grep '\.ARCH'$ &>/dev/null
        if [ $? = 0 ] 
        then
          for arch in $platforms
          do
            archpackage="$(echo $dependency | sed "s/\.ARCH$/\.$arch/")"
            grep ^"name $archpackage"$ $db &>/dev/null && echo "$archpackage" >> $dependencies.verified_arch
          done
        else
          echo $dependency >> $dependencies.verified_arch
        fi
      done
      if [ -f $dependencies.verified_arch ]
      then
        mv $dependencies.verified_arch $dependencies
      else
        rm $dependencies
      fi
    fi

    if [ -s "$dependencies" ]
    then
      echo "----------------" >> $logfile
      echo "Dependencies of $collection: $(cat $dependencies | tr '\n' ' ')" >> $logfile
      for dependency in $(cat $dependencies)
      do
        if [ -n "$(grep ^"${dependency}"$ $collections_done)" ]
        then
          sed -i "/^${dependency}$/d" $dependencies
          continue
        else
          for exclude in $global_exclude
          do
            if [ "$exclude" = "$dependency" ]
            then
              sed -i "/^${exclude}$/d" $dependencies
              echo "$exclude excluded, see \$global_exclude" >> $logfile
            fi
          done
        fi
      done
      cat $dependencies >> $collections_tobedone
      echo "----------------" >> $logfile
    fi
    
    sed -i "/^${collection}$/d" $collections_tobedone
    echo "$collection" >> $collections_done
  done
  # handle package index list per edition
  cat $output >> $TMP/packages.$1
  # handle doc package index, one for each edition
  cat $output_doc >> $TMP/packages.$1.doc

  # untar only one $edition, untar docs together with -extra edition
  if [ "$1" = $edition -o docs = $edition ]
  then
    cd $texmf
    # Cleanup tar-directory
    [ -d $texmf/texmf-dist ] && rm -rf $texmf/texmf-dist
    mkdir $texmf/texmf-dist
    
    # Make tarball/checksum reproducible by setting mtime(clamp-mtime),
    # owner, group and sort content.
    # --clamp-mtime --mtime doesn't work with tar 1.13,
    # when makepkg creates the tarball:
    # tar-1.13: time_t value 9223372036854775808 too large (max=68719476735)
    echo "Adding files to $( echo $tarball | rev | cut -d'/' -f1 | rev ) ..."
    case $edition in
      base)
      unset flavour
      untar $output || exit 1
      remove_cruft || exit 1
      tar rf $tarball --owner=0 --group=0 --sort=name texmf-dist || exit 1
      rm -rf texmf-dist
      ;;
      extra)
      unset flavour
      untar $output || exit 1
      export flavour=".doc"
      untar $output_doc || exit 1
      remove_cruft || exit 1
      #tar vrf $tarball --clamp-mtime --mtime --owner=0 --group=0 --sort=name texmf-dist || exit 1
      tar rf $tarball --owner=0 --group=0 --sort=name texmf-dist || exit 1
      rm -rf texmf-dist
      ;;
      docs)
      export flavour=".doc"
      # only add -base docs to -docs
      if [ $1 = base ]
      then
        untar $output_doc || exit 1
        remove_cruft || exit 1
        #tar vrf $tarball --clamp-mtime --mtime --owner=0 --group=0 --sort=name texmf-dist || exit 1
        tar rf $tarball --owner=0 --group=0 --sort=name texmf-dist || exit 1
        rm -rf texmf-dist
      fi
      ;;
    esac
  fi
}

lint () {

echo "Comparing content of all editions, this may take a while ..." 
cd $TMP
# check if all editions of same VERSION are there, take -base as reference
if [ -s texlive-extra-$VERSION.tar.xz \
  -a -s texlive-docs-$VERSION.tar.xz  ]
then
  for edition in base extra docs
  do
    echo "Extracting index of texlive-${edition}-$VERSION.tar.xz ..."
    # don't list directories
    tar tf texlive-${edition}-$VERSION.tar.xz | grep -v '/'$ > $TMP/packages.$edition.lint
  done

  # compare content
  for edition in base extra docs
  do
    >$TMP/packages.$edition.lint.dup
    if [ $edition = base ]
    then
      echo "check if files of base are present in another edition"
      while read line
      do
        grep ^"$line"$ $TMP/packages.extra.lint >> $TMP/packages.base.lint.dup
        grep ^"$line"$ $TMP/packages.docs.lint >> $TMP/packages.base.lint.dup
      done < $TMP/packages.$edition.lint
    fi
  done
else
  echo "Not all editions are present to lint them. Create them first by"
  echo "$0 [base|docs|extra]"
  echo "bye."
  exit 1
fi

exit 0

}

# Main

LANG=C
output=$TMP/packages
output_doc=$TMP/packages.doc.tmp
errorlog=$TMP/error.log
texmf=$TMP/texmf
db=$TMP/texlive.tlpdb
tmpfile=$TMP/tmpfile
collections_done=$TMP/done
collections_tobedone=$TMP/tobedone
allcollections=$TMP/allcollections
binary_removed=$TMP/binaries.removed
manpages=$TMP/manpages
dependencies=$TMP/deps
packages_base=$TMP/packages.base
packages_extra=$TMP/packages.extra
packages_manpages=$TMP/packages.manpages
updmap=$TMP/updmap.cfg
files_split=$TMP/files.split
platforms="x86_64-linux i386-linux"

# Source global excludes
source $CWD/excludes.texmf

mkdir -p $texmf
cd $TMP

case "$1" in
  base|docs|extra) edition=$1;;
  lint) lint ;;
  *) usage; exit 0 ;;
esac

echo "Building $edition tarball ..."

# Set VERSION, get texlive.tlpdb and strip it, keep texlive.tlpdb.orig 
if [ ! -s ${db}.orig -o ! -s $db -o ! -s VERSION ]
then
  for run in {1..10}
  do
    wget -q --show-progress -t1 -c -O ${db}.orig.xz ${mirror}tlpkg/texlive.tlpdb.xz
    [ -s "${db}.orig.xz" ] && break
  done
  unxz -f ${db}.orig.xz || exit 1
  echo $(date +%y%m%d) > VERSION

  # remove most content from $db to be faster on later processing. 
  # keep dependencies/manpages/binfiles/shortdesc/sizes
  echo "Preparing texlive.tlpdb ..."
  grep -E \
    '^\S|^ RELOC/doc/man|^ texmf-dist/doc/man/man|^ RELOC/doc/info/|^ texmf-dist/doc/info/|^ bin|^$' \
    ${db}.orig | grep -v ^longdesc > $db
  
  # As $db might be renewed, remove the all package meta-files
  # to make them be created again based on (new) $db
  rm -rf $texmf/*.meta
fi

# Get linenumbers of empty lines from $db
emptylines="$(grep -n ^$ $db | cut -d':' -f1)"

# Make a list of all collections
grep ^"name collection-" $db | cut -d' ' -f2 > $allcollections
# remove global excluded collection(s)
for exclude in $global_exclude
do
  sed -i "/^$exclude/d" $allcollections
done

# translate .ARCH to platforms in excludes, to make .ARCH packages excludeable by $global_exclude
for exclude in $global_exclude
do
  if [ -n "$(echo $exclude | grep '\.ARCH'$ )" ]
  then
    for arch in $platforms
    do
      global_exclude+=" $(echo $exclude | sed "s/\.ARCH$/\.$arch/")" 
    done
    global_exclude=${global_exclude/$exclude/}
  fi
done
 
VERSION=$(cat $TMP/VERSION)
tarball=$TMP/texlive-$edition-$VERSION.tar
# set logfile
logfile=$TMP/$VERSION.log

# reset some files
>$logfile
>$tarball
>$collections_done
>$files_split
>$manpages
>$packages_manpages
>$updmap.$edition
>$packages_base
>$packages_extra
>$packages_base.doc
>$packages_extra.doc
>$TMP/duplicates.$edition
>$TMP/packages.$edition.meta
>$TMP/packages.$edition.meta.uncompressed
>$TMP/provides.run.$edition
>$TMP/depends.run.$edition
>$binary_removed.$edition

# Load texmf package list to generate -base/-extra/-docs
source $CWD/packages.texmf

# Put everything in -extra which is not in -base
PACKAGES="
  $(cat $allcollections)
  " texmfget extra

# Check if all collections are part in at least one edition
while read collection
do
  grep -w "$collection" $collections_done &> /dev/null
  if [ $? != 0 ]
  then
    echo "Error: $collection was not handled."
    echo "Edit packages/collections in the texmfget function." | tee -a $logfile
    exit 1
  fi
done < $allcollections

# cleanup 
rm $allcollections
rm $collections_done
rm $collections_tobedone
rm $output
rm $output_doc
rm $dependencies

# untar special- and manpage packages to be splitted/moved to other editions
# splitting special packages, files index
echo "Prepare index of to be splitted/moved files from -base"
[ ! -d texmf-dist ] && mkdir texmf-dist
for package in $special_packages
do
  echo "Splitting $package"
  # special packages have to be in -base, as only here are special
  # tasks done to reduce size of -base edition
  if [ -z "$( grep ^"$package"$ $packages_base )" ]
  then
    echo "$package was not found to be part of -base"
    echo "Edit \$special_packages in $0,"
    echo "it should contain only packages from -base, bye."
    exit 1
  fi
  unset relocated
  pathprefix="texmf-dist/"
  [ -n "$(grep -w ^"relocated 1" $texmf/$package.meta)" ] && \
    relocated="-C texmf-dist" && unset pathprefix
  # avoid big pdf docs which are also present as html
  # move (big)type1 fonts to -extra
  # $files_split lists files to be moved from -base to -extra
  tar tf $texmf/${package}.tar.xz | sed \
  -ne "/.*doc\/latex\/.*\.pdf$/p" \
  -ne "/.*fonts\/map\/.*\.map$/p" \
  -ne "/.*fonts\/enc\/.*\.enc$/p" \
  -ne "/.*fonts\/afm\/.*\.\(afm\|afm\.gz\)$/p" \
  -ne "/.*fonts\/type1\/.*\.pfb$/p" \
  -ne "/.*fonts\/vf\/.*\.vf$/p" | \
    tee -a $files_split > $files_split.tmp

  if [ $edition = base ]
  then
    # Calculate package-minimal size, uncompressed and compressed
    mkdir -p calculate/texmf-dist
    tar xf $texmf/$package.tar.xz -C calculate/texmf-dist --exclude-from=$files_split.tmp
    tar cf calculate/calc.tar.xz -I 'xz' calculate/texmf-dist
    size_minimal=$(du -bc calculate/calc.tar.xz | tail -n1 | sed "s/[[:space:]].*//")
    size_minimal_uncompressed="$(xz -l --verbose calculate/calc.tar.xz | grep "Uncompressed size" | cut -d'(' -f2 | cut -d' ' -f1 )"
    sed -i \
      -e "s/^[0-9]* byte, $package: /$size_minimal byte, $package-minimal: /" \
      $output.base.meta
    sed -i \
      -e "s/^[0-9]* byte, $package: /$size_minimal_uncompressed byte, $package-minimal: /" \
      $output.base.meta.uncompressed
    rm -rf calculate
  fi
  
  if [ $edition = extra ]
  then
    mkdir -p calculate/texmf-dist
    tar xf $texmf/${package}.tar.xz -C calculate/texmf-dist $(paste $files_split.tmp)
    tar cf calculate/calc.tar.xz -I 'xz' calculate/texmf-dist
    size_extended=$(du -bc calculate/calc.tar.xz | tail -n1 | sed "s/[[:space:]].*//")
    size_extended_uncompressed="$(xz -l --verbose calculate/calc.tar.xz | \
      grep "Uncompressed size" | cut -d'(' -f2 | cut -d' ' -f1 )"
 
    # put new sizes in package index uncompressed
    sed -i \
      -e "s/^[0-9]* byte, $package: /$size_extended byte, $package-extended: /" \
      $output.extra.meta
    sed -i \
      -e "s/^[0-9]* byte, $package: /$size_extended_uncompressed byte, $package-extended: /" \
      $output.extra.meta.uncompressed
    rm -rf calculate
    
    # put map files from splitted packages in -extra
    mkdir meta_tmp
    tar xf $texmf/${package}.tar.xz -C meta_tmp tlpkg/tlpobj/$package.tlpobj
    grep ^'execute ' meta_tmp/tlpkg/tlpobj/$package.tlpobj | \
      grep Map | cut -d' ' -f2- | sed "s/^add//g" >> $updmap.$edition
    rm -rf meta_tmp
  fi
 
  # untar to provide files for -extra
  tar xf $texmf/${package}.tar.xz $relocated $(paste $files_split.tmp)
done

# cleanup
rm $files_split.tmp

# fix relocation in index for splitted packages
sed -i \
  -e "s|^doc|texmf-dist\/doc|g" \
  -e "s|^fonts|texmf-dist\/fonts|g" \
  -e "s|^dvips|texmf-dist\/dvips|g" \
  $files_split

# sort meta data about added packages
sort -n $output.$edition.meta > $tmpfile
mv $tmpfile $output.$edition.meta 
sort -n $output.$edition.meta.uncompressed > $tmpfile
mv $tmpfile $output.$edition.meta.uncompressed 

sort -u $binary_removed.$edition > $tmpfile
mv $tmpfile $binary_removed.$edition

# include manpages/GNU infofiles in -base, write index for later exclusion from other editions.
# In -extra/-docs there should not be any manpage left.
echo "Looking for manpages/GNU infofiles to be included in -base ..."
for package in $(paste -s $packages_base.doc | sort -u)
do
  if [ -n "$(grep -E "(doc/man/man|doc/info/)" $texmf/$package.meta )" ]
  then
    echo "Adding manpage from $package.doc to -base"
    flavour=".doc" download $package || exit 1
    unset relocated
    pathprefix="texmf-dist/"
    [ -n "$(grep -w ^"relocated 1" $texmf/$package.meta)" ] \
      && relocated="-C texmf-dist" && unset pathprefix
    tar tf $texmf/${package}.doc.tar.xz | sed \
    -ne "/.*doc\/man\/.*\.1$/p" \
    -ne "/.*doc\/man\/.*\.5$/p" \
    -ne "/.*doc\/info\/.*\.info$/p" \
    | tee -a $manpages > $manpages.tmp
    # untar to provide files for -/extra/-docs
    tar xf $texmf/${package}.doc.tar.xz $relocated $(paste $manpages.tmp)
    echo "$package" >> $packages_manpages
  fi
done 

# cleanup
rm $manpages.tmp
sed -i \
  -e "s/^doc/texmf-dist\/doc/g" \
  $manpages
  
case $edition in
  base) 
  # Provide index of Tex packages
  cat << EOF | gzip -9 >> $texmf/texmf-dist/packages.$edition.gz
Content of -$edition:
$(sed "/-linux$/d" $packages_base | sort)
EOF
  # create texdoc cache file
  if [ $(command -v texdoc) ]
  then
    mkdir -p texmf-dist/scripts/texdoc || exit 1
    TEXMFVAR=$texmf/texmf-dist \
      texdoc -c texlive_tlpdb=$TMP/texlive.tlpdb.orig \
      -DlM texlive-en >/dev/null 2>&1 
    mv texmf-dist/texdoc/cache-tlpdb.lua \
      texmf-dist/scripts/texdoc/Data.tlpdb.lua || exit 1
    # add cache to tarball
    tar rf $tarball --owner=0 --group=0 --sort=name \
      texmf-dist/scripts/texdoc/Data.tlpdb.lua || exit 1
  else
    echo "WARNING: texdoc binary(comming with texlive) is not installed, the texdoc cache"
    echo "Data.tlpdb.lua can't be created and wont't be available."
    echo "Texdoc will not wotk without this."
    echo ""
    echo "Continue with any key or abort with ctrl-c"
    read -n1
  fi

  # prepare updmap.cfg
  tar xf $tarball texmf-dist/web2c/updmap.cfg
  end_n="$(grep -n 'end of updmap-hdr' texmf-dist/web2c/updmap.cfg | cut -d':' -f1)"
  
  sed "1,${end_n}!d" texmf-dist/web2c/updmap.cfg > $TMP/updmap.cfg.tmp
  cat $updmap.$edition >> $TMP/updmap.cfg.tmp
  mv $TMP/updmap.cfg.tmp texmf-dist/web2c/updmap.cfg
  tar f $tarball --delete texmf-dist/web2c/updmap.cfg
  tar rf $tarball --owner=0 --group=0 --sort=name \
    texmf-dist/web2c/updmap.cfg

  # add manpages/GNU infofiles to the tarball
  tar rf $tarball --owner=0 --group=0 --sort=name \
    texmf-dist/doc/man/ texmf-dist/doc/info/ \
    texmf-dist/packages.$edition.gz \
    || exit 1
  echo "Removing files -from base, splitted from special packages to be included in -extra"
  tar f $tarball --delete $(paste $files_split) || exit 1
  ;;
  extra)
  echo "Removing manpages from $edition which now reside in -base" 
  tar f $tarball --delete $(paste $manpages) 2>/dev/null 
  # content info
  echo "Content of -$edition, including documentation:" > $texmf/texmf-dist/packages.$edition
  sed "/-linux$/d" $TMP/packages.$edition | sort >> $texmf/texmf-dist/packages.$edition
  gzip -9 $texmf/texmf-dist/packages.$edition

  # add -extra updmap.cfg
  mkdir -p $texmf/texmf-dist/web2c
  mv $updmap.$edition $texmf/texmf-dist/web2c
  tar rf $tarball --owner=0 --group=0 --sort=name \
    --exclude texmf-dist/doc \
    texmf-dist \
    || exit 1
  ;;
  docs)
  # add docs splittet from base from special packages, add packages index
  # content info, this edition contains all docs from -base
  echo "Content of -$edition, documentation for -base:" > $texmf/texmf-dist/packages.$edition
  sort $packages_base.doc >> $texmf/texmf-dist/packages.$edition
  gzip -9 $texmf/texmf-dist/packages.$edition
  tar rf $tarball --owner=0 --group=0 --sort=name \
    texmf-dist/doc/ \
    texmf-dist/packages.$edition.gz \
    || exit 1
  echo "Removing manpages from $edition which now reside in -base" 
  tar f $tarball --delete $(paste $manpages) || exit 1
  ;;
esac
  
rm -rf texmf-dist
[ -f $updmap.$edition ] && rm $updmap.$edition

# compress the tarball as everything is in place now
echo "Compressing $tarball ..."
[ -f $tarball.xz ] && rm $tarball.xz
xz -T0 $tarball || exit 1
ls -lh $tarball.xz
echo "Logfile: $logfile"

# End of story
