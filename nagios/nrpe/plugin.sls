{% from "nagios/map.jinja" import map with context %}

nrpe-plugin-package:
  pkg:
    - installed
    - name: {{ map.nrpe_plugin }}
