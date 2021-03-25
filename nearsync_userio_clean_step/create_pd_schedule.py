import argparse
import json
import requests
import re
import time

def time_usecs():
  return int(round(int((time.time()+60)*1000*1000)))

def main(args):
  requests.packages.urllib3.disable_warnings()

  s = requests.Session()
  s.auth = (args.user, args.passwd)
  s.headers.update({'Content-Type': 'application/json; charset=utf-8'})

  l = { "pd_name": args.pdname, "type": args.stype, "every_nth": args.nth, "user_start_time_in_usecs": time_usecs(), "start_times_in_usecs": [ time_usecs() ], "retention_policy": { "local_max_snapshots": None, "remote_max_snapshots": {}, "local_retention_period": 1, "remote_retention_period": { args.remote: 1 }, "local_retention_type": "DAYS", "remote_retention_type": { args.remote: "DAYS" } }, }

  payload = json.dumps(l)
  print payload

  p_url = "https://"+ args.pgip +":9440/PrismGateway/services/rest/v2.0/protection_domains/"+ args.pdname +"/schedules"
  data = s.post(p_url, data=payload, verify=False).json()
  print data

  time.sleep(3)

if __name__ == "__main__":
  parser = argparse.ArgumentParser(description="Create PD schedule using Prism API")
  parser.add_argument('--user')
  parser.add_argument('--passwd')
  parser.add_argument('--pdname')
  parser.add_argument('--pgip')
  parser.add_argument('--stype')
  parser.add_argument('--remote')
  parser.add_argument('--nth')
  main(parser.parse_args())
