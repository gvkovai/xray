import argparse
import json
import requests
import re
import time


def main(args):
  requests.packages.urllib3.disable_warnings()

  s = requests.Session()
  s.auth = (args.user, args.passwd)
  s.headers.update({'Content-Type': 'application/json; charset=utf-8'})

  # Get all existing protected VMs and unprotect them
  print "Getting all VMs that are in protected mode"
  b_url = "https://"+ args.pgip +":9440/PrismGateway/services/rest/v2.0/protection_domains/"+ args.pdname
  data = s.get(b_url, verify=False).json()
  vms = []
  for entity in data['vms']:
    vms.append(entity['vm_name'])
  print vms

  print "Unprotect VMs: clear the list of protected VMs"
  p_url = "https://"+ args.pgip +":9440/PrismGateway/services/rest/v2.0/protection_domains/"+ args.pdname +"/unprotect_vms"
  payload = json.dumps(vms)
  res = s.post(p_url, data=payload, verify=False).json()
  print res

  print "Get all existing VMs that need to be protected"
  base_url = "https://"+ args.pgip +":9440/PrismGateway/services/rest/v2.0/vms/?sort_order=ASCENDING&sort_attribute=name"
  data = s.get(base_url, verify=False).json()

  uuids = []
  for entity in data['entities']:
    if re.search("__curie_test_", entity['name']):
      print entity['uuid'] + " " + entity['name']
      uuids.append(entity['uuid'])

  # Protect VMs - wait is introduced for the above calls to sync in
  time.sleep(3)
  e_post_url = "https://"+ args.pgip +":9440/PrismGateway/services/rest/v2.0/protection_domains/"+ args.pdname  +"/protect_vms"
  l = { "uuids": uuids }
  payload = json.dumps(l)
  res = s.post(e_post_url, data=payload, verify=False).json()
  print res

if __name__ == "__main__":
  parser = argparse.ArgumentParser(description="Prism Central API")
  parser.add_argument('--user')
  parser.add_argument('--passwd')
  parser.add_argument('--pdname')
  parser.add_argument('--pgip')
  main(parser.parse_args())
