from iothub_client import IoTHubClient, IoTHubClientError, IoTHubTransportProvider, IoTHubClientResult
from iothub_client import DeviceMethodReturnValue
import time

DEVICE_CONNECTION_STRING = 'HostName=iot-hub-2.azure-devices.net;DeviceId=deviceId1;SharedAccessKey=94087330616332088728883600506995923600569519'
PROTOCOL = IotHubTransportProvider.MQTT
EXIT = False

def device_method_cb(method_name, payload, user_context):
    print('Device method callback: {}, {}'.format(method_name, payload))
    device_method_return_val = DeviceMethodReturnValue()
    if method_name == 'f1':
        print('Method is f1')
        device_method_return_val.status = 200
        device_method_return_val.response = '{"message": "All done"}'
    if method_name == 'exit':
        print('Method is exit!')
        global EXIT
        EXIT = True

    else:
        device_method_return_val.status = 404
        device_method_return_val.response = '{"error": "Direct method {} not found"}'.format(method_name)
    return device_method_return_val

def main():
    client = IoTHubClient(DEVICE_CONNECTION_STRING, PROTOCOL)
    client.set_device_method_callback(device_method_cb, None)
    global EXIT
    while EXIT:
        time.sleep(1)

if __name__ == '__main__':
    main()