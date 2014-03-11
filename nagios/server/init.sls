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
    - name: {{ map.group }}
    - system: true
  user:
    - present
    - name: {{ map.user }}
    - shell: /bin/false
    - home: {{ map.home }}
    - groups:
      - {{ map.group }}

{% if grains['os'] == 'Arch' %}
extend:
  nagios:
    group:
      - gid: {{ map.gid }}
    user:
      - uid: {{ map.uid }}
      - guid: {{ map.guid }}

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
      - service: {{ map.service }}
    - user: nagios
    - group: nagios
{% endif %}
