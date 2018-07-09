{% from "nagios/map.jinja" import nrpe with context %}

nrpe-plugin-package:
  pkg.installed:
    - name: {{ nrpe.plugin }}
    {% if grains['os_family'] == 'Debian' and nrpe.install_recommends == False %}
    - install_recommends: False
    {% endif %}

{% if 'nagios/nrpe/files/plugins' in salt['cp.list_master_dirs']() %}
{{ nrpe.plugin_dir }}:
  file.recurse:
    - source: salt://nagios/nrpe/files/plugins/
    - clean: False
    - file_mode: 0755
{% endif %}
