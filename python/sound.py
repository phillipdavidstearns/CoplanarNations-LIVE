#!/usr/bin/env python3

import sys
import pyaudio
import logging
import socket
import json
from time import sleep
from threading import Thread, Lock, Timer
from signal import *

#===========================================================================
# Signal Handler / shutdown procedure

def signalHandler(signum, frame):
  logging.info(f'Caught termination signal: {signum}')
  shutdown()

def shutdown():
  try:
    client.stop()
    sound.stop()
  except Exception as e:
    logging.error(f'Oh dang! {repr(e)}')
  finally:
    logging.info('Peace out!')
    sys.exit(0)

#===========================================================================

class Client(Thread):
  def __init__(self, host='127.0.0.1', port=1337):
    super().__init__()
    self.daemon = True
    self.host = host
    self.port = port
    self.buffer = bytearray()
    self.socket = None
    self.lastSlice = bytearray()
    self.is_connected = False
    self.doRun = False
    self.lock = Lock()

  def init_socket(self):
    logging.info(f"connecting...")
    try:
      self.socket = socket.socket()
      self.socket.connect((self.host, self.port))
      self.is_connected = True
      logging.info('connected!')
    except socket.error as e:
      logging.error(f"{type(e).__name__}: {e}")
    except Exception as e:
      self.is_connected = False
      template = "An exception of type {0} occurred. Arguments:\n{1!r}"
      message = template.format(type(e).__name__, e.args)
      logging.error(f'{message}')

  def write(self, message):
    try:
      if self.is_connected: 
        self.socket.send(bytes(message, 'utf-8'))
    except socket.error as e:
      logging.error(f'{e}')
      self.is_connected = False

  def read(self):
    if not self.is_connected: return
    try: # grab a chunk of data from the socket...
      message = self.socket.recv(65536).decode('utf-8')
      message = json.loads(message)
      data = bytes(message['data'])
      if data :
        with self.lock:
          self.buffer = data # if there's any data there, add it to the buffer
    except socket.error as e:
      logging.error(f'read() Socket Error: {e}')
      self.lastSlice = bytearray()
      self.is_connected = False
    except json.JSONDecodeError as e:
      pass
    except Exception as e: # if there's definitely no data to be read. the socket will throw and exception
      logging.error(f'read() Other Error: {type(e).__name__}\n{e}')
      pass

  def extractFrames(self, frames, width):
    bufferSize = frames * width
    if len(self.lastSlice) == 0:
      self.lastSlice = bytearray(bytes([127])*bufferSize)

    with self.lock:
      extractedFrames = self.buffer[:bufferSize] # grab a slice of data from the buffer
      # remove the extracted data from the buffer
      self.buffer = self.buffer[len(extractedFrames):]

    if len(extractedFrames) == 0:
      extractedFrames = self.lastSlice
    else:
      self.lastSlice = extractedFrames

    # this makes sure we return as many frames as requested, by padding with audio "0"
    extractedFrames = extractedFrames + bytes([127]) * (bufferSize - len(extractedFrames))

    return extractedFrames

  def run(self):
    logging.info('[Client] run()')
    self.doRun = True
    while self.doRun:
      try:
        while not self.is_connected and self.doRun:
          self.init_socket()
          sleep(5)
        self.read()
        sleep(0.0001)
      except Exception as e:
        logging.error('run(): %s' % repr(e))

  def stop(self):
    logging.info('[Client] stop()')
    self.doRun = False
    try:
      self.socket.close()
    except Exception as e:
      logging.error('While closing socket: %e' % repr(e))
    self.join()

#===========================================================================
# Audifer
# PyAudio stream instance and operations. By default pyAudio opens the stream in its own thread.
# Callback mode is used. Documentation for PyAudio states the process
# for playback runs in a separate thread. Initializing in a subclassed Thread may be redundant.

class Audifier():
  def __init__(
    self,
    qtyChannels=1,
    width=1,
    rate=48000,
    chunkSize=1920,
    deviceIndex=None,
    callback=None
  ):

    if not callback:
      raise Exception(f'Audifier instance requires a callback function. Got: {callback}')

    self.doRun=False
    self.qtyChannels = qtyChannels
    self.width = width
    self.rate = rate
    self.chunkSize = chunkSize
    self.deviceIndex = deviceIndex
    self.callback = callback
    self.pa = pyaudio.PyAudio()
    self.stream = self.initPyAudioStream()

  #On initialization, check for and use headphones, else fallback to speakers
  def initPyAudioStream(self):
    if not self.deviceIndex:
      for i in range(self.pa.get_device_count()):
        device = self.pa.get_device_info_by_index(i)
        print(device)
        print()

        if 'name' in device and device['name'] == 'External Headphones':
          print('External Headphones')
          self.deviceIndex = device['index']
          break
        elif 'name' in device and device['name'] == 'MacBook Pro Speakers':
          print('MacBook Pro Speakers')
          self.deviceIndex = device['index']
          break

    stream = self.pa.open(
      format=self.pa.get_format_from_width(self.width),
      channels=self.qtyChannels,
      rate=self.rate,
      frames_per_buffer=self.chunkSize,
      input=False,
      output_device_index=self.deviceIndex,
      output=True,
      stream_callback=self.callback,
      start=False
    )
    return stream

  def start(self):
    logging.info('[AUDIFIER] run()')
    logging.debug("Starting audio stream...")
    self.stream.start_stream()
    if self.stream.is_active():
      logging.debug("Audio stream is active.")

  def stop(self):
    logging.info('[AUDIFIER] stop()')
    self.stream.close()
    self.pa.terminate()

if __name__ == "__main__":

  width = 1

  logging.basicConfig(
    level=10,
    format='[Coplanar Nations Sound Engine] - %(levelname)s | %(message)s'
  )

  client = Client(
      host = '127.0.0.1',
      port = 1337
    )

  def audio_callback(in_data, frame_count, time_info, status):
    message = json.dumps({
      'type' : 'get',
      'parameter' : 'frames',
      'frame_count' : frame_count
    })
    client.write(message)
    audioChunk = client.extractFrames(frame_count, width)
    return(bytes(audioChunk), pyaudio.paContinue)

  sound = Audifier(width=width, callback=audio_callback)

  signal(SIGINT, signalHandler)
  signal(SIGTERM, signalHandler)
  signal(SIGHUP, signalHandler)

  try:

    client.start()
    sound.start()

    while True:
      sleep(1)

  except Exception as e:
    template = "An exception of type {0} occurred. Arguments:\n{1!r}"
    message = template.format(type(e).__name__, e.args)
    logging.error(f'Ooops! {message}')
    

