name 'memsql'
maintainer 'Jonathan Klinginsmith'
maintainer_email 'jklingin@indiana.edu'
license 'Apache 2.0'
description 'Installs/Configures MemSQL'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.1.0'
chef_version '>= 12.1' if respond_to?(:chef_version)
depends 's3_file', '~> 2.8.5'
