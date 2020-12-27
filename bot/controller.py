import RPi.GPIO as GPIO
import atexit


class Controller:
    def __init__(
        self,
        gpio_right_pin,
        gpio_left_pin,
        pwm_right_pin=33,
        pwm_left_pin=32,
        pin_numbering_mode=GPIO.BOARD,
        allow_warnings=False
    ):
        """Controller for a car where its left and right side motors are wired together"""
        self.gpio_left_pin = gpio_left_pin
        self.gpio_right_pin = gpio_right_pin
        self.pwm_left_pin = pwm_left_pin
        self.pwm_right_pin = pwm_right_pin
        self.direction_pins = {
            'left': self.gpio_left_pin,
            'right': self.gpio_right_pin,
        }
        self.speed_pins = {
            'left': self.pwm_left_pin,
            'right': self.pwm_right_pin,
        }
        self.sides = ['left', 'right']
        self.input_pins = {}
        self.output_pins = {
            'direction': self.direction_pins,
            'speed': self.speed_pins,
        }
        self.pins = {
            'input': self.input_pins,
            'output': self.output_pins,
        }
        self.pin_numbering_mode = pin_numbering_mode
        self.allow_warnings = allow_warnings
        self.speed_controller = {}
        self.frequency = 10000
        self._pin_cleanup()
        self._setup_pins()

    @staticmethod
    def _setup_pin_numbering_mode(mode, allow_warnings=False):
        GPIO.setmode(mode)
        GPIO.setwarnings(allow_warnings)

    @staticmethod
    def _set_pin_value(pins, values):
        GPIO.output(pins, values)

    def _setup_pins(self):
        for pins_type in self.pins:
            if self.pins[pins_type] and pins_type == 'output':
                self._setup_output_pins(self.pins[pins_type])
            elif self.pins[pins_type] and pins_type == 'input':
                GPIO.setup(
                    channels=self.pins[pins_type].values(),
                    direction=GPIO.IN,
                )

    def _setup_output_pins(self, op_pins):
        for pin_type, pins in op_pins.items():
            if pin_type == 'speed':
                # Functions registered are automatically executed
                # upon normal interpreter termination
                atexit.register(self._pwm_release)
                for side in self.sides:
                    self._setup_speed_controller(side, pins[side])
            else:
                GPIO.setup(channels=pins.values(), direction=GPIO.OUT)

    def _setup_speed_controller(self, side, pin):
        self.speed_controller[side] = GPIO.PWM(pin, self.frequency)
        self.speed_controller[side].start(0)
        self.speed_controller[side].ChangeDutyCycle(0)

    def _set_speed(self, speed, side='both'):
        if side != 'both':
            self.speed_controller[side].ChangeDutyCycle(speed)
        else:
            for side in self.sides:
                self.speed_controller[side].ChangeDutyCycle(speed)

    def _get_pin_value(self, pins):
        if isinstance(pins, dict):
            res = {}
            for pin_type in pins:
                res[pin_type] = {
                    'pins': pins[pin_type],
                    'value': self._get_pin_value(pins[pin_type]),
                }
            return res
        if isinstance(pins, list):
            return list(map(GPIO.input, pins))
        return GPIO.input(pins)

    def _pin_cleanup(self):
        """Reset GPIO pins to default(low) state and set I/O modes respectively"""
        GPIO.cleanup()
        self._setup_pin_numbering_mode(
            self.pin_numbering_mode,
            self.allow_warnings,
        )

    def _pwm_release(self):
        for side in self.sides:
            self.speed_controller[side].stop()
