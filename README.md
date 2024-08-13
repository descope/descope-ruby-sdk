# Descope SDK for Ruby

The Descope SDK for Ruby provides convenient access to the Descope user management and authentication API
for a backend written in Ruby. You can read more on the [Descope Website](https://descope.com).

## Requirements

The SDK supports Ruby 3.3.0 and above.

## Installing the SDK

Install the package with:

```bash
gem install descope
```

## Setup

A Descope `Project ID` is required to initialize the SDK. Find it on the
[project page in the Descope Console](https://app.descope.com/settings/project).

```ruby
require 'descope'

descope_client = Descope::Client.new(
  {
    project_id: '<project_id>',
    management_key: ENV['MGMT_KEY']
  }
)
```

### Important Logging note
You may pass `log_level: 'debug'` to the client config or use `DESCOPE_LOG_LEVEL` env var.
Be aware that only the management key is truncated, and the JWT responses are printed on debug

Do not run with log level debug on Production!


## Authentication Methods
These sections show how to use the SDK to perform various authentication/authorization functions:

1. [OTP Authentication](#otp-authentication)
2. [Magic Link](#magic-link)
3. [Enchanted Link](#enchanted-link)
4. [OAuth](#oauth)
5. [SSO (SAML / OIDC)](#sso-saml-oidc)
6. [TOTP Authentication](#totp-authentication)
7. [Passwords](#passwords)
8. [Session Validation](#session-validation)
9. [Roles & Permission Validation](#roles-permission-validation)
10. [Tenant selection](#tenant-selection)
11. [Signing Out](#signing-out)
12. [History](#history)

## API Management Function

These sections show how to use the SDK to perform permission and user management functions. You will need to create an instance of `DescopeClient` by following the [Setup](#setup-1) guide, before you can use any of these methods:

1. [Manage Tenants](#manage-tenants)
2. [Manage Users](#manage-users)
3. [Manage Access Keys](#manage-access-keys)
4. [Manage SSO Setting](#manage-sso-setting)
5. [Manage Permissions](#manage-permissions)
6. [Manage Roles](#manage-roles)
7. [Query SSO Groups](#query-sso-groups)
8. [Manage Flows](#manage-flows-and-theme)
9. [Manage JWTs](#manage-jwts)
10. [Impersonate](#impersonate)
11. [Embedded links](#embedded-links)
12. [Audit](#audit)
13. [Manage ReBAC Authz](#manage-rebac-authz)
14. [Manage Project](#manage-project)
15. [Manage SSO Applications](#manage-sso-applications)

If you wish to run any of our code examples and play with them, check out our [Code Examples](#code-examples) section.

If you're performing end-to-end testing, check out the [Utils for your end to end (e2e) tests and integration tests](#utils-for-your-end-to-end-e2e-tests-and-integration-tests) section. You will need to use the `DescopeClient` object created under [Setup](#setup-1) guide.

For rate limiting information, please confer to the [API Rate Limits](#api-rate-limits) section.

### OTP Authentication

Send a user a one-time password (OTP) using your preferred delivery method (Email/SMS/Voice call). An email address or phone number must be provided accordingly.

The user can either `sign up`, `sign in` or `sign up or in`

```ruby
# Every user must have a login ID. All other user information is optional
# For sign up either phone or email is required
email = 'desmond@descope.com'
user = {'name': 'Desmond Copeland', 'phone': '212-555-1234', 'email': email}
masked_address = descope_client.otp_sign_up(method: Descope::Mixins::Common::DeliveryMethod::EMAIL, login_id: 'someone@example.com', user: user)
```

The user will receive a code using the selected delivery method. Verify that code using:

```ruby
jwt_response = descope_client.otp_verify_code(
    method: Descope::Mixins::Common::DeliveryMethod::EMAIL, login_id: 'someone@example.com', code: '123456'
)
session_token = jwt_response[Descope::Mixins::Common::SESSION_TOKEN_NAME].fetch('jwt')
refresh_token = jwt_response[Descope::Mixins::Common::REFRESH_SESSION_TOKEN_NAME].fetch('jwt')
```

The session and refresh JWTs should be returned to the caller, and passed with every request in the session. Read more on [session validation](#session-validation)

### Magic Link

Send a user a Magic Link using your preferred delivery method (Email / SMS).
The Magic Link will redirect the user to page where the token needs to be verified.
This redirection can be configured in code, or generally in the [Descope Console](https://app.descope.com/settings/authentication/magiclink)

The user can either `sign up`, `sign in` or `sign up or in`

```ruby
masked_address = descope_client.magiclink_sign_up_or_in(
    method: Descope::Mixins::Common::DeliveryMethod::EMAIL,
    login_id: 'desmond@descope.com',
    uri: 'https://myapp.com/verify-magic-link', # Set redirect URI here or via console
)
```

To verify a magic link, your redirect page must call the validation function on the token (`t`) parameter (`https://your-redirect-address.com/verify?t=<token>`):

```ruby
jwt_response = descope_client.magiclink_verify_token('token-here')
session_token = jwt_response[Descope::Mixins::Common::SESSION_TOKEN_NAME].fetch('jwt')
refresh_token = jwt_response[Descope::Mixins::Common::REFRESH_SESSION_TOKEN_NAME].fetch('jwt')
```

The session and refresh JWTs should be returned to the caller, and passed with every request in the session. Read more on [session validation](#session-validation)

### Enchanted Link

Using the Enchanted Link APIs enables users to sign in by clicking a link
delivered to their email address. The email will include 3 different links,
and the user will have to click the right one, based on the 2-digit number that is
displayed when initiating the authentication process.

This method is similar to [Magic Link](#magic-link) but differs in two major ways:

- The user must choose the correct link out of the three, instead of having just one
  single link.
- This supports cross-device clicking, meaning the user can try to log in on one device,
  like a computer, while clicking the link on another device, for instance a mobile phone.

The Enchanted Link will redirect the user to a page where the token needs to be verified.
This redirection can be configured in code per request, or set globally in the [Descope Console](https://app.descope.com/settings/authentication/enchantedlink).

The user can either `sign up`, `sign in` or `sign up or in`

```ruby
res = descope_client.enchanted_link_sign_up_or_in(
    login_id: 'someone@example.com',
    uri: 'https://myapp.com/verify-enchanted-link', # Set redirect URI here or via console
)
link_identifier = res['linkId'] # Show the user which link they should press in their email
pending_ref = res['pendingRef'] # Used to poll for a valid session
masked_email = res['maskedEmail'] # The email that the message was sent to in a masked format
```

After sending the link, you must poll to receive a valid session using the `pending_ref` from
the previous step. A valid session will be returned only after the user clicks the right link.

```ruby

pending_ref = res['pendingRef']

def poll_for_session(descope_client, pending_ref)
  max_tries = 15
  i = 0
  done = false
  while !done && i < max_tries
    begin
      i += 1
      puts 'waiting 4 seconds for session to be created...'
      sleep(4)
      print '.'
      jwt_response = descope_client.enchanted_link_get_session(pending_ref)
      done = true
    rescue Descope::AuthException, Descope::Unauthorized => e
      puts "Failed pending session, err: #{e}"
      nil
    end

    if jwt_response
      puts "jwt_response: #{jwt_response}"
      refresh_token = jwt_response[Descope::Mixins::Common::REFRESH_SESSION_TOKEN_NAME]['jwt']

      puts "refresh_token: #{refresh_token}"
      puts :'Done logging out!'
      descope_client.sign_out(refresh_token)
      puts 'User logged out'
      done = true
    end
  end
end

poll_for_session(descope_client, pending_ref)
```

To verify an enchanted link, your redirect page must call the validation function on the token (`t`) parameter (`https://your-redirect-address.com/verify?t=<token>`). Once the token is verified, the session polling will receive a valid `jwt_response`.

```ruby
begin
    descope_client.enchanted_link_verify_token(token=token)
    # Token is valid
rescue AuthException => e
  # Token is invalid
  puts "Failed to verify token, err: #{e}"
end
```

The session and refresh JWTs should be returned to the caller, and passed with every request in the session. Read more on [session validation](#session-validation)

### OAuth

Users can authenticate using their social logins, using the OAuth protocol. Configure your OAuth settings on the [Descope console](https://app.descope.com/settings/authentication/social). To start a flow call:

```ruby

descope_client.oauth_start(
    provider: 'google', # Choose an oauth provider out of the supported providers
    return_url: 'https://my-app.com/handle-oauth', # Can be configured in the console instead of here
)
```

The user will authenticate with the authentication provider, and will be redirected back to the redirect URL, with an appended `code` HTTP URL parameter. Exchange it to validate the user:

```ruby
jwt_response = descope_client.oauth_exchange_token(code)
session_token = jwt_response[Descope::Mixins::Common::SESSION_TOKEN_NAME].fetch('jwt')
refresh_token = jwt_response[Descope::Mixins::Common::REFRESH_SESSION_TOKEN_NAME].fetch('jwt')
```

The session and refresh JWTs should be returned to the caller, and passed with every request in the session. Read more on [session validation](#session-validation)

### SSO (SAML / OIDC)

Users can authenticate to a specific tenant using SAML or Single Sign On. Configure your SSO/SAML settings on the [Descope console](https://app.descope.com/settings/authentication/sso). To start a flow call:

```ruby

descope_client.saml_sign_in(
    tenant: 'my-tenant-ID', # Choose which tenant to log into
    return_url: 'https://my-app.com/handle-saml', # Can be configured in the console instead of here
    prompt: 'custom prompt here'
)
```

The user will authenticate with the authentication provider configured for that tenant, and will be redirected back to the redirect URL, with an appended `code` HTTP URL parameter. Exchange it to validate the user:

```ruby
jwt_response = descope_client.saml_exchange_token(code)
session_token = jwt_response[Descope::Mixins::Common::SESSION_TOKEN_NAME].fetch('jwt')
refresh_token = jwt_response[Descope::Mixins::Common::REFRESH_SESSION_TOKEN_NAME].fetch('jwt')
```

The session and refresh JWTs should be returned to the caller, and passed with every request in the session. Read more on [session validation](#session-validation)

### TOTP Authentication

The user can authenticate using an authenticator app, such as Google Authenticator.
Sign up like you would use any other authentication method. The sign-up response
will then contain a QR code `image` that can be displayed to the user to scan using
their mobile device camera app, or the user can enter the `key` manually or click
on the link provided by the `provisioning_url`.

Existing users can add TOTP using the `update` function.

```ruby
# Every user must have a login ID. All other user information is optional
email = 'desmond@descope.com'
user = {name: 'Desmond Copeland', phone: '212-555-1234', email: 'someone@example.com'}
totp_response = descope_client.totp_sign_up(method: Descope::Mixins::Common::DeliveryMethod::EMAIL, login_id: 'someone@example.com', user: user)

# Use one of the provided options to have the user add their credentials to the authenticator
provisioning_url = totp_response['provisioningURL']
image = totp_response['image']
key = totp_response['key']
```

There are 3 different ways to allow the user to save their credentials in
their authenticator app - either by clicking the provisioning URL, scanning the QR
image or inserting the key manually. After that, signing in is done using the code
the app produces.

```ruby
jwt_response = descope_client.totp_sign_in_code(
    login_id: 'someone@example.com',
    code: '123456' # Code from authenticator app
)
session_token = jwt_response[Descope::Mixins::Common::SESSION_TOKEN_NAME].fetch('jwt')
refresh_token = jwt_response[Descope::Mixins::Common::REFRESH_SESSION_TOKEN_NAME].fetch('jwt')
```

The session and refresh JWTs should be returned to the caller, and passed with every request in the session. Read more on [session validation](#session-validation)

### Passwords

The user can also authenticate with a password, though it's recommended to
prefer passwordless authentication methods if possible. Sign up requires the
caller to provide a valid password that meets all the requirements configured
for the [password authentication method](https://app.descope.com/settings/authentication/password) in the Descope console.

```ruby
# Every user must have a login_id and a password. All other user information is optional
login_id = 'desmond@descope.com'
password = 'qYlvi65KaX'
user = {
    name: 'Desmond Copeland',
    email: login_id,
}
jwt_response = descope_client.password_sign_up(login_id:, password:, user:)
session_token = jwt_response[Descope::Mixins::Common::SESSION_TOKEN_NAME].fetch('jwt')
refresh_token = jwt_response[Descope::Mixins::Common::REFRESH_SESSION_TOKEN_NAME].fetch('jwt')
```

The user can later sign in using the same login_id and password.

```ruby
jwt_response = descope_client.password_sign_in(login_id:, password:)
session_token = jwt_response[Descope::Mixins::Common::SESSION_TOKEN_NAME].fetch('jwt')
refresh_token = jwt_response[Descope::Mixins::Common::REFRESH_SESSION_TOKEN_NAME].fetch('jwt')
```

The session and refresh JWTs should be returned to the caller, and passed with every request in the session. Read more on [session validation](#session-validation)

In case the user needs to update their password, one of two methods are available: Resetting their password or replacing their password

**Changing Passwords**

_NOTE: send_reset will only work if the user has a validated email address. Otherwise, password reset prompts cannot be sent._

In the [password authentication method](https://app.descope.com/settings/authentication/password) in the Descope console, it is possible to define which alternative authentication method can be used in order to authenticate the user, in order to reset and update their password.

```ruby
# Start the reset process by sending a password reset prompt. In this example we'll assume
# that magic link is configured as the reset method. The optional redirect URL is used in the
# same way as in regular magic link authentication.
login_id = 'desmond@descope.com'
redirect_url = 'https://myapp.com/password-reset'
descope_client.password_reset(login_id:, redirect_url:)
```

The magic link, in this case, must then be verified like any other magic link (see the [magic link section](#magic-link) for more details). However, after verifying the user, it is expected
to allow them to provide a new password instead of the old one. Since the user is now authenticated, this is possible via:

```ruby
# The refresh token is required to make sure the user is authenticated.
err = descope_client.password_update(login_id:, new_password: 'xyz123', token: 'token-here')
```

`update` can always be called when the user is authenticated and has a valid session.

Alternatively, it is also possible to replace an existing active password with a new one.

```ruby
# Replaces the user's current password with a new one
jwt_response = descope_client.password_replace(login_id: 'login', old_password: '1234', new_password: '4567')
session_token = jwt_response[Descope::Mixins::Common::SESSION_TOKEN_NAME].fetch('jwt')
refresh_token = jwt_response[Descope::Mixins::Common::REFRESH_SESSION_TOKEN_NAME].fetch('jwt')
```

### Session Validation

Every secure request performed between your client and server needs to be validated. The client sends
the session and refresh tokens with every request, and they are validated using one of the following:

```ruby
# Validate the session. Will raise if expired
begin
    jwt_response = descope_client.validate_session('session_token')
rescue AuthException => e
    # Session expired
end

# If validate_session raises an exception, you will need to refresh the session using
jwt_response = descope_client.refresh_session('refresh_token')

# Alternatively, you could combine the two and
# have the session validated and automatically refreshed when expired
jwt_response = descope_client.validate_and_refresh_session('session_token', 'refresh_token')
```

Choose the right session validation and refresh combination that suits your needs.

Note: all those validation apis can receive an optional 'audience' parameter that should be provided when using jwt that has the 'aud' claim.

Refreshed sessions return the same response as is returned when users first sign up / log in,
containing the session and refresh tokens, as well as all the JWT claims.
Make sure to return the tokens from the response to the client, or updated the cookie if you're using it.

Usually, the tokens can be passed in and out via HTTP headers or via a cookie.
The implementation can defer according to your framework of choice. See our [examples](#code-examples) for a few examples.

If Roles & Permissions are used, validate them immediately after validating the session. See the [next section](#roles-permission-validation)
for more information.

### Roles Permission Validation

When using Roles & Permission, it's important to validate the user has the required
authorization immediately after making sure the session is valid. Taking the `jwt_response`
received by the [session validation](#session-validation), call the following functions:

For multi-tenant uses:

```ruby
# You can validate specific permissions
valid_permissions = descope_client.validate_tenant_permissions(
    jwt_response: 'resp', tenant: 'my-tenant-ID', permissions: ['Permission to validate']
)

unless valid_permissions
    # Deny access
end

# Or validate roles directly
valid_roles = descope_client.validate_tenant_roles(
    jwt_response: 'resp', tenant: 'my-tenant-ID', roles: ['Role to validate']
)

unless valid_roles
    # Deny access
end
```

When not using tenants use:

```ruby
# You can validate specific permissions
valid_permissions = descope_client.validate_permissions(
    jwt_response: 'resp', permissions: ['Permission to validate']
)
unless valid_permissions
    # Deny access
end

# Or validate roles directly
valid_roles = descope_client.validate_roles(
    jwt_response: 'resp', roles: ['Role to validate']
)

unless valid_roles
    # Deny access
end
```

### Tenant selection
For a user that has permissions to multiple tenants, you can set a specific tenant as the current selected one
This will add an extra attribute to the refresh JWT and the session JWT with the selected tenant ID

```ruby
tenant_id = 't1'
jwt_response = descope_client.select_tenant(tenant_id:, refresh_token: 'refresh_token')
```

### Signing Out

You can log out a user from an active session by providing their `refresh_token` for that session.
After calling this function, you must invalidate or remove any cookies you have created.

```ruby
descope_client.sign_out('refresh_token')
```

It is also possible to sign the user out of all the devices they are currently signed in with. Calling `logout_all` will
invalidate all user's refresh tokens. After calling this function, you must invalidate or remove any cookies you have created.

```ruby
descope_client.sign_out_all('refresh_token')
```

### History
You can get the current session user history.
The request requires a valid refresh token.

```ruby
users_history_resp = descope_client.history(refresh_token)
for user_history in users_history_resp:
    # Do something
```

## Management API

It is very common for some form of management or automation to be required. These can be performed
using the management API. Please note that these actions are more sensitive as they are administrative
in nature. Please use responsibly.

### Setup

To use the management API you'll need a `Management Key` along with your `Project ID`.
Create one in the [Descope Console](https://app.descope.com/settings/company/managementkeys).

```ruby
require 'descope'

# Initialized after setting the DESCOPE_PROJECT_ID and the DESCOPE_MANAGEMENT_KEY env vars
project_id = '<project_id>'
client = Descope::Client.new(
        {
                project_id: project_id,
                management_key: ENV['MGMT_KEY']
        }
)

```

### Manage Tenants

You can create, update, delete or load tenants:

```ruby
# You can optionally set your own ID when creating a tenant
descope_client.create_tenant(
        name: 'My First Tenant',
        id: 'my-custom-id', # This is optional.
        self_provisioning_domains: ['domain.com'],
        custom_attributes: { 'attribute-name': 'value' },
)

# Update will override all fields as is. Use carefully.
descope_client.update_tenant(
        id: 'my-custom-id',
        name: 'My First Tenant',
        self_provisioning_domains: %w[domain.com another-domain.com],
        custom_attributes: { 'attribute-name': 'value' },
)

# Tenant deletion cannot be undone. Use carefully.
descope_client.delete_tenant('my-custom-id')

# Load tenant by id
tenant_resp = descope_client.load_tenant('my-custom-id')

# Load all tenants
tenants_resp = descope_client.load_all_tenants
tenants = tenants_resp['tenants']
tenants.each do |tenant|
  # Do something
end

# search all tenants
tenants_resp = descope_client.search_all_tenants(ids: ['id1'], names: ['name1'], custom_attributes: { 'k1': 'v1' }, self_provisioning_domains: ['spd1'])
tenants = tenants_resp['tenants']
tenants.each do |tenant|
  # Do something
  tenant_id = tenant['id']
end
```

### Manage Users

You can create, update, delete or load users, as well as setting new password, expire password and search according to filters:

```ruby
# A user must have a login ID, other fields are optional.
# Roles should be set directly if no tenants exist, otherwise set
# on a per-tenant basis.
descope_client.create_user(
        login_id: 'desmond@descope.com',
        email: 'desmond@descope.com',
        display_name: 'Desmond Copeland',
        user_tenants: [
                AssociatedTenant('my-tenant-id', ['role-name1']),
        ],
)

# Alternatively, a user can be created and invited via an email message.
# Make sure to configure the invite URL in the Descope console prior to using this function,
# and that an email address is provided in the information.
associated_tenants = [{ tenant_id: 'tenant_id1', role_names: %w[role_name1 role_name2] }]
descope_client.invite_user(
        login_id: 'desmond@descope.com',
        email: 'desmond@descope.com',
        display_name: 'Desmond Copeland',
        user_tenants: client.associated_tenants_to_hash_array(associated_tenants),
)

# Update will override all fields as is. Use carefully.
descope_client.update_user(
        login_id: 'desmond@descope.com',
        email: 'desmond@descope.com',
        display_name: 'Desmond Copeland',
        user_tenants: client.associated_tenants_to_hash_array(associated_tenants)
)

# Patch all user attribute in one api call
descope_client.patch_user(
        login_id: 'desmond@descope.com',
        email: 'desmond@descope.com',
        given_name: 'Desmond',
        family_name: 'Copeland',
        display_name: 'Desmond Copeland',
        user_tenants: client.associated_tenants_to_hash_array(associated_tenants)
)

# Update explicit data for a user rather than overriding all fields
descope_client.update_login_id(
        login_id: 'desmond@descope.com',
        new_login_id: 'bane@descope.com'
)

descope_client.update_phone(
        login_id: 'desmond@descope.com',
        phone: '+18005551234',
        verified: true
)

descope_client.user_remove_tenant_roles(
        login_id: 'desmond@descope.com',
        tenant_id: 'my-tenant-id',
        role_names: ['role-name1']
)

# User deletion cannot be undone. Use carefully.
descope_client.delete_user('desmond@descope.com')

# Load specific user
user_resp = descope_client.load_user('desmond@descope.com')
user = user_resp['user']

# If needed, users can be loaded using the user ID as well
user_resp = descope_client.load_by_user_id('<user-id>')
user = user_resp['user']

# Logout user from all devices by login ID
descope_client.logout_user('<login-id>')

# Logout user from all devices by user ID
descope_client.logout_user_by_id('<user-id>')

# Search all users, optionally according to tenant and/or role filter
# results can be paginated using the limit and page parameters
users_resp = descope_client.search_all_users(tenant_ids = ['my-tenant-id'])
users = users_resp['users']
users.each do |user|
  # Do something
end
```

#### Set or Expire User Password

You can set a new active password for a user, which they can then use to sign in. You can also set a temporary
password that the user will be forced to change on the next login.

```ruby
# Set a user's temporary password
descope_client.set_temporary_password(login_id: '<login-id>', password:  '<some-password>');

# Set a user's password
descope_client.set_active_password(login_id: '<login-id>', password:  '<some-password>');

# Or alternatively, expire a user password
descope_client.expire_password('<login-id>')
```

### Manage Access Keys

You can create, update, delete or load access keys, as well as search according to filters:

```ruby
# An access key must have a name and expiration, other fields are optional.
# Roles should be set directly if no tenants exist, otherwise set
# on a per-tenant basis. If custom_claims supplied they will be presented on the jwt.
# If customClaims is supplied, then those claims will be present in the JWT returned by calls to ExchangeAccessKey.
associated_tenants = [{ tenant_id: 'tenant_id1', role_names: %w[role_name1 role_name2] }]
create_resp = descope_client.create_access_key(
    name: 'name',
    expire_time: 1677844931,
    key_tenants: associated_tenants,
	custom_claims: {'k1': 'v1'}
)
key = create_resp['key']
cleartext = create_resp['cleartext'] # make sure to save the returned cleartext securely. It will not be returned again.

# Load a specific access key
access_key_resp = descope_client.load_access_key('key-id')
access_key = access_key_resp['key']

# Search all access keys, optionally according to a tenant filter
keys_resp = descope_client.search_all_access_keys(['my-tenant-id'])
keys = keys_resp['keys']
keys.each do |key|
        # Do something with key
end

# Update will rename the access key
descope_client.update_access_key(
    id: 'key-id',
    name: 'new name'
)

# Access keys can be deactivated to prevent usage. This can be undone using 'activate'.
descope_client.deactivate_access_key('key-id')

# Disabled access keys can be activated once again.
descope_client.activate_access_key('key-id')

# Access key deletion cannot be undone. Use carefully.
descope_client.delete_access_key('key-id')

```

### Manage SSO SAML Settings

You can manage SSO settings and map SSO group roles and user attributes.

```ruby
# You can get SSO SAML settings for a tenant
sso_settings_res = descope_client.sso_get_settings('tenant-id')  

# You can configure SSO SAML settings manually by setting the required fields directly
descope_client.configure_sso_saml_metadata(
    tenant_id: '123', # Which tenant this configuration is for
    settings: {
      name: 'test',
      clientId: 'test',
      scope: ['test'],
      userAttrMapping: {
              loginId: 'test',
              username: 'test',
              name: 'test'
      },
      callbackDomain: 'test'   
    },
    redirect_url: 'https://your.domain.com', # Global redirection after successful authentication
    domain: 'tenant-users.com' # Users authentication with this domain will be logged in to this tenant
)
```


### Manage Permissions

You can create, update, delete or load permissions:

```ruby
# You can optionally set a description for a permission.
descope_client.create_permission(
    name:'My Permission',
    description:'Optional description to briefly explain what this permission allows.'
)

# Update will override all fields as is. Use carefully.
descope_client.mgmt.update_permission(
    name: 'My Permission',
    new_name: 'My Updated Permission',
    description: 'A revised description'
)

# Permission deletion cannot be undone. Use carefully.
descope_client.mgmt.permission.delete('My Updated Permission')

# Load all permissions
permissions_resp = descope_client.load_all_permissions
permissions = permissions_resp['permissions']
    permissions.each do |permission|
        # Do something
    end
```

### Manage Roles

You can create, update, delete or load roles:

```ruby
# You can optionally set a description and associated permission for a roles.
descope_client.create_role(
    name: 'My Role',
    description: 'Optional description to briefly explain what this role allows.',
    permission_names: ['My Updated Permission'],
    tenant_id: 'Optionally scope this role for this specific tenant. If left empty, the role will be available to all tenants.'
)

# Update will override all fields as is. Use carefully.
descope_client.update_role(
    name: 'My Role',
    new_name: 'My Updated Role',
    description: 'A revised description',
    permission_names: ['My Updated Permission', 'Another Permission'],
    tenant_id: 'The tenant ID to which this role is associated, leave empty, if role is a global one'
)

# Role deletion cannot be undone. Use carefully.
descope_client.delete_role(name: 'My Updated Role',  tenant_id: 'The tenant ID to which this role is associated, leave empty, if role is a global one')

# Load all roles
roles_resp = descope_client.load_all_roles
roles = roles_resp['roles']
    roles.each do |role|
      # Do something
    end
# 
```

# Search roles

```ruby
roles_resp = descope_client.search_roles(
  names: %w[role1 role2], # Search for roles with the names 'role1' and 'role2'
  role_name_like: 'role', # Search for roles that contain the string 'role'
  tenant_ids: %w[tenant1 tenant2], # Search for roles that are associated with the tenants 'tenant1' and 'tenant2'
  permission_names: %w[permission1 permission2] # Search for roles that have the permissions 'permission1' and 'permission2'
)

roles = roles_resp['roles']
roles.each do |role|
  # Do something
end
```

### Manage Flows and Theme

You can list your flows and also import and export flows and screens, or the project theme:

```ruby
# List all project flows
flows_resp = descope_client.list_or_search_flows()
puts("Total number of flows: #{flows_resp['total']}")
flows = flows_resp['flows']
flows.each do |flow|
  # Do something
end

# Export a selected flow by id for the flow and matching screens.
exported_flow_and_screens = descope_client.export_flow('sign-up-or-in')

# Import a given flow and screens to the flow matching the id provided.
imported_flow_and_screens = descope_client.import_flow(
        flow_id: 'sign-up-or-in',
        flow: {},
        screens: []
)

# Export your project theme.
exported_theme = descope_client.export_theme

# Import a theme to your project.
imported_theme = descope_client.import_theme('theme')

```

### Query SCIM Groups

You can query SCIM groups:

```ruby
# Load all groups for a given tenant id
groups_resp = descope_client.scim_search_groups(
        group_id: 'group_id',
        display_name: 'display_name',
        members: ['members'],
        external_id: 'external_id',
        excluded_attributes: { abc: '123' }
)

# Load SCIM group
group = descope_client.scim_load_group(
    tenant_id: 'tenant-id',
    group_id: 'group-id'
)

# Load SCIM group members
group = descope_client.scim_create_group(
        group_id: 'group_id',
        display_name: 'display_name',
        members: ['members'],
        external_id: 'external_id',
        excluded_attributes: { abc: '123' }
)
```

### Manage JWTs

You can add custom claims to a valid JWT.

```ruby
updated_jwt = descope_client.update_jwt(
    jwt: 'original-jwt',
    custom_claims: {
        'custom-key1': 'custom-value1',
        'custom-key2': 'custom-value2'
    },
)
```

# Note 1: The generate code/link functions, work only for test users, will not work for regular users.

# Note 2: In case of testing sign-in / sign-up operations with test users, need to make sure to generate the code prior calling the sign-in / sign-up operations.

### Embedded links

Embedded links can be created to directly receive a verifiable token without sending it.

This token can then be verified using the magic link 'verify' function, either directly or through a flow.

```ruby
token = descope_client.generate_embedded_link(login_id: 'desmond@descope.com', custom_claims: {'key1':'value1'})
```

### Audit

You can perform an audit search for either specific values or full-text across the fields. Audit search is limited to the last 30 days.
Below are some examples. For a full list of available search criteria options, see the function documentation.

```ruby
# Full text search on last 10 days
audits = descope_client.audit_search(
        no_tenants: true,
        actions: ['LoginSucceed'],
        user_ids: %w[user1 user2],
        exclude_actions: %w[exclude1 exclude2],
        devices: %w[Bot Mobile Desktop Tablet Unknown],
        methods: %w[otp totp magiclink oauth saml password],
        geos: %w[US IL],
        remote_addresses: %w[remote1 remote2],
        login_ids: %w[login1 login2],
        tenants: %w[tenant1 tenant2],
        text: 'text123',
        from_ts: time.now - 10 * 24 * 60 * 60,
        to_ts: time.now - 1 * 24 * 60 * 60,
)

# Search successful logins in the last 30 days
audits = descope_client.audit_search(actions: ['LoginSucceed'])
```

You can also create audit event with data

```ruby
descope_client.audit_create_event(
  actor_id: "UXXX", # required, for example a user ID
  tenant_id: "tenant-id", # required
  action: "pencil.created", # required
  type: "info", # either: info/warn/error # required
  data: {
        pencil_id: "PXXX",
        pencil_name: "Pencil Name"
  } # optional
)
```

### Manage ReBAC Authz

Descope supports full relation based access control (ReBAC) using a [Google Zanzibar](https://research.google/pubs/pub48190/) like schema and operations.
A schema comprises namespaces (entities like documents, folders, orgs, etc.) and each namespace has relation definitions to define relations.
Each relation definition can be simple (either you have it or not) or complex (union of nodes).

A simple example for a file system like schema would be:

```yaml
# Example schema for the authz tests
name: Files
namespaces:
  - name: org
    relationDefinitions:
      - name: parent
      - name: member
        complexDefinition:
          nType: union
          children:
            - nType: child
              expression:
                neType: self
            - nType: child
              expression:
                neType: relationLeft
                relationDefinition: parent
                relationDefinitionNamespace: org
                targetRelationDefinition: member
                targetRelationDefinitionNamespace: org
  - name: folder
    relationDefinitions:
      - name: parent
      - name: owner
        complexDefinition:
          nType: union
          children:
            - nType: child
              expression:
                neType: self
            - nType: child
              expression:
                neType: relationRight
                relationDefinition: parent
                relationDefinitionNamespace: folder
                targetRelationDefinition: owner
                targetRelationDefinitionNamespace: folder
      - name: editor
        complexDefinition:
          nType: union
          children:
            - nType: child
              expression:
                neType: self
            - nType: child
              expression:
                neType: relationRight
                relationDefinition: parent
                relationDefinitionNamespace: folder
                targetRelationDefinition: editor
                targetRelationDefinitionNamespace: folder
            - nType: child
              expression:
                neType: targetSet
                targetRelationDefinition: owner
                targetRelationDefinitionNamespace: folder
      - name: viewer
        complexDefinition:
          nType: union
          children:
            - nType: child
              expression:
                neType: self
            - nType: child
              expression:
                neType: relationRight
                relationDefinition: parent
                relationDefinitionNamespace: folder
                targetRelationDefinition: viewer
                targetRelationDefinitionNamespace: folder
            - nType: child
              expression:
                neType: targetSet
                targetRelationDefinition: editor
                targetRelationDefinitionNamespace: folder
  - name: doc
    relationDefinitions:
      - name: parent
      - name: owner
        complexDefinition:
          nType: union
          children:
            - nType: child
              expression:
                neType: self
            - nType: child
              expression:
                neType: relationRight
                relationDefinition: parent
                relationDefinitionNamespace: doc
                targetRelationDefinition: owner
                targetRelationDefinitionNamespace: folder
      - name: editor
        complexDefinition:
          nType: union
          children:
            - nType: child
              expression:
                neType: self
            - nType: child
              expression:
                neType: relationRight
                relationDefinition: parent
                relationDefinitionNamespace: doc
                targetRelationDefinition: editor
                targetRelationDefinitionNamespace: folder
            - nType: child
              expression:
                neType: targetSet
                targetRelationDefinition: owner
                targetRelationDefinitionNamespace: doc
      - name: viewer
        complexDefinition:
          nType: union
          children:
            - nType: child
              expression:
                neType: self
            - nType: child
              expression:
                neType: relationRight
                relationDefinition: parent
                relationDefinitionNamespace: doc
                targetRelationDefinition: viewer
                targetRelationDefinitionNamespace: folder
            - nType: child
              expression:
                neType: targetSet
                targetRelationDefinition: editor
                targetRelationDefinitionNamespace: doc
```

Descope SDK allows you to fully manage the schema and relations as well as perform simple (and not so simple) checks regarding the existence of relations.

```ruby
# Load the existing schema
schema = descope_client.authz_load_schema

# Save schema and make sure to remove all namespaces not listed
descope_client.authz_save_schema(schema: schema, upgrade: true)

# Create a relation between a resource and user
descope_client.authz_create_relations(
        [
                { 
                        resource: 'some-doc',
                        relationDefinition: 'owner',
                        namespace: 'doc',
                        target: 'u1'
                }
        ]
)

# Check if target has the relevant relation
# The answer should be true because an owner is also a viewer
relations = descope_client.authz_has_relations?(
        [
                {
                        resource: 'some-doc',
                        relationDefinition: 'viewer',
                        namespace: 'doc',
                        target: 'u1'
                }
        ]
)
```

### Manage Project

You can change the project name, as well as to clone the current project to a new one.

```ruby

# Change the project name
descope.client.rename_project('new-project-name')

# Clone the current project, including its settings and configurations.
# Note that this action is supported only with a pro license or above.
# Users, tenants and access keys are not cloned.
clone_resp = descope.client.clone_project('new-project-name')
```

### Utils for your end to end (e2e) tests and integration tests

To ease your e2e tests, we exposed dedicated management methods,
that way, you don't need to use 3rd party messaging services in order to receive sign-in/up Emails or SMS, and avoid the need of parsing the code and token from them.

```ruby
# User for test can be created, this user will be able to generate code/link without
# the need of 3rd party messaging services.
# Test user must have a loginId, other fields are optional.
# Roles should be set directly if no tenants exist, otherwise set
# on a per-tenant basis.

associated_tenants = [{ tenant_id: 'tenant_id1', role_names: %w[role_name1 role_name2] }]
descope_client.create_test_user(
        login_id: 'desmond@descope.com',
        email: 'desmond@descope.com',
        display_name: 'Desmond Copeland',
        user_tenants: client.associated_tenants_to_hash_array(associated_tenants)
)

# Now test user got created, and this user will be available until you delete it,
# you can use any management operation for test user CRUD.
# You can also delete all test users.
descope_client.delete_all_test_users

# OTP code can be generated for test user, for example:
resp = descope_client.generate_otp_for_test_user(
        method: Descope::Mixins::Common::DeliveryMethod::EMAIL, login_id: 'login-id'
)
code = resp['code']
# Now you can verify the code is valid (using descope_client.*.verify for example)

# Same as OTP, magic link can be generated for test user, for example:
resp = descope_client.generate_magic_link_for_test_user(
        method: Descope::Mixins::Common::DeliveryMethod::EMAIL,
        login_id: 'login-id',
)
link = resp['link']

# Enchanted link can be generated for test user, for example:
resp = descope_client.generate_enchanted_link_for_test_user(
        'login-id', ''
)
link = resp['link']
pending_ref = resp['pendingRef']
```

### Manage SSO Applications

You can create, update, delete or load SSO applications:

```ruby
descope_client.create_sso_oidc_app(
  name: "My First sso app",
  login_page_url: "https://dummy.com/login",
  id: "my-custom-id", # this is optional
)

# Create SAML sso application
descope_client.create_saml_application(
  name: "My First sso app",
  login_page_url: "https://dummy.com/login",
  id: "my-custom-id", # this is optional
  use_metadata_info: true,
  metadata_url: "https://dummy.com/metadata",
  default_relay_state: "relayState",
  force_authentication: false,
  logout_redirect_url: "https://dummy.com/logout",
)
```

# Update OIDC sso application
# Update will override all fields as is. Use carefully.

```ruby
descope_client.update_sso_oidc_app(
  id: "my-custom-id",
  name: "My First sso app",
  login_page_url: "https://dummy.com/login",
)
````

# Update SAML sso application
# Update will override all fields as is. Use carefully.

```ruby
descope_client.update_saml_application(
  id: "my-custom-id",
  name: "My First sso app",
  login_page_url: "https://dummy.com/login",
  use_metadata_info: false,
  entity_id: "ent1234",
  acs_url: "https://dummy.com/acs",
  certificate: "my cert"
)
```

# SSO application deletion cannot be undone. Use carefully.

```ruby
descope_client.delete_sso_app('my-custom-id')
```

# Load SSO application by id

```ruby
descope_client.load_sso_app('my-custom-id')
```

# Load all SSO applications

```ruby
resp = descope_client.load_all_sso_apps
resp["apps"].each do |app|
  # Do something
end
```


## API Rate Limits

Handle API rate limits by comparing the exception to the APIRateLimitExceeded exception, which includes the RateLimitParameters map with the key 'Retry-After.' This key indicates how many seconds until the next valid API call can take place.

```ruby
begin
    descope_client.magiclink_sign_up_or_in(
        method: Descope::Mixins::Common::DeliveryMethod::EMAIL,
        login_id: 'desmond@descope.com',
        uri: 'https://myapp.com/verify-magic-link',
    )
rescue Descope::RateLimitException => e
    retry_after_seconds = e['API_RATE_LIMIT_RETRY_AFTER_HEADER']
    puts "Rate limit exceeded, retry after #{retry_after_seconds} seconds"
end
    # This variable indicates how many seconds until the next valid API call can take place.
```

## Code Examples

You can find various usage examples in the [examples folder](https://github.com/descope/ruby-sdk/blob/main/examples).

## Run Locally

### Prerequisites

- Ruby 3.3.0 or higher
- Bundler


### Install dependencies

```bash
bundle install
```

### Run tests

Running all tests:

```bash
bundle exec rspec
```

## Learn More

To learn more please see the [Descope Documentation and API reference page](https://docs.descope.com/).

## Contact Us

If you need help you can email [Descope Support](mailto:support@descope.com)

## License

The Descope SDK for Python is licensed for use under the terms and conditions of the [MIT license Agreement](https://github.com/descope/ruby-sdk/blob/main/LICENSE).
