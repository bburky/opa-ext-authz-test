package example.apps.httpbin

import data.example.jwt
import input.attributes.request.http as http_request

default allow = {
    "allowed": false,
    "body": "httpbin: denied/missing JWT token",
}

token_claims = payload {
    [auth_type, bearer_token] := split(http_request.headers.authorization, " ")
    auth_type == "Bearer"
    payload := jwt.decode_verify(bearer_token)
}

allow {
    action_allowed
}

# Provide an error message when the path is denied but the token is still valid
allow = response {
    not action_allowed
    token_claims

    response := {
        "allowed": false,
        "body": "httpbin: access to path denied"
    }
}

action_allowed {
    startswith(http_request.path, base64url.decode(token_claims.path))
}
