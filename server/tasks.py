import asyncio

from bot.bot import EurekaBot, Direction


class Tasks:
    def __init__(self, bot: EurekaBot, front_proximity, rear_proximity, proximity_threshold):
        self.bot = bot
        self.front = front_proximity
        self.rear = rear_proximity
        self.proximity_threshold = proximity_threshold
        self.can_move_forward = True
        self.can_move_backward = True

    def _can_move_forward(self):
        self.can_move_forward = not (self.front.proximity > self.proximity_threshold)
        return self.can_move_forward

    def _can_move_backward(self):
        self.can_move_backward = not (self.rear.proximity > self.proximity_threshold)
        return self.can_move_backward

    async def get_proximity(self):
        while True:
            self.front.get_proximity()
            self.rear.get_proximity()
            await asyncio.sleep(0.1)

    async def avoid_collision(self):
        while True:
            if not self._can_move_forward() and self.bot.current_direction == Direction.forward:
                self.bot.break_bot()
            if not self._can_move_backward() and self.bot.current_direction == Direction.backward:
                self.bot.break_bot()
            await asyncio.sleep(0.1)
