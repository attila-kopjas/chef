#
# Cookbook Name:: memsql
# Recipe:: leaf_install
#


Chef::Log.warn("******* The master IP is '#{node['master_ip']}' *******")
#Chef::Log.info("******* Info The master IP is '#{node['master_ip']}' *******")
#Chef::Log.warn("******* RSA ID  is '#{node['rsa_id']}' *******")


group "#{node['memsql']['srvc-grp']}"

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
end

 template 'create leaf config file' do
  source 'leaf_config.erb'
  owner 'memsql'
  group 'memsql'
  mode '0644'
  path "/tmp/memsql/memsql.cnf"
end