======
nagios
======

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

Install the nagios server, nagios plugins, nrpe plugin and server packages.

``nagios.plugins``
------------------

Install nagios plugins.

``nagios.server``
-----------------

Install the nagios package and start the nagios service.


``nagios.nrpe``
---------------

Install the nrpe plugin and server.

``nagios.nrpe.server``
----------------------

Install the nrpe server.

``nagios.nrpe.plugin``
----------------------

Install the nrpe plugin.

``nagios.nsca.client``
----------------------

Install the nsca client.
