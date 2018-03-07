default['memsql']['base-s3-path'] = 's3://memsql-training'

default['memsql']['ssh-priv-key-path'] = '/var/lib/memsql-ops/id_rsa'
default['memsql']['ssh-user'] = 'ec2-user'

default['memsql']['srvc-grp'] = 'memsql'
default['memsql']['srvc-acct'] = 'memsql'
default['memsql']['srvc-pass'] = '123456'

default['memsql']['version'] = '6.0.7'
default['memsql']['ops-file-name'] = "memsql-ops-#{default['memsql']['version']}.tar.gz"
default['memsql']['ops-s3-path'] = "#{default['memsql']['base-s3-path']}/#{default['memsql']['ops-file-name']}"

default['memsql']['bin-file-name'] = "memsqlbin_amd64.tar.gz"
default['memsql']['bin-s3-path'] = "#{default['memsql']['base-s3-path']}/#{default['memsql']['bin-file-name']}"