from fastapi import FastAPI
from pydantic import BaseModel
import dom_utils
import time
import json
from pathlib import Path
from fastapi.responses import JSONResponse

app = FastAPI()
database_file = '/var/www/html/database.json'
host_vars = '/var/www/html/host_vars'
class VolumeChange(BaseModel):
    old_disk: str
    new_disk: str
    pub_key: str
class ServerName(BaseModel):
    machine: str
@app.post("/growfs/")
async def growfs(disk: VolumeChange):
    old_disk = disk.old_disk
    new_disk = disk.new_disk
    pub_key = disk.pub_key
    p = Path(new_disk)
    vm_name = p.name.split('.')[0]
    if dom_utils.check_server_action(database_file, vm_name, 'growfs') == 0:
        if dom_utils.dom_status(vm_name) == 1:
            dom_utils.dom_shutdown(vm_name)
            time.sleep(20)
        dom_utils.virt_resize(old_disk, new_disk)
        dom_utils.add_server_action(database_file, vm_name, 'growfs')
        time.sleep(30)
    if dom_utils.check_server_action(database_file, vm_name, 'addsshpubkey') == 0:
        if dom_utils.dom_status(vm_name) == 1:
            dom_utils.dom_shutdown(vm_name)
            time.sleep(20)
        dom_utils.virt_customize(pub_key, new_disk)
        dom_utils.add_server_action(database_file, vm_name, 'addsshpubkey')
        print("fin des actions grows - demarrage du système en cours ...")
        time.sleep(60)
    dom_utils.dom_start(vm_name)
    time.sleep(20)
    if dom_utils.checkServerNameInfile(host_vars, vm_name) == 0:
        dom_utils.add_record(host_vars, vm_name)
    value = { 
        "ipAddress": dom_utils.getIp(vm_name),
    }
    return JSONResponse(value)

@app.post("/destroy/")
async def provision(computer: ServerName):
    machine = computer.machine
    dom_utils.remove_server(database_file, host_vars, machine)

 
if __name__ == "__main__":
    import uvicorn
 
    uvicorn.run(app, host="127.0.0.1", port=8000)
