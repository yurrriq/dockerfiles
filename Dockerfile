FROM debian:jessie
MAINTAINER Eric Bailey

# Dependencies
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    apt-utils \
    build-essential \
    libncurses5-dev \
    openssl \
    libssl-dev \
    fop \
    xsltproc \
    unixodbc-dev \
    git \
    autoconf \
    ca-certificates \
    libcurl4-openssl-dev \
    curl \
    git

# OTP
ENV OTP_VERSION 18.2.4
RUN set -xe \
    && OTP_REPO="https://github.com/erlang/otp" \
    && OTP_TARBALL="OTP-$OTP_VERSION.tar.gz" \
    && OTP_DOWNLOAD_URL="$OTP_REPO/archive/$OTP_TARBALL" \
    && OTP_DOWNLOAD_SHA1="4c8d90feb15b58c6b5929413b056c419166d7fc4" \
    && OTP_SRC="/usr/src/otp-src" \
    && curl -fSLO "$OTP_DOWNLOAD_URL" \
    && echo "$OTP_DOWNLOAD_SHA1 $OTP_TARBALL" | sha1sum -c - \
    && mkdir -p $OTP_SRC \
    && tar -xzf $OTP_TARBALL -C $OTP_SRC --strip-components=1 \
    && rm $OTP_TARBALL \
    && cd $OTP_SRC \
    && ./otp_build autoconf \
    && ./configure \
    && make -j$(nproc) \
    && make install \
    && find /usr/local -name examples | xargs rm -rf \
    && rm -rf $OTP_SRC

# LFE
ENV LFE_VERSION 0.10.1
ENV LFE_HOME /opt/erlang/lfe
RUN set -xe \
    && LFE_REPO="https://github.com/rvirding/lfe" \
    && LFE_TARBALL="$LFE_VERSION.tar.gz" \
    && LFE_DOWNLOAD_URL="$LFE_REPO/archive/$LFE_TARBALL" \
    && LFE_DOWNLOAD_SHA1="7c8f351758d270dea482707d5fcb4de82fe3862f" \
    && curl -fSLO "$LFE_DOWNLOAD_URL" \
    && echo "$LFE_DOWNLOAD_SHA1 $LFE_TARBALL" | sha1sum -c - \
    && mkdir -p $LFE_HOME \
    && tar -xzf $LFE_TARBALL -C $LFE_HOME --strip-components=1 \
    && rm $LFE_TARBALL \
    && cd $LFE_HOME \
    && PATH="bin:$PATH" \
    && make compile; \
    make compile install

# rebar3
ENV REBAR3_VERSION beta-4
RUN set -xe \
    && REBAR3_REPO="https://github.com/rebar/rebar3" \
    && REBAR3_TARBALL="$REBAR3_VERSION.tar.gz" \
    && REBAR3_DOWNLOAD_URL="$REBAR3_REPO/archive/$REBAR3_TARBALL" \
    && REBAR3_DOWNLOAD_SHA1="a7c7776d511631f61d1e6ec565baf10b96b32449" \
    && REBAR3_SRC="/usr/src/rebar3-src" \
    && curl -fSLO "$REBAR3_DOWNLOAD_URL" \
    && echo "$REBAR3_DOWNLOAD_SHA1 $REBAR3_TARBALL" | sha1sum -c - \
    && mkdir -p $REBAR3_SRC \
    && tar -xzf $REBAR3_TARBALL -C $REBAR3_SRC --strip-components=1 \
    && rm $REBAR3_TARBALL \
    && cd $REBAR3_SRC \
    && HOME=$PWD ./bootstrap \
    && install -v ./rebar3 /usr/local/bin/ \
    && rm -rf $REBAR3_SRC

# pandoc
ENV PANDOC_VERSION 1.16.0.2
RUN set -xe \
    && PANDOC_REPO="https://github.com/jgm/pandoc/releases/" \
    && PANDOC_DEB="pandoc-$PANDOC_VERSION-1-amd64.deb" \
    && PANDOC_DOWNLOAD_URL="$PANDOC_REPO/download/$PANDOC_VERSION/$PANDOC_DEB" \
    && PANDOC_DOWNLOAD_SHA1="62897204ce29adf67966566b4a08f02b64c09bf2" \
    && curl -fSLO "$PANDOC_DOWNLOAD_URL" \
    && echo "$PANDOC_DOWNLOAD_SHA1 $PANDOC_DEB" | sha1sum -c - \
    && dpkg -i $PANDOC_DEB \
    && rm $PANDOC_DEB

# Clean APT.
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Define mountable directories.
VOLUME ["/usr/src"]

# Define working directory.
WORKDIR /usr/src

# Define default command.
CMD ["rebar3", "compile"]
