import os
import sys

import cv2
import nanocamera as nano
from fastapi import FastAPI, WebSocket
from starlette.responses import StreamingResponse
from starlette.websockets import WebSocketDisconnect

PACKAGE_PARENT = '..'
SCRIPT_DIR = os.path.dirname(os.path.realpath(os.path.join(os.getcwd(), os.path.expanduser(__file__))))
sys.path.append(os.path.normpath(os.path.join(SCRIPT_DIR, PACKAGE_PARENT)))

from bot.sensors.proximity import Proximity
from bot.bot import EurekaBot

app = FastAPI()
bot = EurekaBot()
proximity_front = Proximity(port=0, threshold=100)
proximity_back = Proximity(port=1, threshold=100)


def act(x, y, turn_left, turn_right, speed):
    if speed > 0:
        bot.default_speed = speed

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
                'front': proximity_front.get_proximity(),
                'back': proximity_back.get_proximity()
            }
            await websocket.send_json(proximity)

    except WebSocketDisconnect:
        print('Client disconnected')
