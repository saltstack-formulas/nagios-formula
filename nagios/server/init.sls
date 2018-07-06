{% from "nagios/map.jinja" import nagios with context %}
{% set service_function = {'enabled':'running', 'dead':'dead', 'disabled':'disabled'}.get(nagios.service_status) %}
{% set service_enabled  = {'enabled':True, 'dead':False, 'disabled':False}.get(nagios.service_status) %}

nagios-server-package:
  pkg.installed:
    - name: {{ nagios.server }}

nagios-service:
  service.{{ service_function }}:
    - name: {{ nagios.service }}
    - enable: {{ service_enabled }}

nagios-server-config:
  file.managed:
    - name: {{ nagios.conf }}
    - source: salt://nagios/server/files/nagios.cfg
    - template: jinja
    - watch_in:
      - service: {{ nagios.service }}

nagios-cgi-config:
  file.managed:
    - name: {{ nagios.cgi_conf }}
    - source: salt://nagios/server/files/cgi.cfg
    - template: jinja

nagios-resource-config:
  file.managed:
    - name: {{ nagios.resource_file }}
    - source: salt://nagios/server/files/resource.cfg
    - template: jinja
    - watch_in:
      - service: {{ nagios.service }}

{% if grains['os_family'] == 'Arch' %}
nagios-group:
  group.present:
    - name: nagios
    - system: true
    - gid: 31

nagios-user:
  user.present:
    - name: nagios
    - shell: /bin/false
    - home: /usr/share/nagios
    - gid_from_name: true
    - system: true
    - uid: 31
    - guid: 31

nagios-server-log:
  file.managed:
    - name: {{ nagios.log }}
    - user: root
    - group: nagios
    - mode: 660
    - makedirs: True
    - require:
      - group: nagios-group

extend:
  nagios-server-config:
    - file:
      - user: nagios
      - group: nagios
  nagios-cgi-config:
    - file:
      - user: nagios
      - group: nagios
  nagios-resource-config:
    - file:
      - user: nagios
      - group: nagios
{% endif %}
