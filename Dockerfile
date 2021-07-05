FROM debian:buster-slim

RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update -q \
    && apt-get install -qy build-essential wget libfontconfig1 \
    && rm -rf /var/lib/apt/lists/*

ARG tlyear
ENV TEXLIVE_VERSION=$tlyear
ENV TEXLIVE_URL=ftp://tug.org/historic/systems/texlive/$TEXLIVE_VERSION

RUN wget $TEXLIVE_URL/install-tl-unx.tar.gz ; \
    mkdir /install-tl-unx   ; \
    tar -xvf install-tl-unx.tar.gz -C /install-tl-unx --strip-components=1 ; \
    echo "selected_scheme scheme-basic" >> /install-tl-unx/texlive.profile ; \
# Generally we want to use the final repo from the given texlive version
    export TEXLIVE_REPO_FLAG="-repository $TEXLIVE_URL/tlnet-final/"  ; \
# Check if tlnet-final exists (should exist for all but the most recent version of texlive)
    export TLPDB_EXISTS="$(wget $TEXLIVE_URL/tlnet-final/tlpkg/texlive.tlpdb  -v --spider   2>&1  | grep exists )"; \
# If tlnet-final doesn't exist (most recent texlive) then use default repo
    if [ -z "$TLPDB_EXISTS" ]; then export TEXLIVE_REPO_FLAG="" ; fi ; \
    /install-tl-unx/install-tl -profile /install-tl-unx/texlive.profile -no-verify-downloads $TEXLIVE_REPO_FLAG

ENV PATH="/usr/local/texlive/$TEXLIVE_VERSION/bin/x86_64-linux:${PATH}"

RUN tlmgr install \
        latexmk \
        pgf \
        etoolbox \
        pdfcomment \
        xkeyval \
        datetime2 \
        tracklang \
        marginnote \
        soul    \
        xcolor \
        l3kernel \
        l3packages \
        oberdiek \
        ec \
        ms \
        luatex85 \
        l3build \
# For building the manual
        sansmathfonts \
        needspace \
        tcolorbox \
        environ \
        listings \
        hyperxmp \
        ifmtarg \
        totpages \
        trimspaces \
        zapfding \
        symbol \
        marvosym \
# soulpos comes from either bezos (<= 2018) or soulpos (>= 2019)
# bezos went away entirely in 2018.
    && (tlmgr install soulpos || tlmgr install bezos) \
# soulutf8 comes from either oberdiek (<= 2018) or soulutf8 (>= 2019)
    && (tlmgr install soulutf8 || true) \
# zref comes from either oberdiek (<= 2018) or zref (>= 2019)
    && (tlmgr install zref || true) 

WORKDIR /src