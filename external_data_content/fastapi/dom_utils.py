import re
import sys
import json
import libvirt
import yaml
from xml.dom import minidom

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

def add_record(vm_name):
    with open('routeur.yaml','r') as ansible_routeur_host_vars_file:
        host_vars = yaml.safe_load(ansible_routeur_host_vars_file) 
    getDom_info = dom_getIpaddress(vm_name)    
    host_vars['dhcp'].append({'serverName':vm_name ,'macAddress':getDom_info['mac'] ,'ipAddress':getDom_info['ip']})
    with open('routeur.yaml','w') as ansible_routeur_host_vars_file:
        yaml.safe_dump(host_vars, ansible_routeur_host_vars_file)
