from iothub_client import IoTHubClient, IoTHubClientError, IoTHubTransportProvider, IoTHubClientResult
from iothub_client import DeviceMethodReturnValue
from grovepi import digitalWrite, digitalRead, pinMode
import time

DEVICE_CONNECTION_STRING = 'HostName=iot-hub-2.azure-devices.net;DeviceId=deviceId1;SharedAccessKey=nyzcfE3uWQ4oZ4XOPMjDY4ndIRADowUyw4fsZ+zBjdo='
PROTOCOL = IoTHubTransportProvider.MQTT
EXIT = False

PIN = 4

initialized = False
on_or_off = 0

def initialize_grovepi():
    global initialized
    global on_or_off
    initialized = pinMode(PIN, 'OUTPUT')
    on_or_off = digitalRead(PIN)

def device_method_cb(method_name, payload, user_context):
    global initialized
    global on_or_off
    print ( "\nMethod callback called with:\nmethodName = %s\npayload = %s" % (method_name, payload) )
    device_method_return_value = DeviceMethodReturnValue()
    if method_name == "lockDoor":
        try:
            # Build and send the acknowledgment.

            if not initialized:
                device_method_return_value.response = "{ \"Response\": \"Could not initialize GrovePi\" }"
                device_method_return_value.status = 500
            else:
                on_or_off = not on_or_off
                digitalWrite(PIN, on_or_off)

                device_method_return_value.response = "{{ \"Response\": \"Executed direct method {}, {}, {}\" }}".format(method_name, initialized, on_or_off)
                device_method_return_value.status = 200
        except ValueError:
            # Build and send an error response.
            device_method_return_value.response = "{ \"Response\": \"Invalid parameter\" }"
            device_method_return_value.status = 400
    else:
        # Build and send an error response.
        device_method_return_value.response = "{ \"Response\": \"Direct method not defined: %s\" }" % method_name
        device_method_return_value.status = 404
    return device_method_return_value
    if method_name == 'lockDoor':
        print('Method is lockDoor')
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
    initialize_grovepi()
    client = IoTHubClient(DEVICE_CONNECTION_STRING, PROTOCOL)
    client.set_device_method_callback(device_method_cb, None)
    global EXIT
    while not EXIT:
        print('.')
        time.sleep(1)
    print('Exiting...')

if __name__ == '__main__':
    main()
