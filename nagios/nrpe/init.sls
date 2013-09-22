{% from "nagios/nrpe/map.jinja" import map with context %}

nrpe:
  pkg:
    - installed
    - pkgs: {{ map.pkgs|json }}
  service:
    - running
    - name: {{ map.service }}
    - enable: true
  group:
    - present
    - gid: 31
    - system: true
  user:
    - present
    - shell: /bin/false
    - home: /usr/share/nagios
    - uid: 31
    - guid: 31
    - groups:
      - nrpe

/etc/nrpe:
  file:
    - recurse
    - source: salt://nagios/nrpe/files
    - template: jinja
    - watch_in:
      - service: {{ map.service }}
    - user: nrpe
    - group: nrpe
