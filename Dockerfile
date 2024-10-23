# Utilisation de l'image de base PHP avec Nginx
FROM webdevops/php-nginx:8.3-alpine

# Déclaration des variables d'argument pour la base de données
ARG DB_CONNECTION
ARG DB_HOST
ARG DB_PORT
ARG DB_DATABASE
ARG DB_USERNAME
ARG DB_PASSWORD
ARG DB_URL

# Installation des dépendances nécessaires pour PHP
RUN apk add --no-cache oniguruma-dev libxml2-dev \
    && docker-php-ext-install \
        bcmath \
        ctype \
        fileinfo \
        mbstring \
        xml

# Installation de Composer à partir d'une image existante
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Installation de NodeJS et npm
RUN apk add --no-cache nodejs npm

# Définition des variables d'environnement pour le serveur web
ENV WEB_DOCUMENT_ROOT /app/public
ENV APP_ENV production

# Définition des variables d'environnement pour la base de données
ENV DB_CONNECTION=$DB_CONNECTION
ENV DB_HOST=$DB_HOST
ENV DB_PORT=$DB_PORT
ENV DB_DATABASE=$DB_DATABASE
ENV DB_USERNAME=$DB_USERNAME
ENV DB_PASSWORD=$DB_PASSWORD
ENV DB_URL=$DB_URL

# Définition du répertoire de travail
WORKDIR /app

# Copie du code source dans le conteneur
COPY . .

# Copie du fichier .env.example vers .env si .env n'existe pas
RUN cp -n .env.example .env

# Génération de la clé d'application Laravel et mise à jour du fichier .env


# Installation des dépendances PHP avec Composer en mode production
RUN composer install --no-interaction --optimize-autoloader --no-dev

# Optimisation des configurations, routes et vues pour le déploiement
RUN php artisan key:generate
RUN php artisan config:cache
RUN php artisan route:cache
RUN php artisan view:cache

# Installation et compilation des assets front-end avec npm
RUN npm install
RUN npm run build

# Attribution des permissions correctes à l'utilisateur 'application'
RUN chown -R application:application /app
