{% from "nagios/map.jinja" import map with context %}

nrpe-server-package:
  pkg:
    - installed
    - name: {{ map.nrpe_server }}

nrpe-server-service:
  service:
    - running
    - name: {{ map.nrpe_service }}
    - enable: true

{% if grains['os'] == 'Arch' %}
nrpe-group:
  group:
    - present
    - name: nrpe
    - system: true
    - gid: 31

nrpe-user:
  user:
    - present
    - name: nrpe
    - shell: /bin/false
    - home: /usr/share/nagios
    - gid_from_name: true
    - system: true
    - uid: 31
    - guid: 31

/etc/nrpe:
  file:
    - recurse
    - source: salt://nagios/nrpe/files
    - template: jinja
    - watch_in:
      - service: nrpe-server-service
    - user: nrpe
    - group: nrpe
{% endif %}
