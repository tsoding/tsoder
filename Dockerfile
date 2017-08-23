FROM alpine:3.3

MAINTAINER Alexey Kutepov <reximkut@gmail.com>

ENV OTP_VERSION 18.3
ENV TSODER_VERSION master

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

# Run the tsoder application
CMD ["/artifacts/tsoder/bin/tsoder", "foreground"]

# TODO(#75): Bake ACCESS_TOKEN into the docker image
#
# Right now to run the application you have to provide the
# ACCESS_TOKEN for the docker run command like so:
#
# ```console
# $ docker run -e ACCESS_TOKEN="<access-token>" --rm tsoder
# ```
#
# We need to be able provide the ACCESS_TOKEN at the docker build time
# like so:
#
# ```console
# $ docker build --build-arg access_token="<access-token>" -t tsoder .
# $ docker run --rm tsoder
# ```
