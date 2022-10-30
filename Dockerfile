FROM php:8.1-apache

ARG AKAUNTING_DOCKERFILE_VERSION=0.1
ARG SUPPORTED_LOCALES="en_US.UTF-8"

RUN apt-get update \
   && apt-get -y upgrade --no-install-recommends \
   && apt-get install --no-install-recommends -y imagemagick libfreetype6 libicu libjpeg62-turbo \
      libjpeg libmcrypt libonig libpng libpq libssl libxml2 libxrender1 libzip locales openssl unzip zip zlib1g \
   && apt-get clean && rm -rf /var/lib/apt/lists/* \
   && for locale in ${SUPPORTED_LOCALES}; do \
      sed -i 's/^# '"${locale}/${locale}/" /etc/locale.gen; done \
   && locale-gen \
   && docker-php-ext-configure gd --with-freetype --with-jpeg \
   && docker-php-ext-install -j$(nproc) gd bcmath intl mbstring pcntl pdo pdo_mysql zip \
   && mkdir -p /var/www/akaunting \
   && curl -Lo /tmp/akaunting.zip 'https://akaunting.com/download.php?version=latest&utm_source=docker&utm_campaign=developers' \
   && unzip /tmp/akaunting.zip -d /var/www/html \
   && rm -f /tmp/akaunting.zip

COPY  /files/php-container/ /

ENTRYPOINT ["/usr/local/bin/akaunting.sh"]
CMD ["--start"]
