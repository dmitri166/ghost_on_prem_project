package ghost_platform.terraform

# Policy to ensure all resources have required tags
deny[msg] {
    input.type == "resource"
    not has_required_tags(input.values.tags)
    msg := sprintf("Resource %s must have required tags: name, environment, and managed-by", [input.name])
}

# Policy to ensure no hardcoded secrets in Terraform
deny[msg] {
    input.type == "resource"
    contains_sensitive_key(input.values)
    msg := sprintf("Resource %s contains potentially sensitive data that should not be hardcoded", [input.name])
}

# Policy to ensure encryption is enabled where applicable
deny[msg] {
    input.type == "resource"
    should_be_encrypted(input.type, input.name)
    not is_encrypted(input.values)
    msg := sprintf("Resource %s should have encryption enabled", [input.name])
}

# Policy to ensure network security
deny[msg] {
    input.type == "resource"
    is_network_resource(input.type)
    not has_security_configuration(input.values)
    msg := sprintf("Network resource %s must have proper security configuration", [input.name])
}

# Helper functions
has_required_tags(tags) {
    tags.name
    tags.environment
    tags.managed-by
}

contains_sensitive_key(values) {
    contains(lower(object.keys(values)[i]), "password")
    contains(lower(object.keys(values)[i]), "secret")
    contains(lower(object.keys(values)[i]), "key")
    contains(lower(object.keys(values)[i]), "token")
}

should_be_encrypted(resource_type, resource_name) {
    contains(lower(resource_type), "storage")
    contains(lower(resource_type), "database")
    contains(lower(resource_type), "disk")
}

is_encrypted(values) {
    values.encrypted == true
    values.encryption_enabled == true
}

is_network_resource(resource_type) {
    contains(lower(resource_type), "security_group")
    contains(lower(resource_type), "network")
    contains(lower(resource_type), "firewall")
}

has_security_configuration(values) {
    values.security_group_ids
    values.network_acl_ids
    values.firewall_rules
}
