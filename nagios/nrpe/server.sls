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

/etc/nagios/nrpe.cfg:
   file:
    - managed
    - source: salt://nagios/nrpe/files/nrpe.cfg.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - watch_in:
      - service: nrpe-server-service

{% if grains['os_family'] == 'Arch' %}
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

extend:
  /etc/nagios/nrpe.cfg:
    file:
      - user: nrpe
      - group: nrpe
      - require:
        - user: nrpe-user
        - group: nrpe-group
{% endif %}
