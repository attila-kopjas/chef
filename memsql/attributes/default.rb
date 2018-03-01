default['memsql']['base-s3-path'] = 'https://s3.eu-central-1.amazonaws.com/memsql-training'

default['memsql']['version'] = '6.0.7'
default['memsql']['ops-file-name'] = "memsql-ops-#{default['memsql']['version']}.tar.gz"
default['memsql']['ops-s3-path'] = "#{default['memsql']['base-s3-path']}/#{default['memsql']['ops-file-name']}"

default['memsql']['bin-file-name'] = "memsqlbin_amd64.tar.gz"
default['memsql']['bin-s3-path'] = "#{default['memsql']['base-s3-path']}/#{default['memsql']['bin-file-name']}"


# default['memsql']['version'] = '6.0.7'
# default['memsql']['download_url'] = "http://download.memsql.com/memsql-ops-#{node['memsql']['version']}/memsql-ops-#{node['memsql']['version']}.tar.gz"
# default['memsql']['download_dir'] = Chef::Config[:file_cache_path]
# default['memsql']['checksum'] = 'f6bdf8451ce4d8cd79a555accbcbbef09eb828e0c4c12d1c632442a82739466f'
# default['memsql']['bin_download_url'] = 'http://download.memsql.com/releases/latest/memsqlbin_amd64.tar.gz'
# default['memsql']['bin_checksum'] = 'c900e586c3f8f3fe52a59a9872a70e0b03d98df3ed7cc9a87229947b7a3e4ab0'

 	