#!/usr/bin/env python3

from pathlib import Path
import sys
import json
import requests

input = sys.stdin.read()
input_json = json.loads(input)
disk2 = input_json.get("disk_volume")
p = Path(disk2)
disk1 = str(p.parent)+ "/unknow-" +str(p.name.split('.')[0])+ "." +str(p.name.split('.')[1])
p.name.split('.')[0]
url = 'http://localhost:8000/growfs/'
data = {"old_disk":disk1, "new_disk":disk2}
headers = {'Content-Type': 'application/json'}
response = requests.post(url, data=json.dumps(data), headers=headers)

output = {
    "old_disk": disk1,
    "new_disk": disk2
}

output_json = json.dumps(output,indent=2)
print(output_json)
