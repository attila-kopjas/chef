#
# Cookbook Name:: mesos
# Recipe:: master
#
# Copyright 2016, Jonathan Klinginsmith
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

mesos_master_hostname = node['mesos']['master_hostname']
mesos_repo_rpm_download_url = node['mesos']['repo_rpm_download_url']
mesos_repo_rpm_path = node['mesos']['repo_rpm_path']
mesos_zookeeper_id = node['mesos']['zookeeper_id']
mesos_cluster_name = node['mesos']['cluster_name']
mesos_zookeeper_client_port = node['mesos']['zookeeper_client_port']

remote_file mesos_repo_rpm_path do
  source mesos_repo_rpm_download_url
end

package "#{File.basename(mesos_repo_rpm_path, '.rpm')}" do
  action :install
  source mesos_repo_rpm_path
  provider Chef::Provider::Package::Rpm
end

mesos_packages = %w(mesos marathon mesosphere-zookeeper)
mesos_packages.each do |mesos_package|
  package mesos_package do
    action :install
  end
end

template '/etc/mesos-master/hostname' do
  source 'etc_mesos-master_hostname.erb'
  mode '0644'
  variables(
    mesos_master_hostname: mesos_master_hostname
  )
end

# Populate the Zookeeper myid file with a unique id (e.g., 1..n)
template '/var/lib/zookeeper/myid' do
  source 'zookeeper_myid.erb'
  mode '0644'
  variables(
    mesos_zookeeper_id: mesos_zookeeper_id
  )
end

# Search for all of the Mesos masters and sort by Zookeeper id (1..n) to populate the zoo.cfg file.
mesos_masters = search(:node, "mesos_roles:master AND mesos_cluster_name:#{mesos_cluster_name}")
mesos_masters_sorted = mesos_masters.sort_by { |x| x['mesos']['zookeeper_id'].to_i }

template '/etc/zookeeper/conf/zoo.cfg' do
  source 'zoo.cfg.erb'
  mode '0644'
  variables(
    mesos_masters: mesos_masters_sorted,
    mesos_zookeeper_client_port: mesos_zookeeper_client_port
  )
end

template '/etc/mesos/zk' do
  source 'etc_mesos_zk.erb'
  mode '0644'
  variables(
    mesos_masters: mesos_masters_sorted,
    mesos_zookeeper_client_port: mesos_zookeeper_client_port
  )
end

template '/etc/mesos-master/quorum' do
  source 'etc_mesos-master_quorum.erb'
  mode '0644'
  variables(
    mesos_quorum: "#{(mesos_masters.count / 2) + 1}"
  )
end

service 'mesos-slave' do
  action [:disable, :stop]
end

# service "mesos-master" do
#   action [ :enable ]
# end

# sudo systemctl restart mesos-master.service
# sudo systemctl restart marathon
