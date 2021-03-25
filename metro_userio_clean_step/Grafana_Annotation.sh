# Purpose: Create the Grafana curl command to add an annotation using XRAY_OPENVARS.env.
# tony.casanova@nutanix.com
# October 7, 2019

source ./XRAY_OPENVARS.env

echo "curl -H \"Authorization: Bearer $XRAY_OPENVAR_Grafana_API_KEY\" \
http://$XRAY_OPENVAR_Grafana_IP_PORT/api/annotations \
-H \"Content-Type: application/json\" \
-d '{\"text\":\"&#x269B; $XRAY_OPENVAR_Annotation_Text \
&#x269B; Summary: $XRAY_OPENVARS_task_summary \
<a href=\\\"https://$XRAY_OPENVAR_XRAY_IP/results/$XRAY_OPENVARS_id\\\">&#x2622; XRAY Link</a>\"\
,\"tags\":[\"$XRAY_OPENVARS_targets_default_context_cluster_name\"]}'
" > grafana_annotation.cmd.txt

chmod 777 grafana_annotation.cmd.txt

source ./grafana_annotation.cmd.txt

