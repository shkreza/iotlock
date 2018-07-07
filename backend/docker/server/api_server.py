from flask import Flask, request, make_response, jsonify
from functools import wraps
from iothub_service_client import IoTHubDeviceMethod, IoTHubError
from utils import read_config, SECRETS_ROOT, SECRETS_ROOT_IOTHUB, get_tls_cert_key_paths, get_iot_hub_connection_string

SERVICE_CONNECTION_STRINGS = {
    'iot-hub-2': get_iot_hub_connection_string()
}
METHOD_NAME = 'lockDoor'
METHOD_PAYLOAD = '10'
TIMEOUT = 10

API_BASE_PATH = '/api/v0'

app = Flask(__name__)

HEADER_PARAMS = {
    'device_id': 'x-device-id',
    'hub_name': 'x-hub-name'
}

def invoke_device(hub_name, device_id, method_name):
    if not hub_name or not device_id or not method_name or not hub_name in SERVICE_CONNECTION_STRINGS:
        return None
    connection_string = SERVICE_CONNECTION_STRINGS[hub_name]
    if not connection_string:
        return None

    try:
        iothub_device_method = IoTHubDeviceMethod(connection_string)
        response = iothub_device_method.invoke(device_id, method_name, METHOD_PAYLOAD, TIMEOUT)
        return response
    except IoTHubError as iothub_error:
        print('Error occurred: {}'.format(iothub_error))
        return None

def make_error_response(error_msg, code):
    return make_response(jsonify({'error': error_msg}), code)

def requires_device_id(f):
    @wraps(f)
    def decorated_requires_device_id(*args, **kwargs):
        header_param = HEADER_PARAMS['device_id']
        device_id = request.headers.get(header_param)
        if not device_id:
            return make_error_response('Missing required header: {}'.format(header_param), 400)
        else:
            return f(device_id, *args, **kwargs)
    return decorated_requires_device_id

def requires_hub_name(f):
    @wraps(f)
    def decorated_requires_hub_name(*args, **kwargs):
        header_param = HEADER_PARAMS['hub_name']
        hub_name =  request.headers.get(header_param)
        if not hub_name:
            return make_error_response('Missing required header: {}'.format(header_param), 400)
        else:
            return f(hub_name, *args, **kwargs)
    return decorated_requires_hub_name

@app.route(API_BASE_PATH + '/lock', methods=['POST'])
@requires_device_id
@requires_hub_name
def api_update_lock(hub_name, device_id):
    method_response = invoke_device(hub_name, device_id, METHOD_NAME)
    if not method_response:
        return make_error_response('Error occurred: {}'.format('Invocation failed; device might be offline.'), 500)
    if method_response.status == 200:
        return make_response(jsonify({'payload': method_response.payload}), 200)
    else:
        return make_error_response('Error occurred: {}'.format(method_response.payload), method_response.status)

@app.route(API_BASE_PATH + '/lock', methods=['GET'])
@requires_device_id
@requires_hub_name
def api_get_lock_state(hub_name, device_id):
    assert(device_id)
    assert(hub_name)
    
    message = 'Found these parameters: hub_name={}, device_id={}'.format(hub_name, device_id)
    return make_response(jsonify({'message': message}), 200)

