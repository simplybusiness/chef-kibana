default['kibana']['apache']['template'] = 'kibana-apache.conf.erb'
default['kibana']['apache']['template_cookbook'] = 'kibana'
default['kibana']['apache']['enable_default_site'] = false
default['kibana']['ssl_certificate'] = '/etc/ssl/certs/ssl-cert-snakeoil.pem'
default['kibana']['ssl_key'] = '/etc/ssl/private/ssl-cert-snakeoil.key'
