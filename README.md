# django-deploy
Exploring different deployment options

This assumes you've got `python3`, `virtualenv` & `virtualenvwrapper` installed.
They also assume that you've got `vagrant` installed, although that needn't be a fundamental requirement

## vagrant/manual

1. `cd django-deploy`
1. `mkvirtualenv Vagrant -p python3` (first time) or `workon Vagrant`
1. `pip install pip --upgrade`
1. `vagrant up`
1. `vagrant ssh`

### Actions within the VM
NB: by default, the project folder is shared with the vagrant VM as /vagrant

```
sudo apt update
sudo apt install python3 virtualenv
sudo apt install postgresql postgresql-contrib		# Install PostresSQL
```

Create PostgresSQL user and DB
```
sudo su - postgres
postgres@minimal-xenial:~$ createuser --interactive -P
Enter name of role to add: myapp_django
Enter password for new role: 
Enter it again: 
Shall the new role be a superuser? (y/n) n
Shall the new role be allowed to create databases? (y/n) n
Shall the new role be allowed to create more new roles? (y/n) n
postgres@minimal-xenial:~$ createdb --owner myapp_django myapp
postgres@minimal-xenial:~$ logout
```

Create app user and group
```
sudo groupadd --system webapps
sudo useradd --system --gid webapps --shell /bin/bash --home /webapps/myapp_django myapp
```

Create folder for app
```
sudo mkdir -p /webapps/myapp_django/
sudo chown myapp /webapps/myapp_django/
```

Create virtualenv
```
sudo su - myapp
myapp@django:~$ cd /webapps/myapp_django/
myapp@django:~$ virtualenv . -p python3
...
myapp@django:~$ source bin/activate
(myapp_django)myapp@django:~$ 
```

Install django within the virtualenv
```
pip install django
```

Testing by creating an empty project and running the devserver
```
django-admin.py startproject myapp
cd myapp 
python manage.py runserver 0:8000
```
Browse to http://192.168.33.10:8000/ from the host

Install PostgreSQL/Django adapter
```
pip install psycopg2
```

Edit the myapp/settings.py to add a DB section
```
DATABASES = {
    'default': {
        # 'ENGINE': 'django.db.backends.sqlite3',
        # 'NAME': os.path.join(BASE_DIR, 'db.sqlite3'),
        'ENGINE': 'django.db.backends.postgresql_psycopg2',
        'NAME': 'myapp',
        'USER': 'myapp_django
        'PASSWORD': 'password',
        'HOST': 'localhost',             
        'PORT': '',                      # Set to empty string for default.
    }
}
```
python manage.py migrate

Install gunicorn
```
pip install gunicorn
```

Test gunicorn
```
cd myapp
gunicorn myapp.wsgi:application --bind 192.168.33.10:8001
```
Browse to http://192.168.33.10:8001/ from the host

Copy `gunicorn_start.bash` to ~myapp/bin/ (i.e. /webapps/myapp_django/bin/)
```
chmod +x bin/gunicorn_start.bash
```

Install supervisor
```
sudo apt install supervisor
```

Create config
```
mkdir /etc