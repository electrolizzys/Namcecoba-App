# Supabase Auth Email Templates

The landing page after clicking a link lives in `index.html` / `public/index.html`
(GitHub Pages). The **email body** itself is configured in the Supabase Dashboard:

**Authentication → Email Templates**

Paste the templates below so registration and password recovery emails use the
correct wording (not a generic GitHub-style message).

---

## Confirm signup

**Subject:** Confirm your Namtsetsoba registration

**Body:**

```html
<h2>Welcome to Namtsetsoba</h2>
<p>Thanks for registering. Confirm your email to finish creating your account:</p>
<p><a href="{{ .ConfirmationURL }}">Confirm my email</a></p>
<p>If you did not create a Namtsetsoba account, you can ignore this email.</p>
```

---

## Reset password (recovery)

**Subject:** Reset your Namtsetsoba password

**Body:**

```html
<h2>Password recovery</h2>
<p>We received a request to reset the password for your Namtsetsoba account.</p>
<p><a href="{{ .ConfirmationURL }}">Choose a new password</a></p>
<p>If you did not ask for this, you can ignore this email — your password will stay the same.</p>
```

---

After saving the templates in Supabase, also redeploy `public/index.html` to
GitHub Pages so the link destination matches (registration confirmed vs recover password).
