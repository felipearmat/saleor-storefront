FROM node:10 as builder

# Instalando dependencias e copiando arquivos
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .

# ARGs e ENVs
ARG API_URI
ARG SENTRY_DSN
ARG SENTRY_APM
ARG DEMO_MODE
ARG GTM_ID
ENV API_URI ${API_URI:-http://localhost:8000/graphql/}

# Build do App
RUN API_URI=${API_URI} npm run build

###############################################
# Nginx docker image with pagespeed module
FROM nginx:alpine as deploy

# Upgrade libs for security
RUN apk upgrade

# Cópia do build
WORKDIR /app
COPY --from=builder /app/dist/ .

# Configuração do nginx
COPY ./nginx/nginx.conf /etc/nginx/nginx.conf
COPY ./nginx/server.conf /etc/nginx/sites-available/default
RUN mkdir /etc/nginx/sites-enabled && ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled
RUN ln -sf /dev/stdout /var/log/nginx/access.log && ln -sf /dev/stderr /var/log/nginx/error.log

# Portas a serem expostas
EXPOSE 80
