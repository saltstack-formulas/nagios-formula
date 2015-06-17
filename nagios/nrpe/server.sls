{% from "nagios/map.jinja" import nrpe with context %}

nrpe-server-package:
  pkg.installed:
    - name: {{ nrpe.server }}

nrpe-server-service:
  service.running:
    - name: {{ nrpe.service }}
    - enable: true

/etc/nagios/nrpe.cfg:
   file.managed:
    - source: salt://nagios/nrpe/files/nrpe.cfg.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - watch_in:
      - service: {{ nrpe.service }}

{% if grains['os_family'] == 'Debian' %}
{# may be implied by the os_family, but let's be sure #}
{{ nrpe.cfg_dir }}:
  file.directory:
    - require:
      - pkg: nrpe-server-package
{% endif %}

{% if grains['os_family'] == 'Arch' %}
nrpe-group:
  group.present:
    - name: nrpe
    - system: true
    - gid: 31

nrpe-user:
  user.present:
    - name: nrpe
    - shell: /bin/false
    - home: /usr/share/nagios
    - gid_from_name: true
    - system: true
    - uid: 31
    - guid: 31

extend:
  /etc/nagios/nrpe.cfg:
    file:
      - user: nrpe
      - group: nrpe
      - require:
        - user: nrpe-user
        - group: nrpe-group
{% endif %}
