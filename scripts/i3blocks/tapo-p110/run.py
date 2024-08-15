import sys
import json
import time

from pathlib import Path

from PyP100.PyP110 import P110

tapoP110Secrets = json.loads(Path(str(Path.home()) + '/.ssh/secrets/tapo-p110.json').read_text(encoding="UTF-8"))

def i3blockPrint(p110: P110,input: list[str]):
  current = int(p110.getEnergyUsage()["current_power"] / 1000)
  deviceState = p110.getDeviceInfo()["device_on"]
  if deviceState == True:
    symbol=" "
  else:
    symbol=""
  label = str(input[3])
  minWAT = int(input[4])
  maxWAT = int(input[5])
  output={"full_text":label + ": " + str(current) + "W"+symbol,"short_text":label + ": " + str(current) + "W"+symbol}
  if current <= minWAT:
      output["color"] = "#FFFF00"
  elif current >= maxWAT:
      output["color"] = "#FF0000"
  else:
      output["color"] = "#00FF00"

  print(json.dumps(output),flush=True)

p110 = P110(
    address=tapoP110Secrets["plugs"][sys.argv[1]],
    email=tapoP110Secrets["email"],
    password=tapoP110Secrets["password"],
    preferred_protocol="new"
)

what=str(sys.argv[2])

if what == "i3blockPrint":
  while True:
    i3blockPrint(p110,sys.argv)
    time.sleep(5)
else:
  print(sys.argv)
  print(json.dumps(p110.getDeviceInfo()))
  #print(json.dumps(p110.getEnergyUsage()))
