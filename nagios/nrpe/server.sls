{% from "nagios/map.jinja" import nrpe with context %}

nrpe-server-package:
  pkg.installed:
    - name: {{ nrpe.server }}

nrpe-server-service:
  service.running:
    - name: {{ nrpe.service }}
    - enable: true

nrpe-server-config:
   file.managed:
    - name: {{ nrpe.conf }}
    - source: salt://nagios/nrpe/files/nrpe.cfg.jinja
    - template: jinja
    - user: root
    - group: {{ nrpe.root_group }}
    - mode: 644
    - require:
      - pkg: nrpe-server-package
    - watch_in:
      - service: {{ nrpe.service }}

nrpe-cfg_dir:
  file.directory:
    - name: {{ nrpe.cfg_dir }}
    - user: root
    - group: {{ nrpe.root_group }}
    - require:
      - pkg: {{ nrpe.server }}

{% if grains['os_family'] == 'RedHat' %}
{# create link on Redhat to be more close to debian and other distributions #}
nagios_plugins_sym:
  file.symlink:
    - name: /usr/lib/nagios
    - target: /usr/lib64/nagios
{% endif %}

{% if grains['os_family'] == 'Arch' %}
nrpe-group:
  group.present:
    - name: nrpe
    - system: true
    - gid: 31

nrpe-user:
  user.present:
    - name: nrpe
    - shell: /bin/false
    - home: /usr/share/nagios
    - gid_from_name: true
    - system: true
    - uid: 31
    - guid: 31

extend:
  nrpe-server-config:
    file:
      - user: nrpe
      - group: nrpe
      - require:
        - user: nrpe-user
        - group: nrpe-group
{% endif %}
