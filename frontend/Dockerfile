## Build Phase - Generate production files
# Specify a base image
FROM node:lts-alpine as build

WORKDIR /react

# Copy over everything
COPY . ./

# Validate a project when using Zero-Installs
RUN yarn install --immutable --immutable-cache

# Default Environment Variables
# ARG REACT_APP_BUILD_ID="LOCAL_BUILD"
# ENV REACT_APP_CLIENT_ID REACT_APP_CLIENT_ID_PLACEHOLDER
# ENV REACT_APP_TENANT REACT_APP_TENANT_PLACEHOLDER
# ENV PUBLIC_URL PUBLIC_URL_PLACEHOLDER

# Run prod build (creates build dir with static files)
RUN yarn build

## Run Phase
# Specify a base image
FROM nginx:1.19

WORKDIR /app

RUN apt-get update \
    && apt-get install -y --no-install-recommends openssh-server supervisor \
    && echo "root:Docker!" | chpasswd
RUN mkdir /run/sshd

COPY nginx.conf /etc/nginx/nginx.conf
COPY sshd_config /etc/ssh/
COPY supervisor-app.conf /etc/supervisor/conf.d/

COPY --from=build react/build /var/www/html/

EXPOSE 80 2222

COPY entry_point.sh ./
RUN ["chmod", "+x", "entry_point.sh"]
CMD [ "./entry_point.sh" ]
