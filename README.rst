=============
nagios & nrpe
=============

Formulas to set up and configure nagios server and nrpe agent

.. note::

    See the full `Salt Formulas installation and usage instructions
    <http://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html>`_.

Available states
================

.. contents::
    :local:

``nagios``
----------

Installs the nagios and nrpe package and start the services


``nagios.server``
----------

Install the nagios package and start the nagios service.


``nagios.nrpe``
----------

Install only the nrpe agent and start the service


Example Pillar
==============

.. code:: yaml

    nagios:
      log_file: /var/nagios/nagios.log
      resource_file: /etc/nagios/resource.cfg
    
    nrpe:
      nagios_server: 127.0.0.1
      include_dir: conf.d/

