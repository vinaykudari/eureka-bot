from fastapi import FastAPI, WebSocket
from starlette.websockets import WebSocketDisconnect

app = FastAPI()


def resolve_coordinates(x, y):
    print(x, y, y)


@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()
    try:
        while True:
            data = await websocket.receive_json()
            x, y = round(data['x']), round(data['y'], 2)
            await websocket.send_text(f"x: {x}, y: {y}")
    except WebSocketDisconnect:
        print('Client disconnected')

