#
# Cookbook Name:: memsql
# Recipe:: template_install
#


#include_recipe 's3_file'


group "#{node['memsql']['srvc-grp']}"

user "#{node['memsql']['srvc-acct']}" do
  group node['memsql']['srvc-grp']
  password node['memsql']['srvc-pass']
  shell '/bin/bash'
  manage_home true
end

#sudo opsworks-agent-cli get_json -i
#Chef::Log.info("*** The leaf IP is '#{node['leaf_ip']}' ***")

#Chef::Log.warn("******* The master IP is '#{node['leaf_ip']}' *******")
#Chef::Log.info("******* Info The master IP is '#{node['leaf_ip']}' *******")
#Chef::Log.warn("******* RSA ID is '#{node['rsa_id']}' *******")

directory '/tmp/memsql' do
  owner 'root'
  group 'root'
  mode '0755'
  recursive true
  #action :nothing
end


execute 'download-memsql-packages' do
  cwd '/tmp/memsql'
  user "root"
  action :run
  command "aws s3 cp #{node['memsql']['ops-s3-path']} . && \
    aws s3 cp #{node['memsql']['bin-s3-path']} . && \
    chmod '0644' #{node['memsql']['ops-file-name']} #{node['memsql']['bin-file-name']} && \
    touch /tmp/memsql/memsql_pkg_dl_ok"
  #notifies :run, "execute[install-prereq-packages]", :immediately
  not_if { ::File.exist?("/tmp/memsql/memsql_pkg_dl_ok") }
end

# Sample for using the s3_file resource
# s3_file "/tmp/memsql/#{node['memsql']['bin-file-name']}" do
  # remote_path node['memsql']['bin-s3-path']
  # mode '0644'
  # #action :nothing
# end


 execute 'untar memsql-ops tarball' do
   cwd '/tmp/memsql'
   command "tar -xzf #{node['memsql']['ops-file-name']}"
   creates "/tmp/memsql/memsql-ops-#{node['memsql']['version']}"
 end

 file '/home/memsql/id_rsa' do
  content node['rsa_id']
  mode '0600'
  owner 'memsql'
  group 'memsql'
  sensitive true                  
end