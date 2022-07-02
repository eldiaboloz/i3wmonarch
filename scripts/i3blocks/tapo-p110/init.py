import json
import base64
import sys

from pathlib import Path

from PyP100 import PyP110

tapoP110Secrets = json.loads(Path(str(Path.home()) + '/.ssh/secrets/tapo-p110.json').read_text(encoding="UTF-8"))

p110 = PyP110.P110(
    ipAddress=tapoP110Secrets["plugs"][sys.argv[1]],
    email=tapoP110Secrets["email"],
    password=tapoP110Secrets["password"]
)

p110.handshake()
p110.login()

config = {
    "key": {"write": p110.privateKey.decode("UTF-8"), "read": p110.publicKey.decode("UTF-8")},
    "cookie": p110.cookie,
    "token": p110.token,
    "cipher": {
        "key": base64.b64encode(p110.tpLinkCipher.key).decode("UTF-8"),
        "iv": base64.b64encode(p110.tpLinkCipher.iv).decode("UTF-8")
    }
}

Path('/tmp/tapo-p110.' + sys.argv[1] + '.json').write_text(data=json.dumps(config), encoding="UTF-8");
