FROM alpine:3.3

MAINTAINER Alexey Kutepov <reximkut@gmail.com>

ENV OTP_VERSION 19.0

# Download the Erlang/OTP source
RUN mkdir /buildroot
WORKDIR /buildroot
ADD https://github.com/erlang/otp/archive/OTP-${OTP_VERSION}.tar.gz .
RUN tar zxf OTP-${OTP_VERSION}.tar.gz

# Install additional packages
RUN apk add --no-cache autoconf && \
    apk add --no-cache alpine-sdk && \
    apk add --no-cache openssl-dev

# Build Erlang/OTP
WORKDIR otp-OTP-${OTP_VERSION}
RUN ./otp_build autoconf && \
    CFLAGS="-Os" ./configure --prefix=/buildroot/erlang/${OTP_VERSION} --without-termcap --disable-hipe && \
    make -j10

# Install Erlang/OTP
RUN mkdir -p /buildroot/erlang/${OTP_VERSION} && \
    make install

# Install Rebar3
RUN mkdir -p /buildroot/rebar3/bin
ADD https://s3.amazonaws.com/rebar3/rebar3 /buildroot/rebar3/bin/rebar3
RUN chmod a+x /buildroot/rebar3/bin/rebar3

# Setup Environment
ENV PATH=/buildroot/erlang/${OTP_VERSION}/bin:/buildroot/rebar3/bin:$PATH

# Reset working directory
WORKDIR /buildroot

# Add Tsoder application
RUN mkdir tsoder/
COPY . tsoder/
WORKDIR tsoder/
RUN rebar3 release -o /artifacts

# Create a volume
RUN mkdir -p /artifacts/tsoder/state/
RUN mkdir -p /tmp/tsoder.mnesia/
# TODO(#85): Document how to properly backup the volume
VOLUME ["/artifacts/tsoder/state/"]
VOLUME ["/tmp/tsoder.mnesia/"]

# Run the tsoder application
CMD ["/artifacts/tsoder/bin/tsoder", "foreground"]
