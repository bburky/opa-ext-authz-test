package example.credentials

app_credential(app_name, credential_name) = credentials {
    credentials := opa.runtime()["env"][upper(concat("_", [app_name, credential_name]))]
}
