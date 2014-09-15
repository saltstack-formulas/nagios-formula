{% from "nagios/map.jinja" import nsca with context %}

nagios-nsca-client-package:
  pkg.installed:
    - name: {{ nsca.client }}

/etc/send_nsca.cfg:
  file.managed:
    - source: salt://nagios/nsca/files/send_nsca.cfg.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 600
