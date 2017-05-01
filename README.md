# django-deploy
Exploring different deployment options

This assumes you've got `python3`, `virtualenv` & `virtualenvwrapper` installed.
They also assume that you've got `vagrant` installed, although that needn't be a fundamental requirement

## vagrant/shell

1. `cd django-deploy`
1. `mkvirtualenv Vagrant -p python3` (first time) or `workon Vagrant`
1. `pip install pip --upgrade`
1. `vagrant up`
    - Does an implicit `vagrant provision` using `bootstrap.sh`
