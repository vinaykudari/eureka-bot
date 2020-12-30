from apds9960 import APDS9960
import smbus


class Proximity:
    def __init__(self, port, threshold=50):
        self.port = port
        self.threshold = threshold
        self.bus = smbus.SMBus(port)

        try:
            self._initialize_sensor()
        except Exception as ex:
            raise ex

    def _initialize_sensor(self):
        self.apds = APDS9960(self.bus)
        self.apds.setProximityIntLowThreshold(self.threshold)
        self.apds.enableProximitySensor()

    def get_proximity(self):
        return self.apds.readProximity()

