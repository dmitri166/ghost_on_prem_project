package ghost_platform.kubernetes

# Policy to ensure all pods have resource limits
deny[msg] {
    input.kind == "Pod"
    not has_resource_limits(input.spec.containers[_])
    msg := "Pod must have resource limits defined for all containers"
}

# Policy to ensure no privileged containers
deny[msg] {
    input.kind == "Pod"
    input.spec.containers[_].securityContext.privileged == true
    msg := "Pod must not run privileged containers"
}

# Policy to ensure read-only root filesystem
deny[msg] {
    input.kind == "Pod"
    not input.spec.containers[_].securityContext.readOnlyRootFilesystem == true
    msg := "Pod containers should have read-only root filesystem"
}

# Policy to ensure non-root user
deny[msg] {
    input.kind == "Pod"
    input.spec.containers[_].securityContext.runAsUser == 0
    msg := "Pod containers must not run as root user"
}

# Policy to ensure liveness and readiness probes
deny[msg] {
    input.kind == "Pod"
    container := input.spec.containers[_]
    not has_health_checks(container)
    msg := "Pod containers should have liveness and readiness probes"
}

# Policy to ensure network policies
deny[msg] {
    input.kind == "Namespace"
    not has_network_policy(input.metadata.name)
    msg := "Namespace should have network policies defined"
}

# Policy to ensure RBAC is configured
deny[msg] {
    input.kind == "Pod"
    input.spec.serviceAccountName == "default"
    msg := "Pod should use a dedicated service account, not default"
}

# Helper functions
has_resource_limits(container) {
    container.resources.limits.cpu
    container.resources.limits.memory
}

has_health_checks(container) {
    container.livenessProbe
    container.readinessProbe
}

has_network_policy(namespace) {
    # This would need to be implemented with actual network policy checking
    true
}
