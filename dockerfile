FROM webdevops/php-nginx:8.3-alpine

# Retrieve variables
ARG DB_CONNECTION
ARG DB_HOST
ARG DB_PORT
ARG DB_DATABASE
ARG DB_USERNAME
ARG DB_PASSWORD
ARG DB_URL

# Installation dans votre Image du minimum pour que Docker fonctionnegfgfgfgf
RUN apk add oniguruma-dev libxml2-dev
RUN docker-php-ext-install \
        bcmath \
        ctype \
        fileinfo \
        mbstring \
        xml

# Installation dans votre image de Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Installation dans votre image de NodeJS
RUN apk add nodejs npm

ENV WEB_DOCUMENT_ROOT /app/public
ENV APP_ENV production

ENV APP_ENV production
ENV APP_ENV production

ENV DB_CONNECTION $DB_CONNECTION
ENV DB_HOST $DB_HOST
ENV DB_PORT $DB_PORT
ENV DB_DATABASE $DB_DATABASE
ENV DB_USERNAME $DB_USERNAME
ENV DB_PASSWORD $DB_PASSWORD
ENV DB_URL $DB_URL

WORKDIR /app
COPY . .

# On copie le fichier .env.example pour le renommer en .env
# Vous pouvez modifier le .env.example pour indiquer la configuration de votre site pour la production
RUN cp -n .env.example .env

# Installation et configuration de votre site pour la production
# https://laravel.com/docs/10.x/deployment#optimizing-configuration-loading
RUN composer install --no-interaction --optimize-autoloader --no-dev
# Generate security key
RUN php artisan key:generate
# Optimizing Configuration loading
RUN php artisan config:cache
# Optimizing Route loading
RUN php artisan route:cache
# Optimizing View loading
RUN php artisan view:cache

# Compilation des assets de Breeze (ou de votre site)
RUN npm install
RUN npm run build

RUN chown -R application:application .