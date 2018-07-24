import random

from flask import request
from flask import jsonify

from app import app

# For when we get bad data from the user
class InvalidParameters(Exception):
  def __init__(self,message,payload=None):
    Exception.__init__(self)
    self.message = message
    self.status_code = 400
    self.payload = payload
    
  def to_dict(self):
    rv = dict(self.payload or {})
    rv['errorMessage'] = self.message
    return rv


@app.errorhandler(InvalidParameters)
def handle_invalid_parameters(error):
  response = jsonify(error.to_dict())
  response.status_code = error.status_code
  return response

@app.route('/')
@app.route('/index')
def index():
  min = request.args.get('min',default = 0, type = int)
  max = request.args.get('max',default = 12, type = int)
  if max < min:
    raise InvalidParameters("Max must not be lower than min")

  return jsonify(
    min = min,
    max = max,
    randomNumber = random.randint(min,max)
  )

@app.route('/health')
def health():
  return jsonify(healthStatus="OK")
