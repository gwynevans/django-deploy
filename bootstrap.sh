#!/bin/sh
#
# NB: by default, the project folder is shared with the vagrant VM as /vagrant
#  and this script runs as root

echo "bootstrap.sh started."

apt-get -qq update

apt-get -qq -y install python3 virtualenv

apt-get -qq -y install postgresql postgresql-contrib		# Install PostresSQL

# Create PostgresSQL user and DB
cat <<- EOF | su - postgres -c psql
	-- Create the database user:
	CREATE USER myapp_django WITH PASSWORD 'myapp_password';
	ALTER ROLE myapp_django SET client_encoding TO 'utf8';
	ALTER ROLE myapp_django SET default_transaction_isolation TO 'read committed';
	ALTER ROLE myapp_django SET timezone TO 'UTC';		
	-- Create the database:
	CREATE DATABASE myapp WITH OWNER=myapp_django;
EOF

# Create app user and group
groupadd --system webapps
useradd --system --gid webapps --shell /bin/bash --home /webapps/myapp_django myapp

# Create folder for app
mkdir -p /webapps/myapp_django/
chown myapp /webapps/myapp_django/

# Create virtualenv
sudo su - myapp <<- EOF
	cd /webapps/myapp_django/
	virtualenv . -p python3
	source bin/activate
	# Install django within the virtualenv
	pip install django
	# Testing by creating an empty project
	django-admin.py startproject myapp
	
	# TODO - Use an example with a DB, e.g. /vagrant/django-tutorial.tar
	#      - Copy django_settings.py to use PostgreSQL rather than SQLite
	
	# Install PostgreSQL/Django adapter
	pip install psycopg2
	
	# Prepare Django
	cd myapp
	python manage.py migrate
	cd ..
	
	# Install gunicorn
	pip install gunicorn

	# Copy gunicorn_start.bash to ~myapp/bin/ (i.e. /webapps/myapp_django/bin/)
	cp /vagrant/gunicorn_start.bash bin/gunicorn_start
	chmod +x bin/gunicorn_start
EOF

# Install supervisor
apt-get -qq -y install supervisor

# Create supervisor config
sudo su - myapp <<- EOF
	mkdir logs
	touch logs/gunicorn_supervisor.log
EOF

cp /vagrant/myapp.conf /etc/supervisor/conf.d/myapp.conf
supervisorctl reread
supervisorctl update

apt-get -qq -y install nginx
service nginx stop
cp /vagrant/myapp.nginx.conf /etc/nginx/sites-available/myapp
ln -s /etc/nginx/sites-available/myapp /etc/nginx/sites-enabled/
rm /etc/nginx/sites-enabled/default 
service nginx start 

echo "bootstrap.sh finished."
exit 0
