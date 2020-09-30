# Open Distro For Elasticsearch

---------

## 安全

### 开启kerberos

- 修改 elasticsearch\plugins\opendistro_security\securityconfig\config.yml

```yml
authc:
    kerberos_auth_domain:
    http_enabled: true
    transport_enabled: true
    order: 6
    http_authenticator:
        type: kerberos
        challenge: true
        config:
        # If true a lot of kerberos/security related debugging output will be logged to standard out
        krb_debug: false
        # If true then the realm will be stripped from the user name
        strip_realm_from_principal: true
    authentication_backend:
        type: noop
```
