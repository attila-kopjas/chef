default['mesos']['cluster_name'] = ''
default['mesos']['master_hostname'] = ''
default['mesos']['repo_rpm_download_url'] = 'http://repos.mesosphere.io/el/7/noarch/RPMS/mesosphere-el-repo-7-3.noarch.rpm'
default['mesos']['repo_rpm_path'] = File.join(Chef::Config[:file_cache_path], 'mesosphere-el-repo-7-3.noarch.rpm')
default['mesos']['zookeeper_id'] = ''
default['mesos']['zookeeper_ports'] = '2888:3888'
default['mesos']['zookeeper_client_port'] = '2181'
