FROM debian:buster-slim

RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update -q \
    && apt-get install -qy build-essential wget libfontconfig1 \
    && rm -rf /var/lib/apt/lists/*

ARG tlyear
ENV TEXLIVE_VERSION=$tlyear
ENV TEXLIVE_URL=ftp://tug.org/historic/systems/texlive/$TEXLIVE_VERSION

# Install TexLive with scheme-basic
# Check if tlnew-f
RUN wget $TEXLIVE_URL/install-tl-unx.tar.gz ; \
    mkdir /install-tl-unx   ; \
    tar -xvf install-tl-unx.tar.gz -C /install-tl-unx --strip-components=1 ; \
    echo "selected_scheme scheme-basic" >> /install-tl-unx/texlive.profile ; \
    export TEXLIVE_REPO_FLAG="-repository $TEXLIVE_URL/tlnet-final/"  ; \
    export TLPDB_EXISTS="$(wget $TEXLIVE_URL/tlnet-final/tlpkg/texlive.tlpdb  -v --spider   2>&1  | grep exists )"; \
    if [ -z "$TLPDB_EXISTS" ]; then export TEXLIVE_REPO_FLAG="" ; fi ; \
    /install-tl-unx/install-tl -profile /install-tl-unx/texlive.profile $TEXLIVE_REPO_FLAG

ENV PATH="/usr/local/texlive/$TEXLIVE_VERSION/bin/x86_64-linux:${PATH}"

# Install latex packages
RUN tlmgr install \
    latexmk \
    pgf \
    etoolbox \
    pdfcomment \
    xkeyval \
    datetime2 \
    tracklang \
    zref \
    marginnote \
    soul    \
    soulpos \
    soulutf8

WORKDIR /src