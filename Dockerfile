FROM alpine:3.12

RUN apk add --update --no-cache build-base

ENV MECAB_VERSION 0.996
ENV IPADIC_VERSION 2.7.0-20070801
ENV mecab_url https://src.fedoraproject.org/lookaside/pkgs/mecab/mecab-0.996.tar.gz/7603f8975cea2496d88ed62545ba973f/mecab-0.996.tar.gz
ENV ipadic_url https://codeload.github.com/neologd/mecab-ipadic-neologd/tar.gz/
ENV build_deps 'curl git bash file sudo openssh'
ENV dependencies 'openssl'
ENV NEOLODG_VERSION=0.0.6

RUN apk add --update --no-cache ${build_deps} \
  # Install dependencies

  && apk add --update --no-cache ${dependencies} \

  # Install MeCab
  && echo "========= start mecab install =========\r" \
  && curl -SL -o mecab-${MECAB_VERSION}.tar.gz ${mecab_url} \
  && tar zxf mecab-${MECAB_VERSION}.tar.gz -C /tmp \
  && cd /tmp/mecab-${MECAB_VERSION} \
  && ./configure --enable-utf8-only --with-charset=utf8 \
  && make \
  && make install \
  && cd \
  && echo "========= finished mecab installed =========\r" \

  # Install IPA dic
  && echo "========= start IPA dic install =========\r" \
  && curl -SL -o mecab-ipadic-${NEOLODG_VERSION}.tar.gz ${ipadic_url}/v${NEOLODG_VERSION} \
  && tar zxf mecab-ipadic-${NEOLODG_VERSION}.tar.gz -C /tmp \
  && cd /tmp/mecab-ipadic-neologd-${NEOLODG_VERSION} \
  && ls -lt \
  && ./bin/install-mecab-ipadic-neologd -n -y -a \
  && cd \
  && echo "========= finished IPA dic installed =========\r" \

  # Install Neologd
  && echo "========= start install Neologd =========\r" \
  && git clone --depth 1 https://github.com/neologd/mecab-ipadic-neologd.git \
  && mecab-ipadic-neologd/bin/install-mecab-ipadic-neologd -n -y \
  && echo " ========= finished Neologd installed =========\r" \

  # Clean up
  && apk del ${build_deps} \
  && rm -rf \
    /tmp/mecab-${MECAB_VERSION}* \
    /tmp/mecab-${IPADIC_VERSION}* \
    mecab-ipadic-neologd \
  && echo " ========= cleaned up all directories in /tmp =========\r"

CMD ["mecab", "-d", "/usr/local/lib/mecab/dic/mecab-ipadic-neologd"]
