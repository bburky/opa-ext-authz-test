package example.jwks_jwt

import data.example.jwks_jwt.jwks_url

# TODO: I think this works.

jwks_request(url) = jwks {
	jwks := http.send({
		"url": url,
		"method": "GET",
		"force_cache": true,
		"force_cache_duration_seconds": 3600, # Cache response for an hour
	})
}

jwks = jwks_request(jwks_url).body

decode_verify(jwt, aud) = payload {
	[valid, _, payload] := io.jwt.decode_verify(jwt, {
		"cert": json.marshal(jwks),
		"aud": aud,
	})

	valid == true
}
