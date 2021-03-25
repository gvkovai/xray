import argparse
import json
import requests
import re
import time

def is_cluster_oplog_lws_empty(cvms, timeout):
  all_cvms = set()
  verified_oplog_empty_cvms = set()
  verified_lws_empty_cvms = set()
  end_time = time.time() + int(timeout)

  for cvm in cvms:
    all_cvms.add(cvm)

  print all_cvms
  print verified_oplog_empty_cvms
  print verified_lws_empty_cvms

  while len(all_cvms - verified_oplog_empty_cvms) > 0 and len(all_cvms - verified_lws_empty_cvms) > 0 and end_time > time.time():
    print "True"
    # check for oplog and LWS empty
    for cvm_ip in all_cvms:
      print cvm_ip
      # Get LWS/Oplog Util status
      url = "http://%s:2009/oplog_flush_stats" % cvm_ip
      try:
        response = requests.get(url)
        response.raise_for_status()
      except requests.exceptions.ConnectionError:
        print("Couldn't connect to CVM at %s to get oplog_flush_stats.",
                      cvm_ip)
        continue
      try:
        # Expect response to look like:
        # >>> m = re.search("Total((.*\n){7})", res.content)
        # >>> print m.group(0)
        # Total</b></td>
        # <td>0</td>
        # <td>1638399</td>
        # <td>0.0</td>
        # <td>0</td>
        # <td>1336454</td>
        # <td>0.0</td>
        m = re.search("Total((.*\n){7})", response.content)
        oplog_util = m.group(0).split('\n')[3].replace('<td>', '').replace('</td>','')
        lws_util = m.group(0).split('\n')[6].replace('<td>', '').replace('</td>','')
      except BaseException:
        print("Received unexpected response while waiting for LWS "
                     "to be empty at URL '%s': %r", url, response.content)
        continue
      else:
         if oplog_util == "0.0":
           print("Oplog is empty for '%s'", cvm_ip)
           verified_oplog_empty_cvms.add(cvm_ip)
         if lws_util == "0.0":
           print("LWS is empty for '%s'", cvm_ip)
           verified_lws_empty_cvms.add(cvm_ip)

  if end_time < time.time():
    print("Timeout. Oplog/LWS is not empty yet")
    return False
  else:
    print("Oplog/LWS are empty")
    return True

def main(args):
  requests.packages.urllib3.disable_warnings()

  if is_cluster_oplog_lws_empty(args.cvms.split(","), args.timeout):
    print "is_cluster_oplog_lws_empty: succeeded"
    time.sleep(int(args.wtime))
  else:
    print "is_cluster_oplog_empty: failed"
    exit(1)

if __name__ == "__main__":
  parser = argparse.ArgumentParser(description="Wait for Oplog/LWS empty using :2009")
  parser.add_argument('--cvms', required="Comma separated CVM IP Addresses")
  parser.add_argument('--timeout', default=1800, help="Timeout waiting for oplog/lws empty")
  parser.add_argument('--wtime', default=60, help="Waiting time while oplog/lws is empty")
  main(parser.parse_args())
