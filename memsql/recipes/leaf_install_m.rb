#
# Cookbook Name:: memsql
# Recipe:: leaf_install
#


Chef::Log.warn("******* The MASTER IP is '#{node['master_ip']}' *******")
Chef::Log.warn("******* The LEAF IP is '#{node[:ipaddress]}' *******")
#Chef::Log.warn("******* RSA ID  is '#{node['rsa_id']}' *******")


group "#{node['memsql']['srvc-grp']}"

user "#{node['memsql']['srvc-acct']}" do
  group node['memsql']['srvc-grp']
  password node['memsql']['srvc-pass']
  shell '/bin/bash'
  manage_home true
end

# directory '/tmp/memsql' do
#   owner 'root'
#   group 'root'
#   mode '0755'
#   recursive true
# end

#  template 'create leaf config file' do
#   source 'leaf_config.erb'
#   owner 'memsql'
#   group 'memsql'
#   mode '0644'
#   path "/home/memsql/memsql.cnf"
# end


file '/home/memsql/id_rsa' do
  content node['rsa_id']
  mode '0600'
  owner 'memsql'
  group 'memsql'
  sensitive true                  
end


 execute "agent deploy for leaf" do
  command lazy { <<-END }
    ssh -o StrictHostKeyChecking=no -T -i /home/memsql/id_rsa ec2-user@#{node['master_ip']} \
    sudo memsql-ops agent-deploy -h #{node[:ipaddress]} -i /home/memsql/id_rsa -u ec2-user --allow-no-sudo  &&
    touch /home/memsql/leaf_deploy.ok
  END
  not_if { ::File.exist?("/home/memsql/leaf_deploy.ok") }
 end


 # execute 'agent deploy into leaf' do
 #    command "memsql-ops agent-deploy -h #{node['leaf_ip']} -i /var/lib/memsql-ops/id_rsa -u ec2-user --allow-no-sudo"
 #    not_if 'memsql-ops agent-list | grep FOLLOWER'
 # end


 execute "deploy memsqld and start" do
  command lazy { <<-END }
    ssh -o StrictHostKeyChecking=no -T -i /home/memsql/id_rsa ec2-user@#{node['master_ip']} \
    echo | memsql-ops memsql-deploy -a $(memsql-ops agent-list | grep #{node[:ipaddress]} | awk 'NR==1 { print $1}') -r leaf  &&
    touch /home/memsql/memsqld_deploy.ok
  END
  ignore_failure true
  not_if { ::File.exist?("/home/memsql/memsqld_deploy.ok") }
 end



  # execute 'deploy memsql and start' do
  #   command "echo | memsql-ops memsql-deploy -a $(memsql-ops agent-list | grep FOLLOWER | awk 'NR==1 { print $1}') -r leaf"
  #   ignore_failure true
  #   not_if 'memsql-ops memsql-list | grep LEAF'
  # end



 # execute "change_leaf_conf" do
 #  command lazy { <<-END }
 #    ssh -o StrictHostKeyChecking=no -T -i /var/lib/memsql-ops/id_rsa ec2-user@#{node['leaf_ip']} \
 #       sudo mv /tmp/memsql/memsql.cnf  /var/lib/memsql/leaf*/memsql.cnf  &&
 #    touch /tmp/memsql/leaf_conf.ok
 #  END
 #  not_if { ::File.exist?("/tmp/memsql/leaf_conf.ok") }
 # end

 template 'change config file' do
  source 'leaf_config.erb'
  owner 'memsql'
  group 'memsql'
  mode '0644'
  #path lazy { "/var/lib/memsql/#{`ls /var/lib/memsql | grep leaf|tr -d '\n'`}/memsql.cnf" }
  path lazy { "#{Dir['/var/lib/memsql/leaf*'].first}/memsql.cnf" }
end


execute 'starts memsql' do
   command "memsql-ops memsql-start --no-prompt $(memsql-ops memsql-list | grep #{node[:ipaddress]} | awk 'NR==1 { print $1}')"
   #not_if 'memsql-ops memsql-list |grep LEAF |grep -v "NOT RUNNING"'
 end