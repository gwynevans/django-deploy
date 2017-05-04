# django-deploy
Exploring different deployment options

This assumes you've got `python3`, `virtualenv` & `virtualenvwrapper` installed.
This variant also assumes that you've got `vagrant` and `ansible` installed.

## vagrant/ansible

Deploys Django (on Python 3), Nginx, GUnicorn, Supervisor & PostgreSQL via Ansible

1. `cd django-deploy`
1. `mkvirtualenv Vagrant -p python3` (first time) or `workon Vagrant`
1. `pip install pip --upgrade`
1. `pip install ansible`
1. `vagrant up`
    - Does an implicit `vagrant provision` using Ansible and `playbook.yml`
        - Which in turn installs an example django app from
          [here](https://github.com/gwynevans/django-example), although it 
          does overwrite the settings.py with one in this repo as the example's
          using Debug & sqlite
1. Browse to http://192.168.33.10/


Starting with https://github.com/jcalazan/ansible-django-stack

TODO: Take a look at https://galaxy.ansible.com/tcosta84/

## Comments
OK, a couple of things to note...

First, this is a very 'bad-practice' way of using Ansible, in that it's currently 
just a single playbook, with no deconstruction of the roles or extraction of the values, 
which are themselves mostly hard-coded!

Second, I don't configure an account for the django admin, so you'll have to do that manually
if you want to use the admin pages.
