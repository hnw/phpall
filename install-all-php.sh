#! /bin/sh

dirname=`dirname $0`

php_gz_pkgs=`find . -maxdepth 1 -type f -name 'php-5.*.*.tar.gz' | egrep '\.[0-9]+((alpha|beta|RC)[0-9]+)?\.tar\.gz$'`
php_bz2_pkgs=`find . -maxdepth 1 -type f -name 'php-5.*.*.tar.bz2' | egrep '\.[0-9]+((alpha|beta|RC)[0-9]+)?\.tar\.bz2$'`
php_xz_pkgs=`find . -maxdepth 1 -type f -name 'php-5.*.*.tar.xz' | egrep '\.[0-9]+((alpha|beta|RC)[0-9]+)?\.tar\.xz$'`

if [ -z "$php_gz_pkgs" -a -z "$php_bz2_pkgs" -a -z "$php_xz_pkgs" ]; then
    echo "cannot access php-5.*.tar.{gz,bz2,xz}: No PHP package found"
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

# Compiling PHP 5.0.0-5.0.3 with gcc4
#  see: http://bugs.php.net/32150

old_php_dirs=`find . -maxdepth 1 -type d -name 'php-5.0.[0123]*' | egrep '\.[0-3]((alpha|beta|RC)[0-9]+)?$'`

if [ -n "$old_php_dirs" ]; then
    for php_dir in $old_php_dirs; do
        cd $php_dir
        patch -p1 -N < $dirname/patches/patch-gcc4-for-php5.0.3.txt
        cd ..
    done
fi

# To work with OpenSSL 1.0+
#  for PHP 5.0.x, 5.1.x
#
# see: http://bugs.php.net/48116
# see: http://bugs.php.net/50859

old_php_dirs=`find . -maxdepth 1 -type d -name 'php-5.[01].[0-9]'`

if [ -n "$old_php_dirs" ]; then
    for php_dir in $old_php_dirs; do
        cd $php_dir
        patch -p1 -N < $dirname/patches/patch-openssl1.0.0-for-php5.1.6.txt
        cd ..
    done
fi

# To work with OpenSSL 1.0+
#  for PHP 5.2.0-5.2.6

old_php_dirs=`find . -maxdepth 1 -type d -name 'php-5.2.[0-6]'`

if [ -n "$old_php_dirs" ]; then
    for php_dir in $old_php_dirs; do
        cd $php_dir
        patch -p1 -N < $dirname/patches/patch-openssl1.0.0-for-php5.2.6.txt
        cd ..
    done
fi

# To work with OpenSSL 1.0+
#  for PHP 5.2.7 - 5.2.12
#
# Note: Patching to PHP 5.2.11 and 5.2.12 failed partialy, but no problem.

old_php_dirs=`find . -maxdepth 1 -type d \( -name 'php-5.2.[7-9]' -or -name 'php-5.2.1[0-2]' \)`

if [ -n "$old_php_dirs" ]; then
    for php_dir in $old_php_dirs; do
        cd $php_dir
        patch -p1 -N < $dirname/patches/patch-openssl1.0.0-for-php5.2.10.txt
        cd ..
    done
fi

# To work with OpenSSL 1.0+
#  for PHP 5.3.0 - 5.3.1
#
# Note: Patching to PHP 5.3.1 failed partialy, but no problem.

old_php_dirs=`find . -maxdepth 1 -type d -name 'php-5.3.[0-1]'`

if [ -n "$old_php_dirs" ]; then
    for php_dir in $old_php_dirs; do
        cd $php_dir
        patch -p1 -N < $dirname/patches/patch-openssl1.0.0-for-php5.3.0.txt
        cd ..
    done
fi

# To work with libxml2 2.9.0+
#  for PHP 5.0.x, 5.1.x

old_php_dirs=`find . -maxdepth 1 -type d \( -name 'php-5.0.[0-5]' -or -name 'php-5.1.[0-6]' \)`

if [ -n "$old_php_dirs" ]; then
    for php_dir in $old_php_dirs; do
        cd $php_dir
        patch -p1 -N < $dirname/patches/patch-to-php5.1.6-with-libxml2-2.9.txt
        cd ..
    done
fi

# To work with libxml2 2.9.0+
#  for PHP 5.2.0-5.2.11, 5.3.0

old_php_dirs=`find . -maxdepth 1 -type d \( -name 'php-5.2.[0-9]' -or -name 'php-5.2.1[01]' -or -name 'php-5.3.0' \)`

if [ -n "$old_php_dirs" ]; then
    for php_dir in $old_php_dirs; do
        cd $php_dir
        patch -p1 -N < $dirname/patches/patch-to-php5.3.0-with-libxml2-2.9.txt
        cd ..
    done
fi

# To work with libxml2 2.9.0+
#  for PHP 5.2.12-5.2.17, 5.3.1-5.3.16, 5.4.0-5.4.6
old_php_dirs=`find . -maxdepth 1 -type d \( -name 'php-5.2.1[2-7]' -or -name 'php-5.3.[1-9]' -or -name 'php-5.3.1[0-6]' -or -name 'php-5.4.[0-6]' \)`

if [ -n "$old_php_dirs" ]; then
    for php_dir in $old_php_dirs; do
        cd $php_dir
        patch -p1 -N < $dirname/patches/patch-to-php5.4.6-with-libxml2-2.9.txt
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

php_dirs=`find . -maxdepth 1 -type d -name 'php-5.*.*' | egrep '\.[0-9]+((alpha|beta|RC)[0-9]+)?$'`

# configure & make
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

# installing PHP binaries
if [ -n "$php_dirs" ]; then
    for php_dir in $php_dirs; do
        if [ -f $php_dir/sapi/cli/php ]; then
            install $php_dir/sapi/cli/php $HOME/bin/$php_dir
        fi
    done
fi
