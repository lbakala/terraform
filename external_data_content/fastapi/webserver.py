from fastapi import FastAPI
from pydantic import BaseModel
import time
import dom_utils
import subprocess
from pathlib import Path

app = FastAPI()
class VolumeChange(BaseModel):
    old_disk: str
    new_disk: str
class DataCustom(BaseModel):
    pub_key: str
    new_disk: str
class ServerName(BaseModel):
    server_name: str
@app.post("/growfs/")
async def growfs(disk: VolumeChange):
    old_disk = disk.old_disk
    new_disk = disk.new_disk
    p = Path(new_disk)
    vm_name = p.name.split('.')[0]
    if (dom_utils.dom_status(str(p.name.split('.')[0])) == 0 & dom_utils.check_server_action('/var/www/html/database.json', vm_name, 'grows') == 0 ):
        subprocess.Popen(["/var/www/html/resize.sh", old_disk, new_disk])
        response = {"msg": "grows fs are succesfully"}
    else:
        response = {"msg": "disk are already growing"}
    return response

@app.post("/custom/")
async def custom(cady: DataCustom):
    pub_key = cady.pub_key
    new_disk = cady.new_disk
    p = Path(new_disk)
    vm_name = p.name.split('.')[0]
    if dom_utils.check_server_action('/var/www/html/database.json', vm_name, 'pushsshkey') == 0:
        if dom_utils.dom_status(str(p.name.split('.')[0])) == 1:
            dom_utils.dom_shutdown(p)
            time.sleep(20)
        subprocess.Popen(["/var/www/html/guestfish.sh", new_disk, pub_key, vm_name]) 
    response=dom_utils.dom_getIpaddress(vm_name)
    return response['ip']

@app.post("/provision/")
async def provision(server: ServerName):
    server_name = server.server_name
    dom_utils.dom_start(server_name)
    time.sleep(30)
    if dom_utils.checkServerNameInfile('/var/www/html/inventories/host_vars/routeur.yml', server_name) == 0:
        dom_utils.add_record(server_name)
    subprocess.Popen(["/var/www/html/ansible-playbook.sh", server_name]) 
 
if __name__ == "__main__":
    import uvicorn
 
    uvicorn.run(app, host="127.0.0.1", port=8000)
