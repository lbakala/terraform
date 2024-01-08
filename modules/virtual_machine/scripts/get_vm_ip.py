import re
import sys
import json
import libvirt

def libvirt_callback(userdata, err):
    pass
libvirt.registerErrorHandler(f=libvirt_callback, ctx=None)

conn = None
try:
    conn = libvirt.open("qemu:///system")
except libvirt.libvirtError as e:
    print(repr(e), file=sys.stderr)
    exit(1)

domainName = 'routeur'
try:
    dom = conn.lookupByName(domainName)
    ip_dict = dict()
    ip_list = []
    elm =''
    chaine =''
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
print(json.dumps(res[0], indent=4))
conn.close()            
exit(0)
