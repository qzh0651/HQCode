#!/bin/bash

#set -x

resource_avail_flag=true
log_file="/tmp/dashdb_usage.log"
#mkdir ${WORKSPACE}/report
#index_page="${WORKSPACE}/report/index.html"
index_page="/tmp/index.html"
rm $index_page
touch $index_page

## Generate k8s config file and Print cluster's info
#bx plugin install container-service -r Bluemix -f
#bx login -a https://api.ng.bluemix.net --apikey ${BM_API_KEY}
#bx cs clusters
#$(bx cs cluster-config wams-db2prod-dal13-dashdb-prod1 --export) ; echo $KUBECONFIG
#kubectl --request-timeout=5m get ns

function verify_usage {
	a=$1
	b=$2
	option=$3
	threshold=$4
	below_above="above"
	alert=""
	need=0

	if [ $b -lt $threshold ]; then
		resource_avail_flag=false
		below_above="below"
		alert="(Please raise ticket to increase $option inventory)"
		need=$(($threshold-$b))

		case $option in
			"dash_node") echo "<tr><td bgcolor="#FF0000">$option</td><td bgcolor="#FF0000">$threshold</td><td bgcolor="#FF0000">$b</td><td bgcolor="#FF0000">$a</td><td bgcolor="#FF0000">$need</td><tr>" >> $index_page;;
			"nondash_node") echo "<tr><td bgcolor="#FF0000">$option</td><td bgcolor="#FF0000">$threshold</td><td bgcolor="#FF0000">$b</td><td bgcolor="#FF0000">$a</td><td bgcolor="#FF0000">$need</td><tr>" >> $index_page;;
			"portableip") echo "<tr><td bgcolor="#FF0000">$option</td><td bgcolor="#FF0000">$threshold</td><td bgcolor="#FF0000">$b</td><td bgcolor="#FF0000">$a</td><td bgcolor="#FF0000">$need</td><tr>" >> $index_page;;
			"local") echo "<tr><td bgcolor="#FF0000">$option</td><td bgcolor="#FF0000">$threshold</td><td bgcolor="#FF0000">$b</td><td bgcolor="#FF0000">$a</td><td bgcolor="#FF0000">$need</td><tr>" >> $index_page;;
			"scratch") echo "<tr><td bgcolor="#FF0000">$option</td><td bgcolor="#FF0000">$threshold</td><td bgcolor="#FF0000">$b</td><td bgcolor="#FF0000">$a</td><td bgcolor="#FF0000">$need</td><tr>" >> $index_page;;
			"data") echo "<tr><td bgcolor="#FF0000">$option</td><td bgcolor="#FF0000">$threshold</td><td bgcolor="#FF0000">$b</td><td bgcolor="#FF0000">$a</td><td bgcolor="#FF0000">$need</td><tr>" >> $index_page;;
			"head") echo "<tr><td bgcolor="#FF0000">$option</td><td bgcolor="#FF0000">$threshold</td><td bgcolor="#FF0000">$b</td><td bgcolor="#FF0000">$a</td><td bgcolor="#FF0000">$need</td><tr>" >> $index_page;;
			"ldaphome") echo "<tr><td bgcolor="#FF0000">$option</td><td bgcolor="#FF0000">$threshold</td><td bgcolor="#FF0000">$b</td><td bgcolor="#FF0000">$a</td><td bgcolor="#FF0000">$need</td><tr>" >> $index_page;;
		esac
	else
	    case $option in
			"dash_node") echo "<tr><td>$option</td><td>$threshold</td><td>$b</td><td>$a</td><td>$need</td><tr>" >> $index_page;;
			"nondash_node") echo "<tr><td>$option</td><td>$threshold</td><td>$b</td><td>$a</td><td>$need</td><tr>" >> $index_page;;
			"portableip") echo "<tr><td>$option</td><td>$threshold</td><td>$b</td><td>$a</td><td>$need</td><tr>" >> $index_page;;
			"local") echo "<tr><td>$option</td><td>$threshold</td><td>$b</td><td>$a</td><td>$need</td><tr>" >> $index_page;;
			"scratch") echo "<tr><td>$option</td><td>$threshold</td><td>$b</td><td>$a</td><td>$need</td><tr>" >> $index_page;;
			"data") echo "<tr><td>$option</td><td>$threshold</td><td>$b</td><td>$a</td><td>$need</td><tr>" >> $index_page;;
			"head") echo "<tr><td>$option</td><td>$threshold</td><td>$b</td><td>$a</td><td>$need</td><tr>" >> $index_page;;
			"ldaphome") echo "<tr><td>$option</td><td>$threshold</td><td>$b</td><td>$a</td><td>$need</td><tr>" >> $index_page;;
		esac
	fi
	

	case $option in
		"dash_node") echo "compute resource dashdb nodes available is $below_above threshold: $threshold, avail: $2, total: $1 $alert" >> $log_file;;
		"nondash_node") echo "compute resource nondashdb nodes available is $below_above threshold: $threshold, avail: $2, total: $1 $alert" >> $log_file;;
		"portableip") echo "portable ip available is $below_above threshold: $threshold, avail: $2, total: $1 $alert" >> $log_file;;
		"local") echo "local pv available is $below_above threshold: $threshold, avail: $2, total: $1 $alert" >> $log_file;;
		"scratch") echo "scratch pv available is $below_above threshold: $threshold, avail: $2, total: $1 $alert" >> $log_file;;
		"data") echo "data pv available is $below_above threshold: $threshold, avail: $2, total: $1 $alert" >> $log_file;;
		"head") echo "head pv available is $below_above threshold: $threshold, avail: $2, total: $1 $alert" >> $log_file;;
		"ldaphome") echo "ldap pv available is $below_above threshold: $threshold, avail: $2, total: $1 $alert" >> $log_file;;
	esac
}

function create_table {
	table_name=$1

	cat > $index_page < EOF
	<table dir="ltr" width="500" border="1">
		<colgroup width="20%" />
		<colgroup id="colgroup" class="colgroup" align="center" 
				valign="middle" title="title" width="1*" 
				span="4" style="background:#ddd;" />
		<thead>
			<tr>
				<th scope="col">$1</th>
				<th scope="col">Threshold</th>
				<th scope="col">Available</th>
				<th scope="col">Total</th>
				<th scope="col">Need</th>
			</tr>
		</thead>
		<tbody>
	EOF

}



#echo "Record information about nodes in use for all namespaces:"
#kubectl get pod --all-namespaces -o wide | grep dashmpp
#kubectl get pod --all-namespaces -o wide | grep dsserver
#kubectl get pod --all-namespaces -o wide | grep aspera
#kubectl get pod --all-namespaces -o wide | grep monitor

create_table "compute resorce"

# Check compute resource usage
num_used_dashdb_nodes=$(kubectl get pods --all-namespaces -l type=dashdb | grep -v NAME | wc -l)
num_total_dashdb_nodes=$(kubectl get node -l="reserve/nodetype=dashdbmpp01-1.7.4" | grep -v NAME | wc -l)
num_avail_dashdb_nodes=$(($num_total_dashdb_nodes-$num_used_dashdb_nodes))
verify_usage $num_total_dashdb_nodes $num_avail_dashdb_nodes "dash_node" 18

##nondashdb nodes is special case, one nondash node can support up to 3 namespaces load
num_total_nondashdb_nodes=$(kubectl get node -l="reserve/nodetype=nondashdbmpp01-1.7.4" | grep -v NAME | wc -l)
num_total_ns=$(kubectl get ns | grep db2whoc | wc -l)
num_avai_nondashdb_nodes=$((($num_total_nondashdb_nodes*3-$num_total_ns)/3))
verify_usage $num_total_nondashdb_nodes $num_avai_nondashdb_nodes "nondash_node" 4

num_total_portableip=$(kubectl -n ibm-wams get portableips -o=jsonpath={..spec.type} | tr ' ' '\n' | grep Public | wc -l)
num_used_portableip=$(kubectl get ns | grep db2whoc | wc -l)
num_avail_portableip=$(kubectl get ns | grep db2whoc | wc -l)
verify_usage $num_total_portableip $num_avail_portableip "portableip" 2


echo "</tbody></table><br />" >> $index_page

create_table "Storage resorce"

# Check storage resource usage
num_avail_data=$(kubectl get pv -l storage_type=PERFORMANCE_BLOCK_STORAGE,iops=1200 | grep Available | wc -l)
num_total_data=$(kubectl get pv -l storage_type=PERFORMANCE_BLOCK_STORAGE,iops=1200 | grep -v NAME | wc -l)
verify_usage $num_total_data $num_avail_data "data" 192

num_avail_scratch=$(kubectl get pv -l storage_type=ENDURANCE_BLOCK_STORAGE,iops=2000 | grep Available | wc -l)
num_total_scratch=$(kubectl get pv -l storage_type=ENDURANCE_BLOCK_STORAGE,iops=2000 | grep -v NAME | wc -l)
verify_usage $num_total_scratch $num_avail_scratch "scratch" 40

num_avail_local=$(kubectl get pv -l storage_type=ENDURANCE_BLOCK_STORAGE,iops=5000 | grep Available | wc -l)
num_total_local=$(kubectl get pv -l storage_type=ENDURANCE_BLOCK_STORAGE,iops=5000 | grep -v NAME | wc -l)
verify_usage $num_total_local $num_avail_local "local" 32

num_avail_head=$(kubectl get pv -l storage_type=ENDURANCE_FILE_STORAGE,Iops=4,CapacityGb=500 | grep Available | wc -l)
num_total_head=$(kubectl get pv -l storage_type=ENDURANCE_FILE_STORAGE,Iops=4,CapacityGb=500 | grep -v NAME | wc -l)
verify_usage $num_total_head $num_avail_head "head" 4

num_avail_ldaphome=$(kubectl get pv -l storage_type=ENDURANCE_FILE_STORAGE,Iops=4,CapacityGb=1000 | grep Available | wc -l)
num_total_ldaphome=$(kubectl get pv -l storage_type=ENDURANCE_FILE_STORAGE,Iops=4,CapacityGb=1000 | grep -v NAME | wc -l)
verify_usage $num_total_ldaphome $num_avail_ldaphome "ldaphome" 4

echo "</tbody></table>" >> $index_page

echo "<p>Sample ticket for requesting more resource from wams: https://github.ibm.com/aps-container-service/wdp-ams-devops/issues/157 </p>" >> $index_page

echo "==========================================================================================================================="
echo "Print compute and storage resource usage:"
cat $log_file
echo "==========================================================================================================================="
rm $log_file

if [ $resource_avail_flag = false ]; then
	exit 1
fi







