import re
import sys
import json
import libvirt
import yaml
import subprocess
from xml.dom import minidom
from tinydb import TinyDB, Query

def libvirt_callback(userdata, err):
    pass
libvirt.registerErrorHandler(f=libvirt_callback, ctx=None)

def plateform_connect():
    try:
        conn = None
        conn = libvirt.open("qemu:///system")
        dom = None
        return conn
    except libvirt.libvirtError as e:
        return sys.stderr

def dom_status(vm_name):
    conn = plateform_connect()
    try:
        dom = None
        dom = conn.lookupByName(vm_name)
        if dom.isActive():
            return 1
        else:
            return 0
    except libvirt.libvirtError as e:
        return "aucun domaine ne correspond au nom fourni"
    conn.close
        
def dom_start(vm_name):
    conn = plateform_connect()
    try:
        dom = conn.lookupByName(vm_name)
        dom.create()
    except libvirt.libvirtError as e:
        return sys.stderr
    conn.close
    
def dom_shutdown(vm_name):
    conn = plateform_connect()
    try:
        dom = conn.lookupByName(vm_name)
        dom.destroy()
    except libvirt.libvirtError as e:
        return sys.stderr
    conn.close
    
def dom_getIpaddress(vm_name):
    conn = plateform_connect()
    try:
        dom = conn.lookupByName(vm_name)
        ip_list = []
    except libvirt.libvirtError as e:
        print(json.dumps({'Error': 'Failed to get the domain object'}, indent=4))
        exit(1)
        
    ifaces = dom.interfaceAddresses(libvirt.VIR_DOMAIN_INTERFACE_ADDRESSES_SRC_AGENT, 0)
    for (name, val) in ifaces.items():
        if val['addrs']:
            for addr in val['addrs']:
                if addr['type'] == libvirt.VIR_IP_ADDR_TYPE_IPV4:
                    ip_list.append(eval("{'ip':'" +addr['addr']+ "', 'mac':'" +val['hwaddr']+ "'}"))
    res = list(filter(lambda ip_list: '172.' in ip_list['ip'], ip_list))
    return json.dumps(res[0], indent=4)
    conn.close() 

def virt_resize(old_disk, new_disk):
    subprocess.Popen(["sudo","virt-resize", "--expand", "/dev/sda2", old_disk, new_disk])

def virt_customize(pub_key, dom_disk):
    subprocess.Popen(["sudo", 
                      "virt-customize", "-a", dom_disk, 
                      "--touch", "/home/user/.ssh/authorized_keys", 
                      "--append-line", "/home/user/.ssh/authorized_keys:"+pub_key, 
                      "--firstboot-command", "chown user:user -R /home/user/.ssh/; chmod  600 /home/user/.ssh/authorized_keys",
                      "--touch", "/etc/sudoers.d/users",
                      "--append-line", "/etc/sudoers.d/users:user ALL=(ALL) NOPASSWD: ALL"
                      ])

def check_server_action(database_file, nom, action):
    db = TinyDB(database_file)
    rslt = Query()
    response = 0 if len(db.search(( rslt.name == nom) & (rslt.action == action ))) == 0 else 1
    return response
  
def add_server_action(database_file, nom, action):
    if check_server_action(database_file, nom, action) == 0:
        db = TinyDB(database_file)
        db.insert({'name':nom, 'action':action})

def add_record(host_vars_file, vm_name):
    with open(host_vars_file,'r') as ansible_routeur_host_vars_file:
        host_vars = yaml.safe_load(ansible_routeur_host_vars_file) 
    getDom_info =json.loads(dom_getIpaddress(vm_name)) 
    #print(host_vars)
    host_vars['dhcp'].append({'serverName':vm_name, 'macAddress':getDom_info['mac'], 'ipAddress':getDom_info['ip']})
    with open(host_vars_file,'w') as ansible_routeur_host_vars_file:
        yaml.safe_dump(host_vars, ansible_routeur_host_vars_file)
    ansible_playbook()

def checkServerNameInfile(fileName, server_name):
    try:
        with open(fileName,'r') as ansible_routeur_host_vars_file:
            host_vars = yaml.safe_load(ansible_routeur_host_vars_file) 
        result = [item for item in host_vars['dhcp'] if item['serverName'] == server_name]
        response = 0 if len(result) == 0 else 1
    except:
        response = 0
    return response

def ansible_playbook():
    #subprocess.Popen(["source", "/home/user/python/virtual/environment/bin/activate"])
    #subprocess.Popen(["export", "ANSIBLE_CALLBACK_PLUGINS=\"$(python3 -m ara.setup.callback_plugins)\""], cwd="/home/user/python/virtual/environment/bin")
    subprocess.Popen(["ansible-playbook", "-i", "inventories/hosts", "playbooks/dhcp-dns.yml", "-D", "-u", "user", "--tags=dhcp"], cwd="/var/www/html")

def remove_vm_name_on_host_vars(host_vars_file, server_name):
    try:
        with open(host_vars_file,'r') as ansible_routeur_host_vars_file:
            host_vars = yaml.safe_load(ansible_routeur_host_vars_file) 
        result = [item for item in host_vars['dhcp'] if not item['serverName'] == server_name]
        list_d = {"dhcp": []}
        for item in result: list_d["dhcp"].append(item)
        with open(host_vars_file,'w') as ansible_routeur_host_vars_file:
            yaml.safe_dump(list_d, ansible_routeur_host_vars_file)
        response = 0
        ansible_playbook()
    except:
        response = 1
    return response

def remove_server_action(database_file, nom):
    db = TinyDB(database_file)
    rslt = Query()
    db.remove(rslt.name == nom)

def remove_server(database_file, host_vars_file, vm_name):
    remove_server_action(database_file, vm_name)
    remove_vm_name_on_host_vars(host_vars_file, vm_name)
    ansible_playbook()

def getIp(vm_name):
    getDom_info = json.loads(dom_getIpaddress(vm_name))

    return getDom_info['ip']


   