from iothub_client import IoTHubClient, IoTHubClientError, IoTHubTransportProvider, IoTHubClientResult
from iothub_client import DeviceMethodReturnValue
from grovepi import digitalWrite, digitalRead, pinMode
from picamera import PiCamera
from time import sleep
from os import path, getcwd
import sys
from base64 import standard_b64encode
from urllib.parse import quote_plus

FILENAME='capture.jpeg'
FILEPATH = path.join(getcwd(), FILENAME)
print(FILEPATH)

IMAGE_SIZE=(320, 240)
camera = PiCamera()

DEVICE_CONNECTION_STRING = 'HostName=iot-hub-2.azure-devices.net;DeviceId=deviceId1;SharedAccessKey=0kjODrYQF0i0e5JiTuC7JiDuSCeK7wQwlnP+XKq+vrU='
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

def capture_image(image_size=None):
    try:
        camera.capture(FILEPATH, resize=image_size)
        img = open(FILEPATH, 'rb').read()
        enc = quote_plus(standard_b64encode(img))
        return True, enc
    except Exception as e:
        return False, 'Error again: {}'.format(str(e))


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

                capture_result, encoded_image = capture_image(IMAGE_SIZE)
                json_response = "{{ \"Response\": \"Executed direct method {}, {}, {}\", \"capture_result\": \"{}\", \"encoded_image\": \"{}\" }}".format(method_name, initialized, on_or_off, capture_result, encoded_image)
                # print(json_response)
                device_method_return_value.response = json_response
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

def main():
    initialize_grovepi()
    client = IoTHubClient(DEVICE_CONNECTION_STRING, PROTOCOL)
    client.set_device_method_callback(device_method_cb, None)
    global EXIT
    while not EXIT:
        print('.')
        sleep(1)
    print('Exiting...')

if __name__ == '__main__':
    main()
