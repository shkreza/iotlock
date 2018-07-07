from os import path, getenv

SECRETS_ROOT=getenv('SECRETS_ROOT', '/secrets/lock-backend')
SECRETS_ROOT_IOTHUB=path.join(SECRETS_ROOT, 'iot-hub-connectionstring/secret')
SECRETS_ROOT_TLS_CERT=path.join(SECRETS_ROOT, 'tls-secrets/tls.crt')
SECRETS_ROOT_TLS_KEY=path.join(SECRETS_ROOT, 'tls-secrets/tls.key')

def read_config(filepath):
    with open(filepath) as f:
        return f.read().splitlines()[0]

def get_tls_cert_key_paths():
    return SECRETS_ROOT_TLS_CERT, SECRETS_ROOT_TLS_KEY

def get_iot_hub_connection_string():
    return read_config(SECRETS_ROOT_IOTHUB)
