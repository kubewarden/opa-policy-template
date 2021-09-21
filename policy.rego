package kubernetes.admission

deny[msg] {
	input.request.object.spec.type == "NodePort"
	msg := "Service of type NodePort are not allowed"
}
