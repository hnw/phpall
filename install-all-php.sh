#! /bin/sh

php_gz_pkgs=`find . -type f  -maxdepth 1 -name 'php-5.*.tar.gz'`
php_bz2_pkgs=`find . -type f  -maxdepth 1 -name 'php-5.*.tar.bz2'`

if [ -z "$php_gz_pkgs" -a -z "$php_bz2_pkgs" ]; then
    echo "No PHP package found: place php-5.*.tar.{gz,bz2} in this directory."
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

old_php_dirs=`find . -type d  -maxdepth 1 -name 'php-5.0.[0123]*'`
if [ -n "$old_php_dirs" ]; then
    for php_dir in $old_php_dirs; do
        cd $php_dir
        perl -i.bak -pe 's|(#include "zend.h")|\1\n#include "zend_compile.h"|' Zend/zend_modules.h
        cd ..
    done
fi

CFLAGS=
EXTRA_LIBS=
CONFIGURE_OPTS="--enable-mbstring --disable-cgi"

case `uname` in
  Darwin)
    CFLAGS="-fnested-functions"
    if [ `uname -r | cut -d . -f 1` -ge 10 ]; then
        # add -lresolv for MacOS 10.6 or later
        # via: http://stackoverflow.com/questions/1204440/errors-linking-libresolv-when-building-php-5-2-10-from-source-on-os-x
        EXTRA_LIBS=-lresolv
    fi
    if [ -f  /opt/local/lib/libxml2.dylib -a -f /opt/local/lib/libiconv.dylib ]; then
        CONFIGURE_OPTS="--with-libxml-dir=/opt/local -with-iconv=/opt/local --enable-mbstring --disable-cgi"
    else
        CONFIGURE_OPTS="--disable-mbstring --disable-cgi"
    fi
    ;;
esac

php_dirs=`find . -type d -maxdepth 1 '(' -name 'php-5.0.*' -o -name 'php-5.[1-9].*' ')'`
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

#php_dirs=`find . -type d  -path './php-5.[1-9].*'`
#if [ -n "$php_dirs" ]; then
#    for php_dir in $php_dirs; do
#        if [ ! -f $php_dir/sapi/cli/php ]; then
#            cd $php_dir
#            CFLAGS=$CFLAGS EXTRA_LIBS=$EXTRA_LIBS ./configure --enable-mbstring --disable-cgi || ( autoconf && CFLAGS=$CFLAGS EXTRA_LIBS=$EXTRA_LIBS ./configure --enable-mbstring --disable-cgi && touch .done_autoconf )
#            make
#            cd ..
#        fi
#    done
#fi

mkdir -p $HOME/bin

php_dirs=`find . -type d -maxdepth 1 '(' -name 'php-5.0.*' -o -name 'php-5.[1-9].*' ')'`
if [ -n "$php_dirs" ]; then
    for php_dir in $php_dirs; do
        if [ -f $php_dir/sapi/cli/php ]; then
            install $php_dir/sapi/cli/php $HOME/bin/$php_dir
        fi
    done
fi
