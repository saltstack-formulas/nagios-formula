{% from "nagios/map.jinja" import map with context %}

nagios-server-package:
  pkg:
    - installed
    - name: {{ map.nagios_server }}

nagios-service:
  service:
    - running
    - name: {{ map.nagios_service }}
    - enable: true
