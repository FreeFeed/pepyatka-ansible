# Deploying FreeFeed

Requirements:

- ansible
- debian
- docker

stable/candy:

    ansible-playbook -vv -i stable playbooks/server.yml
    ansible-playbook -vv -i stable playbooks/frontend.yml

release/production:

    ansible-playbook -vv -i release playbooks/server.yml -e freefeed_server_version='freefeed_release_X.YY.Z'
    ansible-playbook -vv -i release playbooks/frontend.yml -e react_client_version='freefeed_release_X.YY.Z'

## Secrets management

Secrets are managed via `ansible-vault`. Our secrets file `group_vars/release_secrets.yml` looks like this:

```
freefeed_mailer_smtp_host: smtp.host.com
freefeed_mailer_smtp_port: 587
freefeed_mailer_smtp_user: user@host.com
freefeed_mailer_smtp_pass: password
freefeed_secret: secret
slack_token: token
recaptcha_server_secret: recaptcha_secret
sentry_dsn: 'https://hexstr:hexstr@sentry.io/somenumber'
new_relic_license_key: key

postgres_pass: password

aws_access_key: AAABBBCCC
aws_secret_key: secret

freefeed_external_auth_google_client_id: clientid.apps.googleusercontent.com
freefeed_external_auth_google_client_secret: secret
freefeed_external_auth_facebook_client_id: clientid
freefeed_external_auth_facebook_client_secret: secret

company_title: 'FreeFeed MTÜ'
company_address: 'Muti 30-25, 13424 Tallinn, Estonia'

healthchecks_io:
  'count-daily-stats': 'deadbeef'
  'db_maintenance': 'deadbeef'
  'notification_emails': 'deadbeef'
  'bestof_emails': 'deadbeef'
  'freefeed-db-backup': 'deadbeef'
  'tg-client-backup': 'deadbeef'
  'tg-client': 'deadbeef'

loggly_token: '12345678-1234-1234-1234-123456789012'
```

Vault uses password stored in a file configured in `ansible.cfg` via `vault_password_file` variable. Password is stored in clear text.

To create another file with secrets create a `.yml` file similar to ours, encrypt it with `ansible-vault encrypt <file>` and commit.

To edit existing file with secrets use `ansible-vault edit <file>` command, and to simply view the decrypted content use `ansible-vault view <file>`.

For more information: `ansible-vault --help`.

## Local test

If you want to test changes in config templates locally,

1. install ansible
1. `cp freefeed local`, replace `freefeed.net` with `localhost` and `release_secrets` with `local_secrets`
1. `cp host_vars/freefeed.net host_vars/localhost`
1. create a vault password file with a password (e.g. `echo 123 >> local.vault`), edit `vault_password_file` in `ansible.cfg` to point to it
1. create a `group_vars/local_secrets` file with fake secrets (see contents above), encrypt it with `ansible-vault encrypt`
1. `ansible-playbook -i local playbooks/server.yml --diff --tags local-json --connection local -e freefeed_config_dir=$OUTPUT_DIR -K` (you might need to run it with sudo first)
