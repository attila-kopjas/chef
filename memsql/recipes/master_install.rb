#
# Cookbook Name:: memsql
# Recipe:: master_install
#


#include_recipe 's3_file'

#sudo opsworks-agent-cli get_json -i
#Chef::Log.info("*** The leaf IP is '#{node['leaf_ip']}' ***")

group "#{node['memsql']['srvc-grp']}"

user "#{node['memsql']['srvc-acct']}" do
  group node['memsql']['srvc-grp']
  password node['memsql']['srvc-pass']
  shell '/bin/bash'
  manage_home true
end


Chef::Log.warn("******* The master IP is '#{node['leaf_ip']}' *******")
#Chef::Log.info("******* Info The master IP is '#{node['leaf_ip']}' *******")
Chef::Log.warn("******* RSA ID is '#{node['rsa_id']}' *******")

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
 
 
# LEAF config


 execute 'agent deploy into leaf' do
   command "memsql-ops agent-deploy -h #{node['leaf_ip']} -i #{node['rsa_id']} -u ec2-user --allow-no-sudo"
   #not_if 'memsql-ops memsql-list | grep LEAF'
  end
 

 execute 'add leaf agent and start' do
   command "echo | memsql-ops memsql-deploy -a $(memsql-ops agent-list | awk 'NR==2 { print $1}') -r leaf"
   ignore_failure true
   not_if 'memsql-ops memsql-list | grep LEAF'
  end

#remote!!!
 template 'change config file' do
  source 'memsql_server_config.erb'
  owner 'memsql'
  group 'memsql'
  mode '0644'
  #path lazy { "/var/lib/memsql/#{`ls /var/lib/memsql | grep leaf|tr -d '\n'`}/memsql.cnf" }
  path lazy { "#{Dir['/var/lib/memsql/*leaf*'].first}/memsql.cnf" }
  #not_if ''
end

 execute 'restarts memsql' do
   command "memsql-ops memsql-restart --all"
   not_if 'memsql-ops memsql-list |grep LEAF |grep -v "NOT RUNNING"'
 end

 
 
 