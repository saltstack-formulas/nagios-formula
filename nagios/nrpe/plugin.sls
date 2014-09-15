{% from "nagios/map.jinja" import nrpe with context %}

nrpe-plugin-package:
  pkg.installed:
    - name: {{ nrpe.plugin }}
