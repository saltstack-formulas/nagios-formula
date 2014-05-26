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
