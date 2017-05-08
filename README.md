# django-deploy
Exploring different deployment options

This assumes you've got `python3`, `virtualenv` & `virtualenvwrapper` installed.
This variant also assumes that you've got `vagrant` and `ansible` installed.

## vagrant/aws
As vagrant/asnible, i.e. deploys Django (on Python 3), Nginx, GUnicorn, Supervisor & PostgreSQL via Ansible, expext this time it does it to an AWS VM rather than a local one.

Usage:
* vagrant plugin install vagrant-aws
* vagrant up --provider=aws

### Vagrant using AWS step-by-step

Install the (Vagrant AWS plugin)[https://github.com/mitchellh/vagrant-aws], add a 'dummy' box and configure it with the AWS details (which should probably be set in your ~/.profile and
be passed in the environment):
```
vagrant plugin install vagrant-aws
vagrant box add dummy https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box
```

Configure Vagrantfile with 
```
  config.vm.provider :aws do |aws, override|
    aws.access_key_id = ENV['AWS_KEY']
    aws.secret_access_key = ENV['AWS_SECRET']
    aws.keypair_name = ENV['AWS_KEYNAME']
    aws.ami = "ami-fa68fbec"
    aws.region = "us-east-1"
    aws.instance_type = "t2.micro"
    aws.security_groups = ["ssh-in"]

    override.vm.box = "dummy"
    override.ssh.username = "ubuntu"
    override.ssh.private_key_path = ENV['AWS_KEYPATH']
  end
```
NB: The ami value is the current "us-east-1 / Ubuntu 16.04 / t2.micro" id value.
The security group in the "group name" (as opposed to the name) of a security-group
defined with a rule to allow SSH in from my personal IP.

If the Ansible provisioning fails with an SSH 'host_unreachable' error, set 
  ansible.verbose = "vvvv" 
in the Vagrantfile provisioning section to confirm, but the chances are that the SSH ControlPath value is too long - try changing it via 
    [ssh_connection]
    control_path = "/tmp/ansible-ssh-%%h-%%p-%%r"
or similar in an ansible.cfg file.

If you get errors in the asnible phase, such as "in heuristic_log_sanitize\r\nTypeError: a bytes-like object is required, not 'str'", then it's probably down to running ansible under a python3 environment on the local system.  (My fix was to re-do my local VEnv to be a python2 one, after which it worked as expected.)

Don't forget to open up your AWS security group to allow HTTP access once provisioned.

### Refs
* https://oliverveits.wordpress.com/2016/04/01/aws-automation-using-vagrant-a-hello-world-example/
* https://github.com/mitchellh/vagrant-aws


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
