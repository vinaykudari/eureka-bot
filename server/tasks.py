import asyncio


class Tasks:
    def __init__(self, bot, front_proximity, rear_proximity, proximity_threshold):
        self.bot = bot
        self.front = front_proximity
        self.rear = rear_proximity
        self.proximity_threshold = proximity_threshold

    def can_move(self):
        return not (
            self.front.proximity > self.proximity_threshold
            or self.rear.proximity > self.proximity_threshold
        )

    async def get_proximity(self):
        while True:
            self.front.get_proximity()
            self.rear.get_proximity()
            await asyncio.sleep(0.1)

    async def check_proximity(self):
        while True:
            if not self.can_move():
                self.bot.break_bot()
            await asyncio.sleep(0.1)
