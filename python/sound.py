#!/usr/bin/env python3

import asyncio
import sys
import pyaudio
import argparse
import logging
import json
from signal import *
from buffer import Buffer

#===========================================================================
# Signal Handler / shutdown procedure

def signalHandler(signum, frame):

  logging.info(f'Caught termination signal: {signum}')

  try:
    shutdown_pyaudio()
  except Exception as e:
    logging.error(f'Oh dang! {repr(e)}')
  finally:
    logging.info('Peace out!')
    sys.exit(0)

#================================================================
# PyAudio Functions
#================================================================

# Closes the audio stream

def close_audio_stream():

  logging.debug(f"Closing audio stream.")

  global audio_stream

  if audio_stream:
    audio_stream.close()
    audio_stream = None

#----------------------------------------------------------------

# Terminates the PyAudio session and releases resources

def terminate_pyaudio():

  logging.debug(f"Terminating PyAudio Session.")

  global pyaudio_obj

  if pyaudio_obj:
    pyaudio_obj.terminate()
    pyaudio_obj = None

#----------------------------------------------------------------

# Closes the active record stream and terminates pyaudio pbject
# Resets global variables to None

def shutdown_pyaudio():

  logging.info(f"Shutting down PyAudio.")

  close_audio_stream()
  terminate_pyaudio()

#----------------------------------------------------------------

# Creates instances of PyAudio and PyAudio.Stream objects.
# Called when a TCP network connection is establish with the Processing server.
# When there are writeable frames available, they are requested from the server.

def initialize_audio_stream():

  logging.debug("Initializing PyAudio Device.")

  global pyaudio_obj, audio_stream

  buffer.clear()

  try:
    pyaudio_obj = pyaudio.PyAudio()
    audio_stream = pyaudio_obj.open(
      format=FORMAT,
      channels=CHANNELS,
      rate=RATE,
      frames_per_buffer=BLOCK_SIZE,
      output=True,
      output_device_index=DEVICE
    )

    logging.info("PyAudio Device Initialized.")
  except Exception as e:
    logging.error(f"While inializing audio device: {e}")
    sys.exit(1)

#================================================================
# asyncio TCP client used to connect to server hosted by Processing Sketch
# basic funtionality includes:
# - automatic reconnection attemps
# - initialization of the audio outpu stream upon connection
# - requests audio data from Processing sketch when needed by audio stream
# - read and buffer audio data from the Processing sketch
# - extract audio data from the buffer to hand off to the audio stream

async def coplanar_nations_client(host='localhost', port=12345):

  logging.info(f"Starting network client.")

  global network_writer, network_reader

  while True:

    #----------------------------------------------------------------

    # If there's no network connection, attempt to connect.
    while network_writer == None:

      try:
        network_reader, network_writer = await asyncio.open_connection(host, port)
        logging.info(f"Connected to server @ {host}:{port}.")
      except OSError as e:
        logging.debug(f"OSError: {e}")
      except Exception as e:
        logging.error(f"While establishing server connection: {e}")

      # Retry after 1 second if attempt fails.
      await asyncio.sleep(1)

    #----------------------------------------------------------------

    # Upon successful connection, set up the PyAudio output stream
    initialize_audio_stream()

    #----------------------------------------------------------------

    # network_writer is not None after establishing a TCP connection w/ Processing server
    while network_writer:

      try:
        # check whether the audio stream had writable frames available
        if (frames := audio_stream.get_write_available()) >= BLOCK_SIZE:

          # request them from the Processing server
          network_writer.write(
            json.dumps({'frame_count': frames}).encode()
          )
          await network_writer.drain()

          # read data from the Processing server
          # add data to the buffer it holds less data than available to be written to the audio stream
          if (data := await network_reader.read(65536)):
            buffer.put(data)

          # extract the data available to write to the audio stream from the buffer
          audio_data = bytes(buffer.get(frames))

          # write that data to the audio stream
          audio_stream.write(audio_data)

        # wait for half the time if would take to play through the data
        await asyncio.sleep(BLOCK_SIZE / (2 * RATE))

      except Exception as e:
        logging.error(f"While writing to socket: {e}")
        network_writer = None
        network_reader = None
        shutdown_pyaudio()

#================================================================
# Sets up argument parsing from cli

def parse_args():

  parser = argparse.ArgumentParser(description="AudioStream client")

  parser.add_argument(
    "--host",
    required=False,
    default="localhost",
    type=str,
    help="Specifies the location of the Processing server. Accepts CIDR or IPv4."
  )

  parser.add_argument(
    "--port",
    required=False,
    default=1337,
    type=int,
    help="Listening port for the Processing server."
  )

  parser.add_argument(
    "--width",
    required=False,
    default=1,
    type=int,
    choices=range(1,5),
    help="Specify bit depth: 1 = 8 bits, 2 = 16 bits, 3 = 24 bits, 4 = 32 bits."
  )

  parser.add_argument(
    "--device",
    required=False,
    default=None,
    help="Specify which audio output device to use."
  )

  parser.add_argument(
    "--samplerate",
    required=False,
    default=48000,
    choices=[22050,44100,24000,48000,96000],
    type=int,
    help="Set samples per second. Device dependent. Accepted values: 22050, 24000, 44100, 48000, 96000"
  )

  parser.add_argument(
    "--blocksize",
    required=False,
    default=1024,
    type=int,
    help="Sets the audio output buffer size. Use larger number if dropouts are experienced."
  )

  parser.add_argument(
    "--loglevel",
    required=False,
    default=20,
    type=int,
    choices=[0,10,20,30,40,50],
    help="Set logging level: 0=NOTSET, 10=DEBUG, 20=INFO, 30=WARNING, 40=ERROR, 50=CRITICAL",
  )

  return parser.parse_args()

#================================================================

if __name__ == "__main__":

  # setup signal handlers
  signal(SIGINT, signalHandler)
  signal(SIGTERM, signalHandler)
  signal(SIGHUP, signalHandler)

  #----------------------------------------------------------------
  # parse arguments from cli

  args = parse_args()

  #----------------------------------------------------------------
  # configure logging

  logging.basicConfig(
    level=args.loglevel,
    format='[Coplanar Nations Sound Engine] - %(levelname)s | %(message)s'
  )

  #----------------------------------------------------------------
  # define global variables

  WIDTH = args.width
  FORMAT = pyaudio.get_format_from_width(WIDTH)
  CHANNELS = 1
  RATE = args.samplerate
  BLOCK_SIZE = args.blocksize
  DEVICE = args.device

  # PyAudio objects
  pyaudio_obj = None
  audio_stream = None

  # asyncio network client objects used for communication with the Processing server
  network_writer = None
  network_reader = None

  # custom FIFO-like buffer for audio data recevied from the Processing server
  buffer = Buffer(zero_pad=False)

  #----------------------------------------------------------------
  # Sanity check that our variables are set as we wish

  # PyAudio variables
  logging.info(f"Width: {WIDTH}")
  logging.info(f"Format: {FORMAT}")
  logging.info(f"Channels: {CHANNELS}")
  logging.info(f"Sample Rate: {RATE}")
  logging.info(f"Block Size: {BLOCK_SIZE}")
  logging.info(f"Device Id: {DEVICE}")

  # Server variables
  logging.info(f"Host: {args.host}")
  logging.info(f"Port: {args.port}")

  #----------------------------------------------------------------

  try:

    # run the client until an unhandled exception occurs or signal is caught 
    asyncio.run(
      coplanar_nations_client(
        host=args.host,
        port=args.port
      )
    )

  except Exception as e:
    template = "An exception of type {0} occurred. Arguments:\n{1!r}"
    message = template.format(type(e).__name__, e.args)
    logging.error(f'Ooops! {message}')
  finally:
    shutdown_pyaudio()
    sys.exit(0)


