FROM tiredofit/nodejs:10-debian-latest
LABEL maintainer="Alenas Kisonas"

### Set defaults
ENV ASTERISK_VERSION=18.2.1 \
    FREEPBX_VERSION=15.0.17.26 \
    BCG729_VERSION=1.0.4 \
    G72X_CPUHOST=penryn \
    G72X_VERSION=0.1 \
    PHP_VERSION=5.6 \
    SPANDSP_VERSION=20180108 \
    RTP_START=18000 \
    RTP_FINISH=18200

RUN apt-get update && apt-get upgrade -y

### Pin libxml2 packages to Debian repositories
RUN echo "Package: libxml2*" > /etc/apt/preferences.d/libxml2 && \
    echo "Pin: release o=Debian,n=buster" >> /etc/apt/preferences.d/libxml2 && \
    echo "Pin-Priority: 501" >> /etc/apt/preferences.d/libxml2 && \
    APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=TRUE && \
    \
### Install dependencies
    set -x && \
    curl https://packages.sury.org/php/apt.gpg | apt-key add - && \
    echo "deb https://packages.sury.org/php/ buster main" > /etc/apt/sources.list.d/deb.sury.org.list && \
    echo "deb http://deb.debian.org/debian buster-backports main" > /etc/apt/sources.list.d/backports.list && \
    echo "deb-src http://deb.debian.org/debian buster-backports main" >> /etc/apt/sources.list.d/backports.list && \
### Update system
    apt-get update && \
    apt-get -o Dpkg::Options::="--force-confold" upgrade -y && \
    \
### Install development dependencies
    ASTERISK_BUILD_DEPS='\
                        autoconf \
                        automake \
                        bison \
                        binutils-dev \
                        build-essential \
                        doxygen \
                        flex \
                        graphviz \
                        libasound2-dev \
                        libc-client2007e-dev \
                        libcfg-dev \
                        libcodec2-dev \
                        libcorosync-common-dev \
                        libcpg-dev \
                        libcurl4-openssl-dev \
                        libedit-dev \
                        libfftw3-dev \
                        libgmime-2.6-dev \
                        libgsm1-dev \
                        libical-dev \
                        libiksemel-dev \
                        libjansson-dev \
                        libldap2-dev \
                        liblua5.2-dev \
                        libmariadb-dev \
                        libmariadbclient-dev \
                        libmp3lame-dev \
                        libncurses5-dev \
                        libneon27-dev \
                        libnewt-dev \
                        libogg-dev \
                        libopus-dev \
                        libosptk-dev \
                        libpopt-dev \
                        libradcli-dev \
                        libresample1-dev \
                        libsndfile1-dev \
                        libsnmp-dev \
                        libspeex-dev \
                        libspeexdsp-dev \
                        libsqlite3-dev \
                        libsrtp2-dev \
                        libssl-dev \
                        libtiff-dev \
                        libtool-bin \
                        libunbound-dev \
                        liburiparser-dev \
                        libvorbis-dev \
                        libvpb-dev \
                        libxml2-dev \
                        libxslt1-dev \
                        linux-headers-amd64 \
                        portaudio19-dev \
                        python-dev \
                        subversion \
                        unixodbc-dev \
                        uuid-dev \
                        zlib1g-dev' && \
    \
### Install runtime dependencies
    apt-get install --no-install-recommends -y \
                    $ASTERISK_BUILD_DEPS \
                    apache2 \
                    composer \
                    fail2ban \
                    ffmpeg \
                    flite \
                    freetds-dev \
                    git \
                    g++ \
                    iptables \
                    lame \
                    libavahi-client3 \
                    libc-client2007e \
                    libcfg7 \
                    libcpg4 \
                    libgmime-2.6 \
                    libical3 \
                    libiodbc2 \
                    libiksemel3 \
                    libicu63 \
                    libicu-dev \
                    libneon27 \
                    libosptk4 \
                    libresample1 \
                    libsnmp30 \
                    libspeexdsp1 \
                    libsrtp2-1 \
                    libunbound8 \
                    liburiparser1 \
                    libvpb1 \
                    locales \
                    locales-all \
                    make \
                    mariadb-client \
                    mpg123 \
                    odbc-mariadb \
                    php${PHP_VERSION} \
                    php${PHP_VERSION}-curl \
                    php${PHP_VERSION}-cli \
                    php${PHP_VERSION}-mysql \
                    php${PHP_VERSION}-gd \
                    php${PHP_VERSION}-mbstring \
                    php${PHP_VERSION}-intl \
                    php${PHP_VERSION}-bcmath \
                    php${PHP_VERSION}-ldap \
                    php${PHP_VERSION}-xml \
                    php${PHP_VERSION}-zip \
                    php${PHP_VERSION}-sqlite3 \
                    php-pear \
                    pkg-config \
                    sipsak \
                    sngrep \
                    socat \
                    sox \
                    sqlite3 \
                    tcpdump \
                    tcpflow \
                    unixodbc \
                    uuid \
                    wget \
                    whois \
                    xmlstarlet && \
    \
### Add users
    addgroup --gid 2600 asterisk && \
    adduser --uid 2600 --gid 2600 --gecos "Asterisk User" --disabled-password asterisk && \
    \
### Build SpanDSP
    mkdir -p /usr/src/spandsp && \
    curl -kL http://sources.buildroot.net/spandsp/spandsp-${SPANDSP_VERSION}.tar.gz | tar xvfz - --strip 1 -C /usr/src/spandsp && \
    cd /usr/src/spandsp && \
    ./configure --prefix=/usr && \
    make && \
    make install && \
    \
### Build Asterisk
    cd /usr/src && \
    mkdir -p asterisk && \
    curl -sSL http://downloads.asterisk.org/pub/telephony/asterisk/releases/asterisk-${ASTERISK_VERSION}.tar.gz | tar xvfz - --strip 1 -C /usr/src/asterisk && \
    cd /usr/src/asterisk/ && \
    make distclean && \
    contrib/scripts/get_mp3_source.sh && \
    cd /usr/src/asterisk && \
    ./configure \
        --with-jansson-bundled \
        --with-pjproject-bundled \
        --with-codec2 \
        --with-crypto \
        --with-gmime \
        --with-iconv \
        --with-iksemel \
        --with-inotify \
        --with-ldap \
        --with-libxml2 \
        --with-libxslt \
        --with-lua \
        --with-ogg \
        --with-opus \
        --with-resample \
        --with-spandsp \
        --with-speex \
        --with-sqlite3 \
        --with-srtp \
        --with-unixodbc \
        --with-uriparser \
        --with-vorbis \
        --with-vpb \
        && \
    \
    make menuselect/menuselect menuselect-tree menuselect.makeopts && \
    menuselect/menuselect --disable BUILD_NATIVE \
                          --enable-category MENUSELECT_ADDONS \
                          --enable-category MENUSELECT_APPS \
                          --enable-category MENUSELECT_CHANNELS \
                          --enable-category MENUSELECT_CODECS \
                          --enable-category MENUSELECT_FORMATS \
                          --enable-category MENUSELECT_FUNCS \
                          --enable-category MENUSELECT_RES \
                          --enable BETTER_BACKTRACES \
                          --disable MOH-OPSOUND-WAV \
                          --enable MOH-OPSOUND-GSM \
                          --disable app_voicemail_imap \
                          --disable app_voicemail_odbc \
                          --disable res_digium_phone \
                          --disable codec_g729a && \
    make && \
    make install && \
    make install-headers && \
    make config

#### Add G729 codecs
RUN git clone https://github.com/BelledonneCommunications/bcg729 /usr/src/bcg729 && \
    cd /usr/src/bcg729 && \
    git checkout tags/$BCG729_VERSION && \
    ./autogen.sh && \
    ./configure --prefix=/usr --libdir=/lib && \
    make && \
    make install && \
    \
    mkdir -p /usr/src/asterisk-g72x && \
    curl https://bitbucket.org/arkadi/asterisk-g72x/get/master.tar.gz | tar xvfz - --strip 1 -C /usr/src/asterisk-g72x && \
    cd /usr/src/asterisk-g72x && \
    ./autogen.sh && \
    ./configure --prefix=/usr --with-bcg729 --enable-$G72X_CPUHOST && \
    make && \
    make install && \
    \
    ldconfig
    
### Cleanup
RUN mkdir -p /var/run/fail2ban && \
    cd / && \
    rm -rf /usr/src/* /tmp/* /etc/cron* && \
    apt-get purge -y $ASTERISK_BUILD_DEPS && \
    apt-get -y autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
    
### FreePBX hacks
RUN sed -i -e "s/memory_limit = 128M/memory_limit = 256M/g" /etc/php/${PHP_VERSION}/apache2/php.ini && \
    sed -i 's/\(^upload_max_filesize = \).*/\120M/' /etc/php/${PHP_VERSION}/apache2/php.ini && \
    a2disconf other-vhosts-access-log.conf && \
    a2enmod rewrite && \
    a2enmod headers && \
    rm -rf /var/log/* && \
    mkdir -p /var/log/asterisk && \
    mkdir -p /var/log/apache2 && \
    mkdir -p /var/log/httpd
    
### Setup for data persistence
RUN mkdir -p /assets/config/var/lib/ /assets/config/home/ && \
    mv /home/asterisk /assets/config/home/ && \
    mv /var/lib/asterisk /assets/config/var/lib/ && \
    ln -s /data/var/lib/asterisk /var/lib/asterisk && \
    mkdir -p /assets/config/var/run/ && \
    mv /var/run/asterisk /assets/config/var/run/ && \
    mkdir -p /assets/config/var/spool && \
    mv /var/spool/cron /assets/config/var/spool/ && \
    ln -s /data/var/spool/cron /var/spool/cron && \
    ln -s /data/var/run/asterisk /var/run/asterisk && \
    rm -rf /var/spool/asterisk && \
    ln -s /data/var/spool/asterisk /var/spool/asterisk && \
    rm -rf /etc/asterisk && \
    ln -s /data/etc/asterisk /etc/asterisk && \
    ln -s /data/etc/fail2ban /etc/fail2ban

### Networking configuration
EXPOSE 80 443 4445 4569 5060/udp 5160/udp 5061 5161 8001 8003 8088 8089 18000-18200/udp

### Files add
ADD install /
