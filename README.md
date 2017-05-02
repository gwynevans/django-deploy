# django-deploy
Exploring different deployment options

This assumes you've got `python3`, `virtualenv` & `virtualenvwrapper` installed.
This variant also assumes that you've got `vagrant` and `ansible` installed.

## vagrant/ansible

1. `cd django-deploy`
1. `mkvirtualenv Vagrant -p python3` (first time) or `workon Vagrant`
1. `pip install pip --upgrade`
1. `pip install ansible`
1. `vagrant up`
    - Does an implicit `vagrant provision` using Ansible and `playbook.yml`
1. Browse to http://192.168.33.10/polls/


Starting with https://github.com/jcalazan/ansible-django-stack

TODO: Take a look at https://galaxy.ansible.com/tcosta84/

## Comments
OK, a couple of things to note...

First, this is a very 'bad-practice' way of using Ansible, in that it's currently 
just a single playbook, with no deconstruction of the roles or extraction of the values, 
which are themselves hard-coded!

Second, the example app is just thrown in and I've not yet done a few important 
things, specifically I've not even had a look to see what's needed to have static
elements served by nginx and I've also neither pre-populated the DB nor configured an 
account for the django admin, so there's not much coming back from the app beyond the
"No polls are available." message!
