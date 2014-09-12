#
# Cookbook Name:: kibana
# Recipe:: default
#
# Copyright 2013, John E. Vincent
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

include_recipe "git"

es_role = node[:opsworks][:layers][node['kibana']['es_role']]

unless es_role == "elasticsearch_elb"?  
  es_instances = node[:opsworks][:layers][node['kibana']['es_role']][:instances]
  es_hosts = es_instances.map{ |name, attrs| attrs['private_ip'] }

  unless es_hosts.empty?
    node.set['kibana']['es_server'] = es_hosts.first
  end
end

if node['kibana']['user'].empty?
  unless node['kibana']['webserver'].empty?
    webserver = node['kibana']['webserver']
    kibana_user = node[webserver]['user']
  else
    kibana_user = "nobody"
  end
else
  kibana_user = node['kibana']['user']
end

directory node['kibana']['installdir'] do
  owner kibana_user
  mode "0755"
end

git "#{node['kibana']['installdir']}/#{node['kibana']['branch']}" do
  repository node['kibana']['repo']
  reference node['kibana']['branch']
  if node['kibana']['git']['checkout']
    action :checkout
  else
    action :sync
  end
  user kibana_user
end

link "#{node['kibana']['installdir']}/current" do
  to "#{node['kibana']['installdir']}/#{node['kibana']['branch']}/src"
end

template "#{node['kibana']['installdir']}/current/config.js" do
  source node['kibana']['config_template']
  cookbook node['kibana']['config_cookbook']
  mode "0750"
  user kibana_user
end

link "#{node['kibana']['installdir']}/current/app/dashboards/default.json" do
  to "logstash.json"
  only_if { !File::symlink?("#{node['kibana']['installdir']}/current/app/dashboards/default.json") }
end

unless node['kibana']['webserver'].empty?
  include_recipe "kibana::#{node['kibana']['webserver']}"
end
