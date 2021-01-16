import VL53L0X


class TimeOfFlight:
    def __init__(
            self,
            i2c_bus=0,
            i2c_address=0x29,
            accuracy_mode=VL53L0X.Vl53l0xAccuracyMode.GOOD,
    ):
        self.i2c_bus = i2c_bus
        self.i2c_address = i2c_address
        self.accuracy_mode = accuracy_mode
        self.distance = 0

        try:
            self._initialize_sensor()
        except Exception as ex:
            raise ex

    def _initialize_sensor(self):
        self.tof = VL53L0X.VL53L0X(
            i2c_bus=self.i2c_bus,
            i2c_address=self.i2c_address,
        )
        self.tof.open()
        self.tof.start_ranging(self.accuracy_mode)
        self.timing = self.tof.get_timing()
        if self.timing < 20000:
            self.timing = 20000
        self.timing = self.timing/1000000.00

    def get_distance(self):
        self.distance = self.tof.get_distance()

