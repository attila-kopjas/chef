#
# Cookbook Name:: memsql
# Recipe:: master_install
#
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

#include_recipe 's3_file'

# memsql_version = node['memsql']['version']
# memsql_ops_file_name = node['memsql']['ops-file-name']
# memsql_bin_file_name = node['memsql']['bin-file-name']

# memsql_ops_download_url = node['memsql']['ops-s3-path']
# memsql_bin_download_url = node['memsql']['bin-s3-path']

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
  #notifies :run, "execute[install-aen-prereq-packages]", :immediately
  not_if { ::File.exist?("/tmp/memsql/memsql_pkg_dl_ok") }
end


# Sample for using the s3_file resource
# s3_file "/tmp/memsql/#{node['memsql']['bin-file-name']}" do
  # remote_path node['memsql']['bin-s3-path']
  # mode '0644'
# end


 execute 'untar memsql-bin tarball' do
   cwd '/tmp/memsql'
   command "tar -xzf #{node['memsql']['bin-file-name']}"
   creates '/tmp/memsql/memsqlbin'
 end

  execute 'untar memsql-ops tarball' do
   cwd '/tmp/memsql'
   command "tar -xzf #{node['memsql']['ops-file-name']}"
   creates "/tmp/memsql/memsql-ops-#{memsql_version}"
 end

 execute 'install memsql' do
   cwd "/tmp/memsql/memsql-ops-#{memsql_version}"
   command './install.sh -n'
   creates '/usr/bin/memsql-ops'
 end


# execute 'add memsql to agent' do
  # command "memsql-ops file-add -t memsql /tmp/memsql/memsqlbin_amd64.tar.gz"
  # not_if 'memsql-ops file-list -t memsql | grep -q MEMSQL'
# end



 

