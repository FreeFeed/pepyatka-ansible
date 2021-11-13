#!/usr/bin/env sh

set -euo pipefail

read -p 'Site name [default: FreeFeed]: ' site_name
site_name=${site_name:-FreeFeed}
read -p 'Site URL (without http://, https:// and www.): ' site_url
if test -z $site_url; then { echo "Can't continue without Site URL"; exit 1; }; fi
read -s -p 'Site secret (like, really strong password): ' site_secret
echo
read -p 'Company title [default: FreeFeed]: ' company_title
company_title=${company_title:-'Company Ltd.'}
read -p 'Company address [default: Tallinn, Estonia]: ' company_address
company_address=${company_address:-'Tallinn, Estonia'}
read -p 'SMTP server host: ' smtp_host
read -p 'SMTP server port: ' smtp_port
read -p 'SMTP server uses tls? [default: false]: ' smtp_use_tls
smtp_use_tls=${smtp_use_tls:-'False'}
read -p 'SMTP server user: ' smtp_user
read -s -p 'SMTP server password: ' smtp_pass
echo
read -p "From name in emails [default: ${site_name}]: " mailer_from_name
mailer_from_name=${mailer_from_name:-site_name}
read -p "From email address: " mailer_from_email

rm -f freefeed beta candy m.freefeed nanopeppa
rm -f host_vars/* group_vars/*
echo 'Cleaned up inventories and variables'

cat > freefeed <<EOF
[target]
${site_url}

[redis:children]
target

[server:children]
target

[frontend:children]
target

[nginx:children]
target

[release:children]
target

[release_secrets:children]
target
EOF

cat > group_vars/all.yml <<EOF
company_title: ${company_title}
company_address: ${company_address}
freefeed_site_title: ${site_name}
freefeed_hostname: ${site_url}
freefeed_media_hostname: ${site_url}
freefeed_site: $(echo ${site_url} | tr . _)
freefeed_mailer_smtp_host: ${smtp_host}
freefeed_mailer_smtp_port: ${smtp_port}
freefeed_mailer_smtp_user: ${smtp_user}
freefeed_mailer_smtp_pass: ${smtp_pass}
freefeed_mailer_use_tls: ${smtp_use_tls}
freefeed_mailer_from_name: ${mailer_from_name}
freefeed_mailer_from_email: ${mailer_from_email}
freefeed_mailer_reset_password_subject: "{{ freefeed_site_title }} password reset"
freefeed_secret: ${site_secret}
freefeed_client_port: 8080
freefeed_env: release
freefeed_server_instances: "{{ ansible_processor_vcpus }}"
freefeed_storage_type: fs
freefeed_files_root_dir: /var/freefeed-files
freefeed_base_port: 3000
freefeed_jobs_enabled: true
nginx_ssl_cert: /etc/letsencrypt/live/${site_url}/fullchain.pem
nginx_ssl_key: /etc/letsencrypt/live/${site_url}/privkey.pem
nginx_ssl_cert_chain: /etc/letsencrypt/live/${site_url}/chain.pem
nginx_let_robots_index_root: true
auth_cookie_domain: ${site_url}
auth_token_prefix: "{{ freefeed_site }}"
# gateway on freefeed docker network
postgres_host: 172.18.0.1
postgres_port: 5432
postgres_user: freefeed
postgres_pass: freefeed
postgres_dbname: freefeed
redis_host: "redis-{{ freefeed_env }}"
local_storage_whoami_cache_key: whoamiCache
recaptcha_enabled: false
ansible_python_interpreter: /usr/bin/python3
EOF

echo "Created group_vars/all.yml"

cat > ./ansible.cfg <<EOF
[defaults]
roles_path = roles
EOF

echo "Overwrote ./ansible.cfg"

