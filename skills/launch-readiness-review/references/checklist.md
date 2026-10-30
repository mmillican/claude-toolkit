# Launch readiness checklist

Check each item against the real code, config, and site content. Note evidence (file and
line, URL, or command output) for every finding.

## Signup and access

- [ ] The full signup path works on the **production** identity provider, not just the local
      one (e.g. Cognito vs Keycloak). Look for differences in password rules, verification,
      hosted-UI sign-up links, and callback URLs.
- [ ] Partial failures (an email send fails, the IdP call fails) don't leave orphaned or
      locked accounts.
- [ ] Validation rules match across frontend, backend, and IdP.
- [ ] Invite/signup-code gates: the page explains what's needed and where to request it
      *before* the user fills in the form.
- [ ] There is a documented way to create the first production admin.
- [ ] Existing users know they don't need to sign up again (sign-in link in the email).

## Security and abuse

- [ ] Rate limiting / bot protection on anonymous endpoints (signup, resend verification,
      password reset, contact forms).
- [ ] Token validation checks audience/client and token type.
- [ ] No account enumeration via different responses.
- [ ] Email ownership is verified before an address is trusted.
- [ ] Secrets are not in the repo; production config comes from the secret store.

## Legal and privacy

- [ ] Privacy policy and terms exist, are linked from signup and the footer, and match what
      is actually collected.
- [ ] Account deletion and data export exist or are promised with a process.
- [ ] Re-acceptance flow if terms change.
- [ ] Analytics respects the policy (e.g. no tracking of admin pages or local dev).

## Product consistency

- [ ] The marketing site, changelog, docs, and app agree on what's available. Look for
      "Coming soon" text, features behind flags, and changelog gaps.
- [ ] Docs that are written are committed and deployed.
- [ ] No placeholder or "Coming soon" UI is visible to normal users.
- [ ] No dead links (`href="#"`, old domains, 404s). Login/signup links point at production.
- [ ] Old URLs redirect (301) where content moved.

## Operations

- [ ] Error monitoring is on and recent errors are triaged.
- [ ] Capacity for a burst: manual approval queues have an owner and a target turnaround;
      code/invite expiry is long enough; email sending limits are adequate.
- [ ] Backups and a rollback path exist.
- [ ] Feature flags in production are in the intended state.

## Communication

- [ ] The announcement says what's new, who it's for, how to get access, and the expected
      wait.
- [ ] Support/contact path is visible.
