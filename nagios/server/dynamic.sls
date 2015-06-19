
# In order for Nagios to know to ask a nrpe daemon for a check to be run, or
# to run a check locally, the following things must be defined on the nagios
# host, in addition to having the hosts and hostgroups defined elsewhere.
#
#  - A global command definition in a nagios config stub: |
#      define command {
#        command_name check_disk_usage
#        command_line $USER1$/check_nrpe -H $HOSTADDRESS$ -c check_disk_usage
#      }
#
#  - A service definition in a nagios config stub: |
#      define service {
#        use limited-notification-service
#        service_description Check for low disk space on any local disks
#        display_name check_disk
#        check_command check_disk_usage
#        hostgroup_name com.example
#      }

{% from "nagios/map.jinja" import nagios with context %}

{{ nagios.dynamic_cfg_dir }}:
  file.directory:
    - makedirs: True

{% for check_name, check_def in salt['pillar.get']("nagios:checks").items() %}
{% if check_def.get('decommissioned') %}
clear decommissioned {{ check_name }} global nagios command definition:
  file.absent:
    - name: {{ nagios.dynamic_cfg_dir }}/{{ check_name }}.command.global.cfg
{% else %}
{{ check_name }} global nagios command definition:
  file.managed:
    - name: {{ nagios.dynamic_cfg_dir }}/{{ check_name }}.command.global.cfg
    - contents: |
        define command {
          command_name {{ check_name }}
{%- if 'command_name' in check_def['plugin'] %}
          command_line $USER1$/{{ check_def['plugin']['command_name'] }} {{ check_def['plugin'].get('command_args', "") }}
{%- else %}
          command_line $USER1$/check_nrpe -H $HOSTADDRESS$ -c {{ check_name }}
{%- endif %}
        }
{% endif %}  # decommed
    - require:
      - file: {{ nagios.dynamic_cfg_dir }}

{% if check_def.get('decommissioned') %}
clear decommissioned {{ check_name }} nagios service definition:
  file.absent:
    - name: {{ nagios.dynamic_cfg_dir }}/{{ check_name }}.service.global.cfg
{% else %}
{{ check_name }} nagios service definition:
  file.managed:
    - name: {{ nagios.dynamic_cfg_dir }}/{{ check_name }}.service.global.cfg
    - contents: |
        define service {
          use {{ check_def['service'].get('template', "limited-notification-service") }}
          service_description {{ check_def['service']['description'] }}
          display_name {{ check_name }}
          check_command {{ check_name }}
{%- if 'hostgroups' in check_def['service'] %}
          hostgroup_name {{ check_def['service']['hostgroups']|join(',') }}
{%- endif %}
{%- if 'hostnames' in check_def['service'] %}
          host_name {{ check_def['service']['hostnames']|join(',') }}
{%- endif %}
        }
{% endif %}  # decommed
    - require:
      - file: {{ nagios.dynamic_cfg_dir }}
{% endfor %}

{% if salt['pillar.get']("nagios:pseudohosts", False) %}
nagios psuedohosts file:
  file.managed:
    - name: {{ nagios.dynamic_cfg_dir }}/pseudohosts.cfg
    - contents: |
{%- for pseudohost, attributes in salt['pillar.get']("nagios:pseudohosts").items() %}
        define host {
          use linux-server
          host_name {{ pseudohost }}
{%- if attributes %}{# dict value of None is legal here; if so, skip. #}
{%- if attributes.get('parent', False) %}
          parent {{ attributes['parent'] }}
{%- endif %}
{%- endif %}
        }
{%- endfor %}
{% else %}
no stale nagios pseudohost defs:
  file.absent:
    - name: {{ nagios.dynamic_cfg_dir }}/pseudohosts.cfg
{% endif %}
    - require:
      - file: {{ nagios.dynamic_cfg_dir }}
