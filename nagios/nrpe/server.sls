{% from "nagios/map.jinja" import nrpe with context %}

nrpe-server-package:
  pkg.installed:
    - name: {{ nrpe.server }}

nrpe-server-service:
  service.running:
    - name: {{ nrpe.service }}
    - enable: true

{% if grains['os'] == 'FreeBSD' %}
/usr/local/etc/nrpe.cfg:
   file.managed:
    - source: salt://nagios/nrpe/files/nrpe.cfg.jinja
    - template: jinja
    - user: root
    - group: wheel
    - mode: 644
    - watch_in:
      - service: {{ nrpe.service }}
{% else %}
/etc/nagios/nrpe.cfg:
   file.managed:
    - source: salt://nagios/nrpe/files/nrpe.cfg.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - watch_in:
      - service: {{ nrpe.service }}
{% endif %}

{{ nrpe.cfg_dir }}:
  file.directory:
    - require:
      - pkg: {{ nrpe.server }}


{%- if nrpe.nrpe_commands is defined %}
  {%- if nrpe.get('nrpe_commands') is mapping %}
    {%- for check_id, nrpe_command in nrpe.get('nrpe_commands').items() %}
{{ nrpe.cfg_dir }}/{{ check_id }}:
  file.managed:
    - contents: "{{ nrpe_command }}"
    - user: root
    - group: root
    - mode: 644
    - require:
      - file: {{ nrpe.cfg_dir }}
    - watch_in:
      - service: {{ nrpe.service }}
    {%- endfor %}
  {%- elif nrpe.get('nrpe_commands') is iterable %}
    {%- for nrpe_command in nrpe.get('nrpe_commands') %}
    {% set cmd_id = nrpe_command.split("[")[1].split("]")[0] %}
{{ nrpe.cfg_dir }}/{{ check_id }}:
  file.managed:
    - contents : "{{ nrpe_command }}"
    - user: root
    - group: root
    - mode: 644
    - require:
      - file: {{ nrpe.cfg_dir }}
    - watch_in:
      - service: {{ nrpe.service }}
    {%- endfor %}
  {%- endif %}
{%- endif %}


{% if grains['os_family'] == 'RedHat' %}
{# create link on Redhat to be more close to debian and other distributions #}
nagios_plugins_sym:
  file.symlink:
    - name: /usr/lib/nagios
    - target: /usr/lib64/nagios
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
