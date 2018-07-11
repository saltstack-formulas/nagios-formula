{% from "nagios/map.jinja" import nsca with context %}

nagios-nsca-client-package:
  pkg.installed:
    - name: {{ nsca.client }}

/etc/send_nsca.cfg:
  file.managed:
    - source: salt://nagios/nsca/files/send_nsca.cfg.jinja
    - template: jinja
    - user: {{ nsca_client.get('user', 'root') }}
    - group: {{ nsca_client.get('group', 'root') }}
    - mode: {{ nsca_client.get('mode', '0600') }}

