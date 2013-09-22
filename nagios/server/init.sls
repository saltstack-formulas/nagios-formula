{% from "nagios/server/map.jinja" import map with context %}

nagios:
  pkg:
    - installed
    - pkgs: {{ map.pkgs|json }}
  service:
    - running
    - name: {{ map.service }}
    - enable: true
  group:
    - present
    - gid: 30
    - system: true
  file.directory:
    - name: /usr/share/nagios
    - user: nagios
    - group: nagios
    - mode: 755
    - recurse:
      - user
      - group
      - mode
  user:
    - present
    - shell: /bin/false
    - home: /usr/share/nagios 
    - uid: 30
    - guid: 30
    - groups:
      - nagios

/etc/nagios:
  file:
    - recurse
    - source: salt://nagios/server/files
    - template: jinja
    - watch_in:
      - service: {{ map.service }}
    - user: nagios
    - group: nagios

/var/nagios/nagios.log:
  file.managed:
    - user: root
    - group: nagios
    - mode: 660

