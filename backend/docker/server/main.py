from utils import get_tls_cert_key_paths
from api_server import app

tls_secrets = get_tls_cert_key_paths()
print('TLS SECRETS: {}'.format(tls_secrets))

def main():
    server_config = {
        'port': 443,
        'host': '0.0.0.0',
        'debug': True,
        'ssl_context': get_tls_cert_key_paths()
    }
    app.run(**server_config)

if __name__ == '__main__':
    main()