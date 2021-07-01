package envoy.authz

import data.example.apps

import input.attributes.destination.principal

prinicpal_match(pattern) = response {
    response := glob.match(pattern, ["/"], principal)
}

default allow = {
    "allowed": false,
    "body": "no matching app",
}

allow = response {
    app = apps[_]
    app.enabled
    prinicpal_match(app.principals[_])
    response := app.allow
}
