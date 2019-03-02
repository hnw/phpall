#! /bin/bash

usage_exit() {
        echo "Usage: $0 [-j N] " 1>&2
        exit 1
}

NJOB=""

while getopts j:h OPT
do
    case $OPT in
        j)  NJOB=$OPTARG
            ;;
        h)  usage_exit
            ;;
        \?) usage_exit
            ;;
    esac
done

shift $((OPTIND - 1))

dirname=$(cd $(dirname $0);pwd)

php_gz_pkgs=`find . -maxdepth 1 -type f -name 'php-[57].*.*.tar.gz' | egrep '\.[0-9]+((alpha|beta|RC)[0-9]+)?\.tar\.gz$'`
php_bz2_pkgs=`find . -maxdepth 1 -type f -name 'php-[57].*.*.tar.bz2' | egrep '\.[0-9]+((alpha|beta|RC)[0-9]+)?\.tar\.bz2$'`
php_xz_pkgs=`find . -maxdepth 1 -type f -name 'php-[57].*.*.tar.xz' | egrep '\.[0-9]+((alpha|beta|RC)[0-9]+)?\.tar\.xz$'`

if [ -z "$php_gz_pkgs" -a -z "$php_bz2_pkgs" -a -z "$php_xz_pkgs" ]; then
    echo "cannot access php-[57].*.tar.{gz,bz2,xz}: No PHP package found"
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

if [ -n "$php_xz_pkgs" ]; then
    for php_pkg in $php_xz_pkgs; do
        if [ ! -d `basename $php_pkg .tar.xz` ]; then
            tar xvf $php_pkg
        fi
    done
fi

# Supporting gcc4 for PHP 5.0.0-5.0.3
#  see: http://bugs.php.net/32150

old_php_dirs=`find . -maxdepth 1 -type d -name 'php-5.0.[0123]*' | egrep '\.[0-3]((alpha|beta|RC)[0-9]+)?$'`

if [ -n "$old_php_dirs" ]; then
    for php_dir in $old_php_dirs; do
        cd $php_dir
        patch -p1 -N < $dirname/patches/patch-to-php-5.0.3-for-supporting-gcc4.txt
        cd ..
    done
fi

# Supporting OpenSSL 1.0+
#  for PHP 5.0.x, 5.1.x
#
# see: http://bugs.php.net/48116
# see: http://bugs.php.net/50859

old_php_dirs=`find . -maxdepth 1 -type d -name 'php-5.[01].[0-9]'`

if [ -n "$old_php_dirs" ]; then
    for php_dir in $old_php_dirs; do
        cd $php_dir
        patch -p1 -N < $dirname/patches/patch-to-php-5.1.6-with-openssl-1.0.0.txt
        cd ..
    done
fi

# Supporting OpenSSL 1.0+
#  for PHP 5.2.0-5.2.6

old_php_dirs=`find . -maxdepth 1 -type d -name 'php-5.2.[0-6]'`

if [ -n "$old_php_dirs" ]; then
    for php_dir in $old_php_dirs; do
        cd $php_dir
        patch -p1 -N < $dirname/patches/patch-to-php-5.2.6-with-openssl-1.0.0.txt
        cd ..
    done
fi

# Supporting OpenSSL 1.0+
#  for PHP 5.2.7 - 5.2.12
#
# Note: Patching to PHP 5.2.11 and 5.2.12 failed partialy, but no problem.

old_php_dirs=`find . -maxdepth 1 -type d \( -name 'php-5.2.[7-9]' -or -name 'php-5.2.1[0-2]' \)`

if [ -n "$old_php_dirs" ]; then
    for php_dir in $old_php_dirs; do
        cd $php_dir
        patch -p1 -N < $dirname/patches/patch-to-php-5.2.10-with-openssl-1.0.0.txt
        cd ..
    done
fi

# Supporting OpenSSL 1.0+
#  for PHP 5.3.0 - 5.3.1
#
# Note: Patching to PHP 5.3.1 failed partialy, but no problem.

old_php_dirs=`find . -maxdepth 1 -type d -name 'php-5.3.[0-1]'`

if [ -n "$old_php_dirs" ]; then
    for php_dir in $old_php_dirs; do
        cd $php_dir
        patch -p1 -N < $dirname/patches/patch-to-php-5.3.0-with-openssl-1.0.0.txt
        cd ..
    done
fi

# Supporting SSLv2-disabled OpenSSL for PHP < 5.3.7
# (via: https://bugs.php.net/bug.php?id=54736)
#
# Note: Patching to PHP 5.0.0, 5.0.1 failed partialy, but no problem.

old_php_dirs=`find . -maxdepth 1 -type d \( -name 'php-5.[012].*' -or -name 'php-5.3.[0-6]' \)`

if [ -n "$old_php_dirs" ]; then
    for php_dir in $old_php_dirs; do
        cd $php_dir
        patch -p1 -N < $dirname/patches/patch-to-php-5.3.6-with-openssl-disabled-sslv2.txt
        cd ..
    done
fi

# Supporting libxml2 2.9.0+
#  for PHP 5.0.x, 5.1.x

old_php_dirs=`find . -maxdepth 1 -type d \( -name 'php-5.0.[0-5]' -or -name 'php-5.1.[0-6]' \)`

if [ -n "$old_php_dirs" ]; then
    for php_dir in $old_php_dirs; do
        cd $php_dir
        patch -p1 -N < $dirname/patches/patch-to-php-5.1.6-with-libxml2-2.9.txt
        cd ..
    done
fi

# Supporting libxml2 2.9.0+
#  for PHP 5.2.0-5.2.11, 5.3.0

old_php_dirs=`find . -maxdepth 1 -type d \( -name 'php-5.2.[0-9]' -or -name 'php-5.2.1[01]' -or -name 'php-5.3.0' \)`

if [ -n "$old_php_dirs" ]; then
    for php_dir in $old_php_dirs; do
        cd $php_dir
        patch -p1 -N < $dirname/patches/patch-to-php-5.3.0-with-libxml2-2.9.txt
        cd ..
    done
fi

# Supporting libxml2 2.9.0+
#  for PHP 5.2.12-5.2.17, 5.3.1-5.3.16, 5.4.0-5.4.6

old_php_dirs=`find . -maxdepth 1 -type d \( -name 'php-5.2.1[2-7]' -or -name 'php-5.3.[1-9]' -or -name 'php-5.3.1[0-6]' -or -name 'php-5.4.[0-6]' \)`

if [ -n "$old_php_dirs" ]; then
    for php_dir in $old_php_dirs; do
        cd $php_dir
        patch -p1 -N < $dirname/patches/patch-to-php-5.4.6-with-libxml2-2.9.txt
        cd ..
    done
fi

# To fix configuration problem in oniguruma with PHP 5.0.x
# see: https://bugs.php.net/bug.php?id=34977

old_php_dirs=`find . -maxdepth 1 -type d -name 'php-5.0.[0-5]'`

if [ -n "$old_php_dirs" ]; then
    for php_dir in $old_php_dirs; do
        cd $php_dir
        patch -p1 -N < $dirname/patches/patch-to-php-5.0.5-with-oniguruma-configuration.txt
        cd ..
    done
fi

# Change inline to static inline for C99 compliance
#  with PHP 5.0.0-5.0.3

old_php_dirs=`find . -maxdepth 1 -type d -name 'php-5.0.[0-3]'`

if [ -n "$old_php_dirs" ]; then
    for php_dir in $old_php_dirs; do
        cd $php_dir
        patch -p1 -N < $dirname/patches/patch-to-php-5.0.3-for-supporting-c99.txt
        cd ..
    done
fi

# for PHP 5.2.12 with MacOSX 10.5
#  see:http://bugs.php.net/50508
# T.B.D.

CFLAGS=
EXTRA_LIBS=
CONFIGURE_OPTS="--enable-mbstring --disable-cgi --with-zlib --with-bz2 --enable-bcmath"

case `uname` in
  Darwin)
    #CFLAGS="-fnested-functions"
    if [ `uname -r | cut -d . -f 1` -ge 10 ]; then
        # add -lresolv for MacOS 10.6 or later
        # via: http://stackoverflow.com/questions/1204440/errors-linking-libresolv-when-building-php-5-2-10-from-source-on-os-x
        EXTRA_LIBS=-lresolv
    fi
    if hash brew 2>/dev/null && [ -n "$(brew list | grep '^openssl$')" ]; then
        CONFIGURE_OPTS="$CONFIGURE_OPTS --with-openssl=$(brew --prefix openssl)"
    elif [ -f /usr/lib/libssl.dylib ]; then
        CONFIGURE_OPTS="$CONFIGURE_OPTS --with-openssl=/usr"
    fi
    if [ -f /opt/local/lib/libxml2.dylib ]; then
        # MacPorts
        CONFIGURE_OPTS="$CONFIGURE_OPTS --with-libxml-dir=/opt/local"
    elif [ -f /usr/local/lib/libxml2.dylib ]; then
        # Homebrew
        CONFIGURE_OPTS="$CONFIGURE_OPTS --with-libxml-dir=/usr/local"
    elif hash brew 2>/dev/null && [ -n "$(brew list | grep '^libxml2$')" ]; then
        # Homebrew
        CONFIGURE_OPTS="$CONFIGURE_OPTS --with-libxml-dir=$(brew --prefix libxml2)"
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
    elif hash brew 2>/dev/null && [ -n "$(brew list | grep '^libiconv$')" ]; then
        # Homebrew
        CONFIGURE_OPTS="$CONFIGURE_OPTS --with-iconv=$(brew --prefix libiconv)"
    else
        # MacOSX stock libiconv is not compatible, so disabled.
        CONFIGURE_OPTS="$CONFIGURE_OPTS --without-iconv"
    fi
    ;;
esac

php_dirs=`find . -maxdepth 1 -type d -name 'php-[57].*.*' | egrep '\.[0-9]+\.[0-9]+((alpha|beta|RC)[0-9]+)?$'`

MAKE_OPTS=""
if [ -n "$NJOB" ]; then
    MAKE_OPTS="$MAKE_OPTS -j $NJOB"
fi

# configure & make
if [ -n "$php_dirs" ]; then
    for php_dir in $php_dirs; do
        if [ ! -f $php_dir/sapi/cli/php ]; then
            cd $php_dir
            CFLAGS=$CFLAGS EXTRA_LIBS=$EXTRA_LIBS ./configure $CONFIGURE_OPTS
            make $MAKE_OPTS
            cd ..
        fi
    done
fi

mkdir -p $HOME/bin

# installing PHP binaries
if [ -n "$php_dirs" ]; then
    for php_dir in $php_dirs; do
        if [ -f $php_dir/sapi/cli/php ]; then
            install $php_dir/sapi/cli/php $HOME/bin/$php_dir
        fi
    done
fi
