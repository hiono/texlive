FROM alpine:latest AS installer
MAINTAINER onohr <bps@sculd.com>
ENV PATH /usr/local/bin/texlive:$PATH
ARG TEXMFLOCAL=/usr/local/texlive/texmf-local/tex/latex
WORKDIR /install-tl-unx
RUN apk add --no-cache fontconfig perl tar wget xz
COPY ./texlive.profile ./
RUN wget -nv https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
RUN tar -xzf ./install-tl-unx.tar.gz --strip-components=1
RUN ./install-tl --profile=texlive.profile
RUN ln -sf /usr/local/texlive/*/bin/* /usr/local/bin/texlive
RUN tlmgr install \
  collection-fontsrecommended \
  collection-langjapanese \
  collection-latexextra \
  latexmk
# for additional modules
## pseudo code modules
RUN wget http://captain.kanpaku.jp/LaTeX/jlisting.zip \
    && unzip jlisting.zip \
    && mkdir -p ${TEXMFLOCAL}/listings \
    && cp jlisting/jlisting.sty ${TEXMFLOCAL}/listings
RUN wget http://mirrors.ctan.org/macros/latex/contrib/algorithms.zip \
    && unzip algorithms.zip \
    && cd algorithms \
    && latex algorithms.ins \
    && mkdir -p ${TEXMFLOCAL}/algorithms \
    && cp *.sty ${TEXMFLOCAL}/algorithms
RUN wget http://mirrors.ctan.org/macros/latex/contrib/algorithmicx.zip \
    && unzip algorithmicx.zip \
    && mkdir -p ${TEXMFLOCAL}/algorithmicx \
    && cp algorithmicx/*.sty ${TEXMFLOCAL}/algorithmicx

FROM alpine:latest
MAINTAINER onohr <bps@sculd.com>
ENV PATH /usr/local/bin/texlive:$PATH
WORKDIR /workdir
COPY --from=installer /usr/local/texlive /usr/local/texlive
RUN apk add --no-cache bash fontconfig perl
RUN ln -sf /usr/local/texlive/*/bin/* /usr/local/bin/texlive
CMD ["bash"]
