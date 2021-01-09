import os
import sys

import asyncio
from fastapi import FastAPI, WebSocket
from starlette.websockets import WebSocketDisconnect

PACKAGE_PARENT = '..'
SCRIPT_DIR = os.path.dirname(os.path.realpath(os.path.join(os.getcwd(), os.path.expanduser(__file__))))
sys.path.append(os.path.normpath(os.path.join(SCRIPT_DIR, PACKAGE_PARENT)))

from bot.sensors.proximity import Proximity
from bot.bot import EurekaBot
from server.tasks import Tasks

app = FastAPI()

front_proximity = Proximity(port=0, threshold=100)
rear_proximity = Proximity(port=1, threshold=100)

bot = EurekaBot()
tasks = Tasks(
    front_proximity=front_proximity,
    rear_proximity=rear_proximity,
    proximity_threshold=60,
    bot=bot,
)

loop = asyncio.get_event_loop()
loop.create_task(tasks.get_proximity())
loop.create_task(tasks.check_proximity())


def act(x, y, turn_left, turn_right, speed):
    bot.current_speed = speed

    if turn_left is True:
        bot.move_left()
    elif turn_right is True:
        bot.move_right()

    if y == 0.0:
        bot.break_bot()

    if ((300.0 <= x < 360.0) or (0.0 <= x < 60.0)) and (y != 0.0):
        bot.move_forward(acceleration=0, duration=0)
    elif ((120.0 <= x < 180.0) or (180 <= x < 240.0)) and (y != 0.0):
        bot.move_backward(acceleration=0, duration=0)
    elif (60.0 <= x < 120.0) and (y != 0.0):
        bot.rotate(angle=5, direction='clockwise')
    elif (240.0 <= x < 300) and (y != 0.0):
        bot.rotate(angle=5, direction='anti-clockwise')


@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()
    try:
        while True:
            request = await websocket.receive_json()
            act(**request)
            proximity = {
                'front': front_proximity.proximity,
                'rear': rear_proximity.proximity,
            }
            await websocket.send_json(proximity)
    except WebSocketDisconnect:
        bot.break_bot()
        print('Client disconnected')



