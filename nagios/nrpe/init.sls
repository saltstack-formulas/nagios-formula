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
  nrpe:
    group:
    - gid: {{ map.gid }}
    user:
    - uid: {{ map.uid }}
    - guid: {{ map.guid }}

/etc/nrpe:
  file:
    - recurse
    - source: salt://nagios/nrpe/files
    - template: jinja
    - watch_in:
      - service: {{ map.service }}
    - user: nrpe
    - group: nrpe
{% endif %}
