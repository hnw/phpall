#! /bin/sh

php_pkgs=`find . -path './php-5.*.tar.gz'`
if [ -z "$php_pkgs" ]; then
    no_targz=true
else
    for php_pkg in $php_pkgs; do
        if [ ! -d `basename $php_pkg .tar.gz` ]; then
            tar xvzf $php_pkg
        fi
    done
fi
php_pkgs=`find . -path './php-5.*.tar.bz2'`
if [ -z "$php_pkgs" ]; then
    no_tarbz2=true
else
    for php_pkg in "$php_pkgs"; do
        if [ ! -d `basename $php_pkg .tar.bz2` ]; then
            tar xvjf $php_pkg
        fi
    done
fi

if [ $no_targz -a $no_tarbz2 ]; then
    echo "No PHP package found: place php-5.*.tar.{gz,bz2} in this directory."
fi

php_dirs=`find . -type d -path './php-5.0.[0123]'`
if [ -n "$php_dirs" ]; then
    for php_dir in php-5.0.[0123]; do
        cd $php_dir
        perl -i.bak -pe 's|(#include "zend.h")|\1\n#include "zend_compile.h"|' Zend/zend_modules.h
        cd ..
    done
fi

CFLAGS=
CONFIGURE_OPTS="--enable-mbstring --disable-cgi"

case `uname` in
  Darwin)
    CFLAGS="-fnested-functions"
    if [ -f  /opt/local/lib/libxml2.dylib -a -f /opt/local/lib/libiconv.dylib ]; then
        CONFIGURE_OPTS="--with-libxml-dir=/opt/local -with-iconv=/opt/local --enable-mbstring --disable-cgi"
    else
        CONFIGURE_OPTS="--disable-mbstring --disable-cgi"
    fi
    ;;
esac

php_dirs=`find . -type d -path './php-5.0.?'`
if [ -n "$php_dirs" ]; then
    for php_dir in $php_dirs; do
        if [ ! -f $php_dir/sapi/cli/php ]; then
            cd $php_dir
            CFLAGS=$CFLAGS ./configure $CONFIGURE_OPTS
            make
            cd ..
        fi
    done
fi

php_dirs=`find . -type d -path './php-5.[1-9].?'`
if [ -n "$php_dirs" ]; then
    for php_dir in $php_dirs; do
        if [ ! -f $php_dir/sapi/cli/php ]; then
            cd $php_dir
            ./configure --enable-mbstring --disable-cgi || ( autoconf && ./configure --enable-mbstring --disable-cgi && touch .done_autoconf )
            make
            cd ..
        fi
    done
fi

mkdir -p $HOME/bin

php_dirs=`find . -type d -path './php-5.?.?'`
if [ -n "$php_dirs" ]; then
    for php_dir in $php_dirs; do
        if [ -f $php_dir/sapi/cli/php ]; then
            install $php_dir/sapi/cli/php $HOME/bin/$php_dir
        fi
    done
fi
