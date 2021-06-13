#!/bin/bash

#substitute settings in conf file since nginx does not expand environment variables by itself.
# echo "Adding BACKEND_API_URL: ${BACKEND_API_URL} to nginx.conf"
# sed -i 's@${BACKEND_API_URL}@'"${BACKEND_API_URL}"'@' /etc/nginx/nginx.conf

#substitute settings in 'yarn build'-generated files with values from environment
grep -lr REACT_APP_CLIENT_ID_PLACEHOLDER /var/www/html > list.txt
while read p; do
 echo "substituting yarn build strings REACT_APP_CLIENT_ID_PLACEHOLDER with ''${REACT_APP_CLIENT_ID}' and REACT_APP_TENANT_PLACEHOLDER to ${REACT_APP_TENANT} into $p"
 sed 's@REACT_APP_CLIENT_ID_PLACEHOLDER@'"${REACT_APP_CLIENT_ID}"'@g' -i $p
 sed 's@REACT_APP_TENANT_PLACEHOLDER@'"${REACT_APP_TENANT}"'@g' -i $p
done < list.txt

#substitute settings in 'yarn build'-generated files with values from environment
grep -lr PUBLIC_URL_PLACEHOLDER /var/www/html > list.txt
while read p; do
echo "substituting yarn build string PUBLIC_URL_PLACEHOLDER with '${PUBLIC_URL}' into $p"
 # The order of these statements is important
 sed 's@'"/PUBLIC_URL_PLACEHOLDER"'@'"${PUBLIC_URL}"'@g' -i $p
 sed 's@PUBLIC_URL_PLACEHOLDER@'"${PUBLIC_URL}"'@g' -i $p
done < list.txt

supervisord -n
