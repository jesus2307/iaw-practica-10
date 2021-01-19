!/bin/bash

##############
###VARIABLES##
##############
CLAVE_MYSQL=root
ROOT_MYSQL=root
DB_NAME=wordpress_data
DB_USER=wordpress_user
DB_PASSWORD=wordpress_password
IP_PRIVADA=localhost

# Variables de sitio Wordpress
WP_URL=54.174.234.141
WP-ADMIN=jesus
WP_ADMIN_PASS=jesus
WP_NAME=jesus
WP_ADMIN_EMAIL=jesus@gmail.com

# Activar la depuración del script
set -x
# Actualizamos
apt update
apt upgrade

# Creamos la base de datos
mysql -u $ROOT_MYSQL -p$CLAVE_MYSQL <<< "DROP DATABASE IF EXISTS $DB_NAME;"
mysql -u $ROOT_MYSQL -p$CLAVE_MYSQL <<< "CREATE DATABASE $DB_NAME;"

# Creamos el usuario 
mysql -u $ROOT_MYSQL -p$CLAVE_MYSQL <<< "DROP USER '$DB_USER'@'$IP_PRIVADA';"
mysql -u $ROOT_MYSQL -p$CLAVE_MYSQL <<< "CREATE USER '$DB_USER'@'$IP_PRIVADA' IDENTIFIED WITH caching_sha2_password BY '$DB_PASSWORD';"
mysql -u $ROOT_MYSQL -p$CLAVE_MYSQL <<< "GRANT ALL ON $DB_NAME.* TO '$DB_USER'@'$IP_PRIVADA';"
mysql -u $ROOT_MYSQL -p$CLAVE_MYSQL <<< "FLUSH PRIVILEGES;"


# Descargar archivo wp-cli.phar
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar

# Asignar permiso de ejecución
chmod +x wp-cli.phar

# Mover el archivo al directorio y cambiar su nombre (así se puede usar sin tener que utilizar una ruta absoluta)
mv wp-cli.phar /usr/local/bin/wp


# Ir al directorio de descarga para Wordpress
cd /var/www/html

# Eliminamos index.html
rm -rf index.html

# Descargar código de Wordpress (en español) con el flag --allow-root para que permita descargarlo
wp core download --locale=es_ES --allow-root

# Le damos permiso a la carpeta de wordpress
chown -R www-data:www-data /var/www/html

# Crear archivo de configuración
wp config create --dbname=$DB_NAME --dbuser=$DB_USER --dbpass=$DB_PASSWORD --allow-root

# Crear sitio Wordpress
wp core install --url=$WP_URL --title="$WP_NAME" --admin_user=$WP_ADMIN --admin_password=$WP_ADMIN_PASS --admin_email=$WP_ADMIN_EMAIL --allow-root

# Descargar plugins de wordpress
wget https://downloads.wordpress.org/plugin/rocket-lazy-load.2.3.4.zip
wp plugin install rocket-lazy-load.2.3.4.zip --allow-root --activate --force --path=/var/www/html/
wget https://downloads.wordpress.org/plugin/wp-super-cache.1.7.1.zip
wp plugin install wp-super-cache.1.7.1.zip --allow-root --activate --force --path=/var/www/html/
wget https://downloads.wordpress.org/plugin/social-icons-widget-by-wpzoom.zip
wp plugin install social-icons-widget-by-wpzoom.zip --allow-root --activate --force --path=/var/www/html/
wget https://downloads.wordpress.org/plugin/image-widget.4.4.7.zip
wp plugin install image-widget.4.4.7.zip --allow-root --activate --force --path=/var/www/html/

# Actualizar plugins
#wp plugin update --all --allow-root

# Actualizar themes
#wp theme update --all --allow-root

# Actualizar core de wordpress
#wp core update --allow-root