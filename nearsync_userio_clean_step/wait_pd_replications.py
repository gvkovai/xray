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

  end_time = time.time() + int(args.wtime)
  while end_time > time.time():
    r_url = "https://"+ args.pgip +":9440/PrismGateway/services/rest/v2.0/protection_domains/"+ args.pdname +"/replications/"
    data = s.get(r_url, verify=False).json()
    print data

    if data['metadata']['count'] == 0:
      time.sleep(1)
    else:
      end_time = time.time() + int(args.wtime)

    time.sleep(5)

if __name__ == "__main__":
  parser = argparse.ArgumentParser(description="Wait for PD replications to complete using Prism API")
  parser.add_argument('--user')
  parser.add_argument('--passwd')
  parser.add_argument('--pdname')
  parser.add_argument('--pgip')
  parser.add_argument('--wtime')
