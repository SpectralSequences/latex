FROM debian:bookworm-slim

RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update -q \
    && apt-get install -qy build-essential wget libfontconfig1 time git sudo perl \
    && rm -rf /var/lib/apt/lists/*

ARG tlyear
ENV TEXLIVE_VERSION=$tlyear
ENV TEXLIVE_URL=ftp://tug.org/historic/systems/texlive/$TEXLIVE_VERSION

RUN wget $TEXLIVE_URL/install-tl-unx.tar.gz \
    && mkdir /install-tl-unx    \
    && tar -xvf install-tl-unx.tar.gz -C /install-tl-unx --strip-components=1 \
    && echo "selected_scheme scheme-basic" >> /install-tl-unx/texlive.profile \
# Generally we want to use the final repo from the given texlive version
    && export TEXLIVE_REPO_FLAG="-repository $TEXLIVE_URL/tlnet-final/"  \
# Check if tlnet-final exists (should exist for all but the most recent version of texlive)
    && export TLPDB_EXISTS="$(wget $TEXLIVE_URL/tlnet-final/tlpkg/texlive.tlpdb  -v --spider   2>&1  | grep exists )" \
# If tlnet-final doesn't exist (most recent texlive) then use default repo
    && if [ -z "$TLPDB_EXISTS" ]; then export TEXLIVE_REPO_FLAG="" ; fi  \
    && /install-tl-unx/install-tl -profile /install-tl-unx/texlive.profile -no-verify-downloads $TEXLIVE_REPO_FLAG \
    && rm -r /install-tl-unx    \
    && rm /install-tl-unx.tar.gz

# Determine architecture for PATH
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "aarch64" ]; then \
        echo "export PATH=/usr/local/texlive/$TEXLIVE_VERSION/bin/aarch64-linux:\$PATH" >> /etc/profile.d/texlive.sh; \
    else \
        echo "export PATH=/usr/local/texlive/$TEXLIVE_VERSION/bin/x86_64-linux:\$PATH" >> /etc/profile.d/texlive.sh; \
    fi

ENV PATH="/usr/local/texlive/$TEXLIVE_VERSION/bin/x86_64-linux:/usr/local/texlive/$TEXLIVE_VERSION/bin/aarch64-linux:${PATH}"

RUN tlmgr install \
        latexmk \
# Needed by (at least one of) spectralsequences examples
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
        luatex85 \
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
# For l3build
        luatex \
        latex-bin \
        platex \
        uplatex \
        tex \
        xetex \
# soulpos comes from either bezos (<= 2018) or soulpos (>= 2019)
# bezos went away entirely in 2018.
    && (tlmgr install soulpos || tlmgr install bezos) \
# soulutf8 comes from either oberdiek (<= 2018) or soulutf8 (>= 2019)
    && (tlmgr install soulutf8 || true) \
# zref comes from either oberdiek (<= 2018) or zref (>= 2019)
    && (tlmgr install zref || true) \
# luahbtex needed by l3build, only available in versions >= 2020
    && (tlmgr install luahbtex || true) \
# hypdoc needed to build documentation, only available in >= 2022
    && (tlmgr install hypdoc || true) \
    && (tlmgr install ms || true) \
# tikzfill needed by tcolorbox in >= 2023
    && (tlmgr install tikzfill || true) \
    && tlmgr option -- autobackup 0


# Install l3build. We need a common version independent of the texlive version
# so we do a custom install.
RUN git clone --branch patches --depth 1 https://github.com/hoodmane/l3build.git \
    && cd l3build   \
    && chmod 755 l3build.lua    \
    && ln -s /l3build/l3build.lua /usr/local/bin/l3build \
# Need to install in a place accessible from both root and other users. This
# path also doesn't have a year in it which is nice.
    && ./l3build.lua install --texmfhome /usr/local/texlive/texmf-local/ \
    && texhash

ENV SAVED_PATH="${PATH}"
WORKDIR /src
