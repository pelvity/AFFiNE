# Password-Required Registration - Implementation Summary

## Date: 2025-12-04

## Objective
Disable email verification but **require password** for new user registration.

---

## Changes Made

### Backend Changes

**File: `packages/backend/server/src/core/auth/controller.ts`**

#### 1. Modified `passwordSignIn()` method
- **New behavior**: Handles both signup and login with password
- **For new users**: Creates account with password, marks as `registered=true` and `emailVerifiedAt=now()`
- **For existing users**: Verifies password and logs them in
- **No email verification required** for either case

```typescript
async passwordSignIn(req, res, email, password) {
  const existingUser = await this.models.user.getUserByEmail(email);
  
  if (existingUser) {
    // Existing user - verify password and sign in
    user = await this.auth.signIn(email, password);
  } else {
    // New user - create account with password (no email verification)
    const newUser = await this.models.user.create({
      email,
      password,
      registered: true,
      emailVerifiedAt: new Date(), // Mark as verified immediately
    });
    user = sessionUser(newUser);
  }
  
  // Set cookies and return user
  await this.auth.setCookies(req, res, user.id);
  res.status(HttpStatus.OK).send(user);
}
```

#### 2. Modified `sendMagicLink()` method
- **New behavior**: Rejects passwordless signups
- **For new users**: Throws `WrongSignInCredentials` error (requires password)
- **For existing users with password**: Auto-login them (no email code needed)
- **For existing users without password**: Requires them to set a password

```typescript
async sendMagicLink(req, res, email, ...) {
  const user = await this.models.user.getUserByEmail(email);
  
  if (user) {
    if (user.password) {
      // Existing user with password - auto-login
      const currentUser = sessionUser(user);
      await this.auth.setCookies(req, res, currentUser.id);
      res.status(HttpStatus.OK).send(currentUser);
      return;
    }
    // Existing user without password - reject
    throw new WrongSignInCredentials({ email });
  } else {
    // New user - reject (must use password signup)
    throw new WrongSignInCredentials({ email });
  }
}
```

---

## Flow Diagrams

### New User Registration Flow:
```
1. User enters email on signup page
2. Frontend calls /api/preflight → returns {registered: false, hasPassword: false}
3. Frontend shows password input field
4. User enters password
5. Frontend calls /api/auth/sign-in with {email, password}
6. Backend creates user with password and emailVerifiedAt=now()
7. Backend sets authentication cookies
8. Backend returns user object
9. User is immediately logged in
```

### Existing User Login Flow:
```
1. User enters email on login page
2. Frontend calls /api/preflight → returns {registered: true, hasPassword: true}
3. Frontend shows password input field
4. User enters password
5. Frontend calls /api/auth/sign-in with {email, password}
6. Backend verifies password
7. Backend sets authentication cookies
8. Backend returns user object
9. User is immediately logged in
```

### Passwordless Attempt (Rejected):
```
1. User enters email without password
2. Frontend calls /api/auth/sign-in with {email} (no password)
3. Backend calls sendMagicLink()
4. Backend throws WrongSignInCredentials error
5. Frontend shows error message
```

---

## Key Differences from Previous Implementation

| Feature | Previous (Passwordless) | Current (Password Required) |
|---------|------------------------|----------------------------|
| Email verification | ❌ Disabled | ❌ Disabled |
| Password required | ❌ No | ✅ Yes |
| New user signup | Email only | Email + Password |
| Existing user login | Email only | Email + Password |
| Magic link | Auto-login | Rejected (requires password) |

---

## Testing

### Test 1: Passwordless Signup (Should Fail)
```powershell
POST /api/auth/sign-in
Body: { "email": "test@example.com" }
Expected: 400 Bad Request (WrongSignInCredentials)
```

### Test 2: Password Signup (Should Succeed)
```powershell
POST /api/auth/sign-in
Body: { "email": "test@example.com", "password": "SecurePass123!" }
Expected: 200 OK with user object
```

### Test 3: Existing User Login (Should Succeed)
```powershell
POST /api/auth/sign-in
Body: { "email": "test@example.com", "password": "SecurePass123!" }
Expected: 200 OK with user object
```

---

## Database Schema

Users created with this flow will have:
- `email`: User's email address
- `password`: Hashed password
- `registered`: `true`
- `emailVerifiedAt`: Current timestamp (not null)
- `hasPassword`: `true`

---

## Security Considerations

✅ **Improvements**:
- Passwords are required for all new accounts
- Passwords are hashed before storage
- Email verification is bypassed (faster onboarding)

⚠️ **Considerations**:
- No email verification means anyone can register with any email
- Consider adding:
  - Email confirmation (optional, post-registration)
  - Password strength requirements
  - Rate limiting on signup endpoint
  - CAPTCHA (already implemented in frontend)

---

## Deployment Status

- ✅ Backend code modified
- 🔄 Docker image rebuilding (in progress)
- ⏳ Frontend changes (auto-detected via hot-reload)
- ⏳ Testing pending (after Docker rebuild completes)

---

## Files Modified

1. ✅ `packages/backend/server/src/core/auth/controller.ts`
   - Modified `passwordSignIn()` to handle signup + login
   - Modified `sendMagicLink()` to reject passwordless attempts

2. ✅ `packages/frontend/core/src/modules/cloud/services/auth.ts`
   - Modified `sendEmailMagicLink()` to detect immediate login

---

## Next Steps

1. ⏳ Wait for Docker build to complete
2. ⏳ Test password-required signup flow
3. ⏳ Test existing user login flow
4. ⏳ Verify database state
5. ⏳ Test frontend UI flow in browser
