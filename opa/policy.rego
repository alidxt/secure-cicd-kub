package kubernetes.admission

deny[msg] {
  input.kind.kind == "Pod"
  some i
  container := input.request.object.spec.containers[i]
  not container.securityContext
  msg := sprintf("container %v has no securityContext and may run as root", [container.name])
}
