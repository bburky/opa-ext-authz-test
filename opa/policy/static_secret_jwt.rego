package example.jwt

import data.example.jwt.secret

decode_verify(jwt) = payload {
	[valid, _, payload] := io.jwt.decode_verify(jwt, {"secret": secret})
	valid == true
}
