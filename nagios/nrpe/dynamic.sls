# In order to be useful to Nagios, the NRPE daemon needs needs:
#
#  - A check script on minion disk:
#      e.g. file /usr/lib/nagios/plugins/check_ldap
#
#  - A command definition on minion disk:
#      e.g., /etc/nagios/nrpe.d/disk-space.cfg, which contains: |
#        command[check_disk_usage]=/usr/lib/nagios/plugins/check_disk arg1 arg2 arg3
#

{% from "nagios/map.jinja" import nrpe with context %}

{% if grains['os_family'] in ['Debian','RedHat']  %}

include:
  - nagios.nrpe.server
  - nagios.plugins

{% if salt['pillar.get']("nagios:checks", False) %}
{% for check_name, check_def in salt['pillar.get']("nagios:checks").items() %}
{% if not check_def.get('decommissioned') %}
{% if 'plugin_file' in check_def['plugin'] %} {# skip checks that are non-NRPE, aka remote checks #}
{{ check_name }} nagios plugin:
{% if 'plugin_source' in check_def['plugin'] %}
  file.managed:
    - name: {{ nrpe.plugin_dir }}/{{ check_def['plugin']['plugin_file'] }}
    - source: {{ check_def['plugin']['plugin_source'] }}
    - mode: '0755'
{% else %}
  file.exists:
    - name: {{ nrpe.plugin_dir }}/{{ check_def['plugin']['plugin_file'] }}
{%- endif %}
    - require:
      - sls: nagios.plugins
{% endif %}  # plugin_file in check_def['plugin']
{% endif %}  # decommed

{% if check_def.get('decommissioned') %}
clear decommissioned {{ check_name }} nrpe command:
  file.absent:
    - name: {{ nrpe.cfg_dir }}/{{ check_name }}.cfg
{% else %}
{% if 'plugin_file' in check_def['plugin'] %} {# skip checks that are non-NRPE, aka remote checks #}
{{ check_name }} nrpe command definition:
  file.managed:
    - name: {{ nrpe.cfg_dir }}/{{ check_name }}.cfg
    - mode: {{ nrpe.cmd_mode }}
    - contents: |
        command[{{ check_name }}]={{ nrpe.plugin_dir }}/{{ check_def['plugin']['plugin_file'] }} {{ check_def['plugin'].get('plugin_args', "") }}
    - require:
      - file: {{ check_name }} nagios plugin
      - file: {{ nrpe.cfg_dir }}
    - watch_in:
      - service: nrpe-server-service
{% endif %}  # if 'plugin_file' in check_def['plugin']
{% endif %}  # decommed

{% endfor %}  # end on the minion
{% endif %}   # if salt['pillar.get']("nagios:checks", False)

{% endif %}  #
