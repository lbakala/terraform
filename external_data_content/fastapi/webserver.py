from fastapi import FastAPI
from pydantic import BaseModel
import check_status
import subprocess
from pathlib import Path

app = FastAPI()
class VolumeChange(BaseModel):
    old_disk: str
    new_disk: str
@app.post("/growfs/")
async def growfs(disk: VolumeChange):
    old_disk = disk.old_disk
    new_disk = disk.new_disk
    p = Path(new_disk)
    if check_status.dom_status(str(p.name.split('.')[0])) == 0:
        subprocess.Popen(["/var/www/html/resize.sh", old_disk, new_disk])
    return {"msg": "we got data succesfully"}

#add publickey to disk image << en cours ...
#start dom << ok
#pause << ok
#get ip adresse << ok
#add dns ans dhcp info to routeur host_vars ansible << en cours ...
#run ansible-playbook to do change 
 
if __name__ == "__main__":
    import uvicorn
 
    uvicorn.run(app, host="127.0.0.1", port=8000)
