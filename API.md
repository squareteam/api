# Squareteam API

## Authentification


Each user is identified by his email address.

### To register

    - Client sends identifier and password
    - Server generates SALT1 (8 bytes)
    - Server stores identifier, SALT1 and PBKDF2_SHA256(SALT1, password)

### Login

The login step is to generate a session token:

    - Client sends his identifier
    - Server generates SALT2 (8 bytes)
    - Server sends back SALT1 and SALT2
    - Client computes TOKEN = HMAC_SHA256(SALT2+PBKDF2_SHA256(SALT1, password), identifier)
    - Server computes the same TOKEN
    - Client stores TOKEN for the session
    - Server stores TOKEN and SALT2 in cache with a TTL

### Authenticated request

1. Client must generate a __BLOB__ from the request data sorted by key:
```
BLOB = "key1=value1&key2=value2&key3=value3..."
```

2. Client generates a __TIMESTAMP__

3. Client computes a __HASH__ (using his token)
```
HASH = HMAC_SHA256(TOKEN, HTTP_Method + ":" + URL_PATH + ":" + TIMESTAMP + ":" + BLOB)
```

4. Client adds the three St fields in the request HTTP header:
    - "St-Identifier": user_identifier
    - "St-Timestamp" : TIMESTAMP
    - "St-Hash"      : HASH

5. Client sends data (in the same order than the blob) with the custom HTTP header.

## API

All responses are encoded in JSON using this patern:

    {
        "data" : ...,
        "error": ...
    }


There are some global error:

- HTTP code 500; error: "api.server_error" => Internal error.
- HTTP code 400; error: "api.bad_request" => Request not correct.
- HTTP code 405; error: "api.method_not_allowed" => HTTP method not allowed.
- HTTP code 404; error: "api.not_found" => HTTP not found.
- HTTP code 401; error: "api.not_authentified" => Not identified or identification failed.


A bad request always return data = null and a HTTP code != 200.
A successfull request always return a 200 HTTP code and error = "".


### POST /register

Parameters:

    "identifier": email,
    "password"  : password

Result OK:

    null

Errors:

    - errors: "api.email_violation" (HTTP 400)

### PUT /login

Parameter:

    "identifier": email

Result OK:

    {
         "salt1": SALT1,
         "salt2": SALT2
    }

Each salt are encode in hexadecimal.


Errors:

    - errors: "api.login_fail" (HTTP 400)

### PUT /logout

**Authentification needed.**

Parameter:

    /

Result OK:

    null

Errors:

    /

### GET /user/me

**Authentification needed.**

Parameter:

    /

Result OK:

    {
        "id"   : user_id,
        "email": user_email
    }

Errors:

    /

### GET /organization/:id

**Authentification needed.**

Retrieve information about an organization.

Parameter:

    /

Result OK:

    {
        "id"  : orga_id,
        "name": orga_name
    }

Errors:

    - errors: "api.orga_not_found" (HTTP 404)

### DELETE /organization/:id

**Authentification needed.**

Delete the current organization. Require to be admin.

Parameter:

    /

Result OK:

    null

Errors:

    - errors: "api.orga_not_found" (HTTP 404)
    - errors: "api.forbidden" (HTTP 403)

### POST /organization

**Authentification needed.**

Create an organization.

Parameter:

    "name": organization_name

Result OK (HTTP 201):

    organization_id

Errors:

    - errors: "api.orga_violation" (HTTP 400)

# TODO :

### GET /user/organizations

**Authentification needed.**

Returns all organizations which the user is subscribed to.

Parameter:

    /

Result OK:

    [
        {
            "id"     : relation_id,
            "orga_id": organization_id,
            "user_id": user_id,
            "admin"  : user_is_admin
        },
    ]

Errors:

    /
