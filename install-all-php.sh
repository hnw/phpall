#! /bin/sh

php_gz_pkgs=`find . -maxdepth 1 -type f -name 'php-5.*.*.tar.gz' | egrep '\.[0-9]+((alpha|RC)[0-9]+)?\.tar\.gz$'`
php_bz2_pkgs=`find . -maxdepth 1 -type f -name 'php-5.*.*.tar.bz2' | egrep '\.[0-9]+((alpha|RC)[0-9]+)?\.tar\.bz2$'`

if [ -z "$php_gz_pkgs" -a -z "$php_bz2_pkgs" ]; then
    echo "cannot access php-5.*.tar.{gz,bz2}: No PHP package found"
    exit
fi

if [ -n "$php_gz_pkgs" ]; then
    for php_pkg in $php_gz_pkgs; do
        if [ ! -d `basename $php_pkg .tar.gz` ]; then
            tar xvzf $php_pkg
        fi
    done
fi
if [ -n "$php_bz2_pkgs" ]; then
    for php_pkg in $php_bz2_pkgs; do
        if [ ! -d `basename $php_pkg .tar.bz2` ]; then
            tar xvjf $php_pkg
        fi
    done
fi

old_php_dirs=`find . -maxdepth 1 -type d -name 'php-5.0.[0123]*' | egrep '\.[0-3]((alpha|RC)[0-9]+)?$'`

if [ -n "$old_php_dirs" ]; then
    for php_dir in $old_php_dirs; do
        cd $php_dir
        perl -i.bak -pe 's|(#include "zend.h")|\1\n#include "zend_compile.h"|' Zend/zend_modules.h
        cd ..
    done
fi

CFLAGS=
EXTRA_LIBS=
CONFIGURE_OPTS="--enable-mbstring --disable-cgi --with-zlib --with-bz2 --with-bcmath"

case `uname` in
  Darwin)
    CFLAGS="-fnested-functions"
    if [ `uname -r | cut -d . -f 1` -ge 10 ]; then
        # add -lresolv for MacOS 10.6 or later
        # via: http://stackoverflow.com/questions/1204440/errors-linking-libresolv-when-building-php-5-2-10-from-source-on-os-x
        EXTRA_LIBS=-lresolv
    fi
    if [ -f /usr/lib/libssl.dylib ]; then
        CONFIGURE_OPTS="$CONFIGURE_OPTS --with-openssl=/usr"
    fi
    if [ -f /opt/local/lib/libxml2.dylib ]; then
        # MacPorts
        CONFIGURE_OPTS="$CONFIGURE_OPTS --with-libxml-dir=/opt/local"
    elif [ -f /usr/local/lib/libxml2.dylib ]; then
        # Homebrew
        CONFIGURE_OPTS="$CONFIGURE_OPTS --with-libxml-dir=/usr/local"
    else
        # MacOSX stock
        CONFIGURE_OPTS="$CONFIGURE_OPTS --with-libxml-dir=/usr"
    fi
    if [ -f /opt/local/lib/libiconv.dylib ]; then
        # MacPorts
        CONFIGURE_OPTS="$CONFIGURE_OPTS --with-iconv=/opt/local"
    elif [ -f /usr/local/lib/libiconv.dylib ]; then
        # Homebrew
        CONFIGURE_OPTS="$CONFIGURE_OPTS --with-iconv=/usr/local"
    else
        # MacOSX stock libiconv is not compatible, so disabled.
        CONFIGURE_OPTS="$CONFIGURE_OPTS --without-iconv"
    fi
    ;;
esac

php_dirs=`find . -maxdepth 1 -type d -name 'php-5.*.*' | egrep '\.[0-9]+((alpha|RC)[0-9]+)?$'`

if [ -n "$php_dirs" ]; then
    for php_dir in $php_dirs; do
        if [ ! -f $php_dir/sapi/cli/php ]; then
            cd $php_dir
            CFLAGS=$CFLAGS EXTRA_LIBS=$EXTRA_LIBS ./configure $CONFIGURE_OPTS
            make
            cd ..
        fi
    done
fi

mkdir -p $HOME/bin

if [ -n "$php_dirs" ]; then
    for php_dir in $php_dirs; do
        if [ -f $php_dir/sapi/cli/php ]; then
            install $php_dir/sapi/cli/php $HOME/bin/$php_dir
        fi
    done
fi
