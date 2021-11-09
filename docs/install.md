# Installing in Production

It is possible to run FreeFeed on various infrastructure:
- everything on a single hardware or cloud server - this is how freefeed.net is set up right now
- application on one server, and the database on another one (e.g. EC2+RDS) - this is how we had been running FreeFeed up until ~2 years ago
- on kubernetes (theoretically, we haven’t tried it ourselves - please let us know if you have done or are planning to do it)

Here for the sake of simplicity we will cover only the first scenario.

## Necessary manual steps

### Get a server
We recommend to use Debain 11, have at least 4GB of RAM and at least 2 CPU cores. Required disk size capacity will depend on how much data users will be generating and whether you will be storing attachments on disk or S3-compatible infrastructure, but allocating at least few 10s of GB for freefeed data is probably a good idea.

Hosting providers which we can recommend:
- digitalocean.com
- hetzner.com
- aws.amazon.com

### Get a domain name
You also need to point A record of your domain to the server, examples on how to do it among some popular domain names providers:
    - [Namecheap](https://www.namecheap.com/support/knowledgebase/article.aspx/434/2237/how-do-i-set-up-host-records-for-a-domain/)
    - [Name.com](https://www.name.com/support/articles/115004893508-adding-an-a-record)
    - [Gandi.net](https://docs.gandi.net/en/domain_names/common_operations/link_domain_to_website.html)

### Setup SSH access to your server
[Tutorial](https://www.digitalocean.com/community/tutorials/how-to-set-up-ssh-keys-on-debian-11) from DigitalOcean community.

## Run some commands on the server
We assume you managed to log in to your server and your user has sudo access.

### Install necessary packages

    $ sudo apt update && sudo apt install gnupg2 git ca-certificates

### Install Ansible

    $ sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367
    $ echo 'deb http://ppa.launchpad.net/ansible/ansible/ubuntu focal main' | sudo tee /etc/apt/sources.list.d/ansible.list
    $ sudo apt update && sudo apt install ansible
    
### The rest

    $ git clone https://github.com/FreeFeed/freefeed-ansible.git
    $ cd freefeed-ansible
    $ ansible-playbook -i localhost, playbooks/docker.yml

