
import argparse
import json
import requests
import re


def main(args):
  requests.packages.urllib3.disable_warnings()

  base_url = "https://"+ args.pcip +":9440/api/nutanix/v3/vms/list"
  s = requests.Session()
  s.auth = (args.user, args.passwd)
  s.headers.update({'Content-Type': 'application/json; charset=utf-8'})

  payload = json.dumps({ "kind": "vm", "sort_attribute": "name", "sort_order": "ASCENDING" })
  print payload
  data = s.post(base_url, data=payload, verify=False).json()

  for entity in data['entities']:
    if re.search("__curie_test_", entity['status']['name']):

      print entity['metadata']['uuid'] + " " + entity['status']['name']

      e_get_url = "https://"+ args.pcip +":9440/api/nutanix/v3/vms/"+entity['metadata']['uuid']
      e = s.get(e_get_url, data={}, verify=False).json()

      print "Protecting VM " + entity['status']['name']
      e['metadata']['categories_mapping']['ProtectionRule'] = [ args.prrule ]
      e['metadata']['categories']['ProtectionRule'] = args.prrule

      e_put_url = "https://"+ args.pcip +":9440/api/nutanix/v3/vms/"+entity['metadata']['uuid']

      l = { "spec": e['spec'], "api_version": "3.1", "metadata": e['metadata'] }
      payload = json.dumps(l)
      data = s.put(e_put_url, data=payload, verify=False).json()

if __name__ == "__main__":
  parser = argparse.ArgumentParser(description="Prism Central API")
  parser.add_argument('--user')
  parser.add_argument('--passwd')
  parser.add_argument('--prrule')
  parser.add_argument('--pcip')
  main(parser.parse_args())

