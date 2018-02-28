#
# Cookbook Name:: memsql
# Recipe:: leaf_install
#


directory '/tmp/aen' do
  owner 'root'
  group 'root'
  mode '0755'
  recursive true
  #action :nothing
  #notifies :delete, 'directory[/tmp/aen]' # at the end of the recipe
end
