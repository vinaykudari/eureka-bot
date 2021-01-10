import cv2
import queue
import threading
import time


class Camera:
    def __init__(self, src=0, width=640, height=480, font=cv2.FONT_HERSHEY_PLAIN):
        self.font = font
        self.streamer = cv2.VideoCapture(src, cv2.CAP_V4L2)
        self.streamer.set(cv2.CAP_PROP_FOURCC, cv2.VideoWriter_fourcc('M', 'J', 'P', 'G'))
        self.streamer.set(cv2.CAP_PROP_FRAME_WIDTH, width)
        self.streamer.set(cv2.CAP_PROP_FRAME_HEIGHT, height)
        self.streamer.set(cv2.CAP_PROP_BUFFERSIZE, 1)

        # Warmup the camera
        self.streamer.read()

        # @todo Unable to reduce frame streaming delay with threading
        self.Q = queue.Queue(maxsize=128)
        # t = threading.Thread(target=self._reader)
        # t.daemon = True
        # t.start()

    @staticmethod
    def _to_bytes(buffer, web=True):
        frame_bytes = buffer.tobytes()
        if web:
            frame_bytes = (
                    b'--frame\r\n'
                    b'Content-Type: image/jpeg\r\n\r\n' + frame_bytes + b'\r\n'
            )
        return frame_bytes

    def _process_frame(self, frame, typ=None, data={}):
        if typ == 'add_text':
            frame = cv2.putText(
                frame,
                data.get('text', 'No text provided'),
                (10, 100),
                self.font,
                1,
                (255, 255, 255),
                1
            )
        return frame

    def _get_frame(self):
        grabbed, frame = self.streamer.read()
        if not grabbed:
            return

        processed_frame = self._process_frame(frame)
        return processed_frame

    def _reader(self):
        while True:
            if not self.Q.full():
                frame = self._get_frame()
                flag, buffer = cv2.imencode('.jpg', frame)
                if not flag:
                    return

                self.Q.put(self._to_bytes(buffer))

    def get_stream_queue(self):
        while True:
            yield self.Q.get()

    def get_stream(self):
        while True:
            frame = self._get_frame()
            if frame is None:
                break
            flag, buffer = cv2.imencode('.jpg', frame)
            if not flag:
                return
            yield self._to_bytes(buffer)
