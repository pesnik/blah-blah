from __future__ import annotations

import os

from airflow.www.fab_security.manager import AUTH_LDAP

basedir = os.path.abspath(os.path.dirname(__file__))

WTF_CSRF_ENABLED = True
WTF_CSRF_TIME_LIMIT = None

# ----------------------------------------------------
# AUTHENTICATION CONFIG
# ----------------------------------------------------
AUTH_TYPE = AUTH_LDAP

AUTH_LDAP_USE_TLS = False
AUTH_LDAP_SERVER = "ldap://ip:389"

AUTH_LDAP_BIND_USER = "username"
AUTH_LDAP_BIND_PASSWORD = "password"
AUTH_LDAP_SEARCH = "ou=Permanent Employee,ou=AgentsHQ,dc=agents,dc=com"
AUTH_LDAP_UID_FIELD = "sAMAccountName"
