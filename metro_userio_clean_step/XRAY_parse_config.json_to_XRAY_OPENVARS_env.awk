# Purpose: To convert config.json to shell environment variables for general purpose use in shell scripts.
# tony.casanova@nutanix.com
# October 3, 2019
#

BEGIN{
DEBUG = 0
FS="[{}:\"]"
node_count = 0
}

{

# Handle the JSON Levels.
gsub(/^  "/,"L1:\"",$0)
gsub(/^    "/,"L2:\"",$0)
gsub(/^      "/,"L3:\"",$0)
gsub(/^        "/,"L4\"",$0)
gsub(/^          "/,"L5\"",$0)
gsub(/^            "/,"L6\"",$0)

# Handle the HTML embedded in descriptions.
gsub(/<strong>/,"",$0)
gsub(/<\/strong>/,"",$0)
gsub(/<br\/>\\n/," ",$0)
gsub(/\\n<br\/>/," ",$0)
gsub(/<li>/," ",$0)
gsub(/<\/li>/," ",$0)
gsub(/\\n/," ",$0)
gsub(/<ol>/," ",$0)
gsub(/<\/ol>/," ",$0)
#gsub(/\./,"_",$0)


if ( DEBUG == 1 ) { for( f=1;f<=NF;f++){printf("# NR:%s NF(%s/%s): \"%s\" ",NR,f,NF,$f)};printf("\n\n") }

if ( $1 == "L1" ) {
# Set the current L1
L1_topic = $3
L1_value = $5

if ( $3 == "id" || $3 == "name" || $3 == "preset" ) {
L1_value = $6
# Remove the trailing comma if there.
gsub(/,/,"",L1_value)
}

if ( L1_value != "" && L1_value != " " ){
#printf("L1_topic: %s L1_value: %s\n", L1_topic,L1_value)
}

if ( L1_value != "" && L1_value != " " ){
 gsub(/\./,"_",L1_topic)
 # Remove the training comma is there.
 gsub(",","",L1_value)
 # Remove empty space before and after.
 printf("export XRAY_OPENVARS_%s=\"%s\"\n",L1_topic,L1_value)
}

}


if ( $1 == "L2") {
# Set the current L2

if ( DEBUG == 1 ) { for( f=1;f<=NF;f++){printf("# NR:%s NF(%s/%s): \"%s\" ",NR,f,NF,$f)};printf("\n\n") }

L2_topic = $3
#for( f=1;f<=NF;f++){gsub(/^\s*/,"",$f);gsub(/\s*$/,"",$f)}
L2_value = $6
#printf("### L2_topic: %s\n",L2_topic)
#printf("### L2_value: %s\n",L2_value)
#printf("### L1_topic:\"%s\" L2_topic: \"%s\" L2_value: \"%s\"\n", L1_topic,L2_topic,L2_value)

if ( L2_value != "" && L2_value != " " ){


#gsub(/\./,"_",L1_topic)
#gsub(/\./,"_",L2_topic)


printf("export XRAY_OPENVARS_%s_%s=\"%s\"\n",L1_topic,L2_topic,L2_value)

}

}

if ( $1 == "L3") {
# Set the current L3
L3_topic = $3
L3_value = $5

if (  L3_topic ~ /"nodes"/  ) {
if ( DEBUG == 1 ) { printf("### nodes found.\n") }
#printf("L1_topic: %s L2_topic: %s L3_topic: %s L3_value: %s node: %s\n", L1_topic,L2_topic,L3_topic,L3_value,node_count )

gsub(/\./,"_",L1_topic)
gsub(/\./,"_",L2_topic)
gsub(/\./,"_",L3_topic)

printf("export XRAY_OPENVARS_%s_%s_%s=\"%s\"\n",L1_topic,L2_topic,L3_topic,L3_value)

if ( DEBUG == 1 ) { printf("node_count: %s\n", node_count) }
} else {
if ( DEBUG == 1 ) { printf("### nodes not found.\n") }
}

}

if ( $1 == "L4") {
# Set the current L4
L4_topic = $2

# If only four fields make the last field the value.

if ( NF == 4 ) {
L4_value = $4
} else {
L4_value = $5
}




#printf("L1_topic: %s L2_topic: %s L3_topic: %s L4_topic: %s L4_value: %s\n", L1_topic,L2_topic,L3_topic,L4_topic,L4_value)

if ( L4_value != "" && L4_value != " " && L4_value != " [" ){

gsub(/\./,"_",L1_topic)
gsub(/\./,"_",L2_topic)
gsub(/\./,"_",L3_topic)
gsub(/\./,"_",L4_topic)

 printf("export XRAY_OPENVARS_%s_%s_%s_%s=\"%s\"\n",L1_topic,L2_topic,L3_topic,L4_topic,L4_value)
}

}


if ( $1 == "L5" ) {
# Set the current L5
L5_topic = $2
L5_value = $5

if ( L5_value != "" && L5_value != " " ){
#printf("L5_topic: %s L5_value: %s\n", L5_topic,L5_value)
#printf("L5: L1_topic: %s L2_topic: %s L3_topic: %s L4_topic: %s L5_topic: %s L5_value: %s\n",L1_topic,L2_topic,L3_topic,L4_topic,L5_topic,L5_value)

gsub(/\./,"_",L1_topic)
gsub(/\./,"_",L2_topic)
gsub(/\./,"_",L3_topic)
gsub(/\./,"_",L4_topic)
gsub(/\./,"_",L5_topic)

printf("export XRAY_OPENVARS_%s_%s_%s_%s_%s=\"%s\"\n",L1_topic,L2_topic,L3_topic,L4_topic,L5_topic,L5_value)
}

}

if ( $1 == "L6" ) {

if ( DEBUG == 1 ) { printf("node_count: %s\n", node_count) }

# Set the current L6
L6_topic = $2
L6_value = $5

if ( L4_topic ~ /^node/) {
L4_topic = sprintf("node_%s",node_count)
}


if ( L6_value != "" && L6_value != " " && NF > 4){
#printf("L6_topic: %s L6_value: %s\n", L6_topic,L6_value)
#printf("L6: L1_topic: %s L6_topic: %s L3_topic: %s L4_topic: %s L5_topic: %s L6_topic: %s L6_value: %s\n",L1_topic,L2_topic,L3_topic,L4_topic,L5_topic,L6_topic,L6_value)
#printf("L6: L1_topic: %s L6_topic: %s L3_topic: %s L4_topic: %s L6_topic: %s L6_value: %s\n",L1_topic,L2_topic,L3_topic,L4_topic,L6_topic,L6_value)

printf("export XRAY_OPENVARS_%s_%s_%s_%s_%s_%s=\"%s\"\n",L1_topic,L2_topic,L3_topic,L4_topic,L5_topic,L6_topic,L6_value)

}

}

if ( $0 ~ /svm_addr/ )  {
node_count = node_count + 1
if ( DEBUG == 1 ) { printf("node_count: %s\n", node_count) }
}



}
