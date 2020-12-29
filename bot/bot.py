import RPi.GPIO as GPIO
import time
import enum

from bot.controller import Controller


class Direction(enum.Enum):
    forward = GPIO.LOW
    backward = GPIO.HIGH


class EurekaBot(Controller):
    def __init__(
        self,
        min_speed=10,
        max_speed=100,
        turn_speed=20,
        default_speed=20,
        acceleration_duration=0.1,
    ):
        super().__init__(gpio_left_pin=15, gpio_right_pin=22)
        self.min_speed = min_speed
        self.max_speed = max_speed
        self.turn_speed = turn_speed
        self.default_speed = default_speed
        self.acceleration_duration = acceleration_duration
        self.current_speed = 0
        self.current_acceleration = 0
        self.friction = 0.95
        # Found this value by experimenting
        self.rotation_constant = 0.175

    def _get_speed(self, acceleration):
        if acceleration != 0:
            speed = self.current_speed + acceleration * self.acceleration_duration
        else:
            speed = self.default_speed
        return min(max(round(speed, 2), 0), self.max_speed)

    def _accelerate(self, acceleration):
        # Set magnitude
        self.current_speed = self._get_speed(acceleration)
        self.current_acceleration = acceleration
        self._set_speed(side='both', speed=self.current_speed)
        if acceleration > 0:
            time.sleep(self.acceleration_duration)

    def move(self, acceleration, duration):
        if duration > 0:
            start_time = time.time()
            while (time.time() - start_time <= duration) and self.current_speed < self.max_speed:
                self._accelerate(acceleration=acceleration)
        else:
            self._accelerate(acceleration=acceleration)

        print(f'acc={self.current_acceleration}')

    def turn(self, duration, speed=0):
        start_time = time.time()
        while time.time() - start_time <= duration:
            self._set_speed(side='both', speed=speed if speed else self.turn_speed)

    def break_bot(self):
        self._set_speed(side='both', speed=0)
        self.current_acceleration = 0

    def _get_rotation_duration(self, speed, angle):
        duration = (self.rotation_constant * angle) / speed
        # print(f'duration = {duration}, angle={angle}')
        return round(duration, 2)

    def _set_rotation_direction(self, direction):
        if direction == 'clockwise':
            self._set_pin_value(self.direction_pins['left'], Direction.forward.value)
            self._set_pin_value(self.direction_pins['right'], Direction.backward.value)
        else:
            self._set_pin_value(self.direction_pins['left'], Direction.backward.value)
            self._set_pin_value(self.direction_pins['right'], Direction.forward.value)

    def rotate(self, angle=0, duration=0, speed=0, direction='clockwise'):
        self._set_rotation_direction(direction=direction)
        if angle:
            duration = self._get_rotation_duration(
                speed=speed if speed else self.turn_speed,
                angle=angle,
            )
        self.turn(duration=duration, speed=speed)

    def stop(self):
        if self.current_acceleration > 0:
            while self.current_speed > self.min_speed:
                self._accelerate(acceleration=-self.current_acceleration / self.friction)
        self.current_speed = 0
        self._set_speed(side='both', speed=self.current_speed)

    def move_forward(self, acceleration=0, duration=3):
        # Set direction
        self._set_pin_value(self.direction_pins.values(), Direction.forward.value)
        self.current_acceleration = acceleration
        self.move(duration=duration, acceleration=acceleration)
        self.stop()

    def move_backward(self, acceleration=0, duration=3):
        # Set direction
        self._set_pin_value(self.direction_pins.values(), Direction.backward.value)
        self.current_acceleration = acceleration
        self.move(duration=duration, acceleration=acceleration)
        self.stop()

    def move_left(self, speed=0, angle=90):
        self.rotate(angle=angle, speed=speed, direction='anti-clockwise')

    def move_right(self, speed=0, angle=90):
        self.rotate(angle=angle, speed=speed, direction='clockwise')
