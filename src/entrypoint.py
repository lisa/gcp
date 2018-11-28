import sys
import os

# Add our application's path to Python's seach path so that it can find 
# `app` and `flask`.
sys.path.append("/usr/src/app")

# Change run directory (from `/`) to where our app lives `/usr/src/app` 
os.chdir("/usr/src/app")

from app import app
debug_mode = False

debug_mode = (os.environ.get('DEBUG_MODE') == "True")

listen_port = 80
if "LISTEN_PORT" in os.environ:
  listen_port = int(os.environ.get('LISTEN_PORT'))

app.run(
  debug=debug_mode,
  host='0.0.0.0', port=listen_port
  )
