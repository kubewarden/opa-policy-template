package kubernetes.admission

request_service_clusterip = {"request": {"object": {"spec": {"type": "ClusterIp"}}}}

request_service_nodeport = {"request": {"object": {"spec": {"type": "NodePort"}}}}

test_accept {
	r = request_service_clusterip
	res = deny with input as r
	count(res) = 0
}

test_reject {
	r = request_service_nodeport
	res = deny with input as r
	count(res) = 1
}
