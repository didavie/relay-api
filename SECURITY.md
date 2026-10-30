# Security policy

## Reporting a vulnerability

Please do not open a public issue for a security problem in the Relay API or in the code of this repository.

- Use GitHub private vulnerability reporting: **Security > Report a vulnerability** on [didavie/relay-api](https://github.com/didavie/relay-api/security/advisories/new), or
- e-mail **relay@didavie.com** with the subject `Security: relay-api`.

Include what you found, the steps to reproduce it and the impact you expect. Test only with your own accounts and with sandbox keys from [relaysandbox.didavie.com](https://relaysandbox.didavie.com). Do not access other customers' data, degrade the service, or run automated scans that send large volumes of requests.

We acknowledge reports within 3 business days and keep you informed until the fix is released. We credit reporters who wish to be named once the fix is public.

## If a key leaks

If you published a Relay API key or webhook secret by mistake, revoke it right away where it was created (Relay Partners, the agency Developers page, or the sandbox) and create a new one. Revoked keys stop working at once.
