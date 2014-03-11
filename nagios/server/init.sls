{% from "nagios/map.jinja" import map with context %}

nagios-server-package:
  pkg:
    - installed
    - name: {{ map.nagios_server_pkg }}

nagios-service:
  service:
    - running
    - name: {{ map.nagios_service }}
    - enable: true

{% if grains['os'] == 'Arch' %}
nagios-group:
  group:
    - present
    - name: nagios
    - gid: 30
    - system: true

nagios-user:
  user:
    - present
    - name: nagios
    - shell: /bin/false
    - home: /dev/null
    - gid: 30
    - guid: 30
    - gid_from_name: true
    - system: true

/usr/share/nagios:
  file.directory:
    - user: nagios
    - group: nagios
    - mode: 755
    - recurse:
      - user
      - group
      - mode

/var/nagios/nagios.log:
  file.managed:
    - user: root
    - group: nagios
    - mode: 660

/etc/nagios:
  file:
    - recurse
    - source: salt://nagios/server/files
    - template: jinja
    - watch_in:
      - service: nagios-service
    - user: nagios
    - group: nagios
{% endif %}
