package aetheris.authz

import future.keywords.in
import future.keywords.if

# ─────────────────────────────────────────────
# MAIN DECISION POINT
# allow = true  → request is permitted
# ─────────────────────────────────────────────
default allow := false

allow if {
    token_valid
    role_permitted
}

# ─────────────────────────────────────────────
# TOKEN VALIDATION
# ─────────────────────────────────────────────
token_valid if {
    input.token != null
    input.token != ""
    not token_expired
}

token_expired if {
    now := time.now_ns() / 1000000000
    input.token_claims.exp < now
}

# ─────────────────────────────────────────────
# ROLE-BASED ACCESS CONTROL (RBAC)
# ─────────────────────────────────────────────
permission_matrix := {
    "backend": {
        "GET":    ["service-reader", "service-writer", "aetheris-admin"],
        "POST":   ["service-writer", "aetheris-admin"],
        "PUT":    ["service-writer", "aetheris-admin"],
        "DELETE": ["aetheris-admin"]
    }
}

user_roles := input.token_claims.roles

role_permitted if {
    required := permission_matrix[input.service][input.method]
    some role in user_roles
    role in required
}
