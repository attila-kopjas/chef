default['memsql']['base-s3-path'] = 's3://memsql-training'

default['memsql']['version'] = '6.0.7'
default['memsql']['ops-file-name'] = "memsql-ops-#{default['memsql']['version']}.tar.gz"
default['memsql']['ops-s3-path'] = "#{default['memsql']['base-s3-path']}/#{default['memsql']['ops-file-name']}"

default['memsql']['bin-file-name'] = "memsqlbin_amd64.tar.gz"
default['memsql']['bin-s3-path'] = "#{default['memsql']['base-s3-path']}/#{default['memsql']['bin-file-name']}"