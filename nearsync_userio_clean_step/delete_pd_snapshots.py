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

  g_url = "https://"+ args.pgip +":9440/PrismGateway/services/rest/v2.0/protection_domains/"+ args.pdname +"/dr_snapshots"
  data = s.get(g_url, verify=False).json()

  for entity in data['entities']:
    print entity['snapshot_id']
    d_url = "https://"+ args.pgip +":9440/PrismGateway/services/rest/v2.0/protection_domains/"+ args.pdname +"/dr_snapshots/"+ entity['snapshot_id']
    s.delete(d_url, verify=False)
    time.sleep(1)

if __name__ == "__main__":
  parser = argparse.ArgumentParser(description="Delete PD schedule using Prism API")
  parser.add_argument('--user')
  parser.add_argument('--passwd')
  parser.add_argument('--pdname')
  parser.add_argument('--pgip')
  main(parser.parse_args())
