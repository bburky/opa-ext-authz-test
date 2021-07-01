package example.apps.podinfo

import data.example.jwt
import data.example.apps.podinfo.credentials
import input.attributes.request.http as http_request

default allow = {
    "allowed": false,
    "body": "podinfo: denied/missing JWT token",
}

token_claims = payload {
    [auth_type, auth_value] := split(http_request.headers.authorization, " ")
    auth_type == "Basic"
    [user, pass] = split(base64.decode(auth_value), ":")
    user == "JWT"
    payload := jwt.decode_verify(pass)
}

allow = response {
    token_claims

    response := {
        "allowed": true,
        # Translate one set of (JWT) creds into different creds for an upstream app
        "headers": {
            # Rewrite the Authorization header before sending it upstream
            "Authorization": encoded_credentials
        }
    }
}

encoded_credentials = authorization {
    encoded := base64.encode(concat(":", [credentials.username, credentials.password]))
    authorization := concat(" ", ["Basic", encoded])
}
