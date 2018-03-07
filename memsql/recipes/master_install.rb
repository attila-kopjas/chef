#
# Cookbook Name:: memsql
# Recipe:: master_install
#


#include_recipe 's3_file'

#sudo opsworks-agent-cli get_json -i
#Chef::Log.info("*** The leaf IP is '#{node['leaf_ip']}' ***")


user "#{node['memsql']['srvc-acct']}" do
  group node['memsql']['srvc-grp']
  password node['memsql']['srvc-pass']
  shell '/bin/bash'
  manage_home true
end


directory '/tmp/memsql' do
  owner 'root'
  group 'root'
  mode '0755'
  recursive true
  #action :nothing
end


group "#{node['memsql']['srvc-grp']}"

user "#{node['memsql']['srvc-acct']}" do
  group node['memsql']['srvc-grp']
  password node['memsql']['srvc-pass']
  shell '/bin/bash'
  manage_home true
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


execute 'install memsql' do
   cwd "/tmp/memsql/memsql-ops-#{node['memsql']['version']}"
   command './install.sh --ignore-min-requirements -n'
   creates '/usr/bin/memsql-ops'
 end


 execute 'add memsql to agent' do
   command "memsql-ops file-add -t memsql /tmp/memsql/memsqlbin_amd64.tar.gz"
   not_if 'memsql-ops file-list -t memsql | grep -q MEMSQL'
 end


 execute 'add master agent and start' do
   command "echo | memsql-ops memsql-deploy -a $(memsql-ops agent-list | awk 'NR==2 { print $1}') -r master"
   ignore_failure true
   not_if 'memsql-ops memsql-list | grep MASTER'
  end


 template 'change config file' do
  source 'memsql_server_config.erb'
  owner 'memsql'
  group 'memsql'
  mode '0644'
  #path lazy { "/var/lib/memsql/#{`ls /var/lib/memsql | grep master|tr -d '\n'`}/memsql.cnf" }
  path lazy { "#{Dir['/var/lib/memsql/*master*'].first}/memsql.cnf" }
  #not_if ''
end

 execute 'restarts memsql' do
   command "memsql-ops memsql-restart --all"
   not_if 'memsql-ops memsql-list |grep MASTER |grep -v "NOT RUNNING"'
 end

 
  
 template node['memsql']['ssh-priv-key-path'] do
  source 'id_rsa.erb'
  rsa_key = data_bag_item('anaconda_gecloud_privkey', 'private_key_dev', data_bag_secret)['key']
  variables rsa_key: rsa_key
  owner node['memsql']['srvc-grp']
  group node['memsql']['srvc-grp']
  mode '0600'
  sensitive true
  #action :nothing
  #notifies :delete, "template[#{node['memsql']['memsql-ssh-priv-key-path']}]" # at the end of the recipe
end
 
 