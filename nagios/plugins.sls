{% from "nagios/map.jinja" import map with context %}

nagios-plugins:
  pkg:
    - installed
    - name: {{ map.nagios_plugins }}
