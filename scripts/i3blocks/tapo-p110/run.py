import json
import sys
import uuid

from base64 import b64encode, b64decode
from requests import Session
from pathlib import Path

import PyP100.PyP100
from PyP100 import PyP110
from PyP100 import tp_link_cipher

tapoP110Secrets = json.loads(Path(str(Path.home()) + '/.ssh/secrets/tapo-p110.json').read_text(encoding="UTF-8"))

class MyP110(PyP110.P110):
    def __init__(self, ipAddress="", email="", password="", config={}):
        self.ipAddress = ipAddress
        self.email = email
        self.password = password
        self.terminalUUID = str(uuid.uuid4())
        self.session = Session()
        self.errorCodes = PyP100.PyP100.ERROR_CODES
        self.encryptCredentials(email, password)
        if config:
            self.privateKey = config["key"]["write"].encode("UTF-8")
            self.publicKey = config["key"]["read"].encode("UTF-8")
            self.cookie = config["cookie"]
            self.token = config["token"]
            self.tpLinkCipher = tp_link_cipher.TpLinkCipher(
                b64decode(config["cipher"]["key"].encode("UTF-8")),
                b64decode(config["cipher"]["iv"].encode("UTF-8"))
            )
        else:
            self.createKeyPair()

def i3blockPrint(p110: MyP110,input: list[str]):
  current = int(p110.getEnergyUsage()["result"]["current_power"] / 1000)
  deviceState = p110.getDeviceInfo()["result"]["device_on"]
  if deviceState == True:
    symbol=" "
  else:
    symbol=""
  label = str(input[3])
  minWAT = int(input[4])
  maxWAT = int(input[5])
  print(label + ": " + str(current) + "W"+symbol)
  print(label + ": " + str(current) + "W"+symbol)

  if current <= minWAT:
      color = "#FFFF00"
  elif current >= maxWAT:
      color = "#FF0000"
  else:
      color = "#00FF00"
  print(color)


p110 = MyP110(
    ipAddress=tapoP110Secrets["plugs"][sys.argv[1]],
    email=tapoP110Secrets["email"],
    password=tapoP110Secrets["password"],
    config=json.loads(Path('/tmp/tapo-p110.' + sys.argv[1] + '.json').read_text(encoding="UTF-8"))
)

what=str(sys.argv[2])

if what == "i3blockPrint":
  i3blockPrint(p110,sys.argv)
else:
  print(sys.argv)
  print(json.dumps(p110.getDeviceInfo()))
  #print(json.dumps(p110.getEnergyUsage()))
