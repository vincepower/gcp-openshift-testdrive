import random
import yaml

PROPERTY_LENGTH = 'length'

MIN_LENGTH=3
CHARACTERS = 'abcdefghijkmnopqrstuvwxyz'

class InputError(Exception):
  """Raised when input properties are unexpected."""


def GenerateConfig(context):
  """Entry function to generate the DM config."""
  props = context.properties
  length = props.setdefault(PROPERTY_LENGTH, MIN_LENGTH)

  content = {
      'resources': [],
      'outputs': [{
          'name': 'string',
          'value': GenerateRandomString(length)
      }]
  }
  return yaml.dump(content)


def GenerateRandomString(length=3):
  """Generates a random string."""
  if length < MIN_LENGTH:
    raise InputError('Password length must be at least %d' % MIN_LENGTH)
  global CHARACTERS
  out = ''
  for _ in range(length):
    char=random.choice(CHARACTERS)
    CHARACTERS = CHARACTERS.translate(None, char)
    out += char
  return out
