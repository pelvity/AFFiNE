# Teacher Workspace - Default Subscription Setup

## ✅ Final Configuration

Your "teacher" workspace is now set up with the **default Team Plan** subscription.

### Workspace Details
- **Workspace ID:** `d26c28f3-902a-4277-9c97-203ea500fb4f`
- **Workspace Name:** teacher
- **Subscription:** Team Plan v1 (default, no customizations)

### Default Team Plan Features
- **Member Limit:** 100 members
- **Storage Quota:** ~100 GB base + (20 GB × number of members)
- **Blob Size Limit:** 500 MB per file
- **History Period:** 30 days
- **Seat Quota:** 20 GB per member

### Current Members (4/100)
1. **admin@affine.pro** - Owner (Accepted)
2. **artem_bmw@gmail.com** - Collaborator (Accepted)
3. **dmxer@gmail.com** - Collaborator (Accepted)
4. **artem.math@gmail.com** - Collaborator (Accepted) ✅ Just approved

### What Was Fixed

1. ✅ **Removed SafeInt NaN error** - Removed conflicting pro_plan_v1
2. ✅ **Set memberLimit to 100** - Reasonable limit that won't cause overflow
3. ✅ **Enabled team_plan_v1** - Using default configuration from features table
4. ✅ **No custom configs** - All settings use defaults (no hardcoded values)
5. ✅ **Approved artem.math@gmail.com** - Changed status from AllocatingSeat to Accepted

### Why Email Notifications Don't Work

**Email is NOT configured** on your production server. To enable email notifications:

1. Set these environment variables in `.env.prod.local`:
   ```bash
   MAILER_HOST=smtp.gmail.com
   MAILER_PORT=587
   MAILER_USER=your-email@gmail.com
   MAILER_PASSWORD=your-app-password
   MAILER_SENDER=noreply@affine.pro
   ```

2. Restart the backend:
   ```bash
   docker restart affine_backend_prod
   ```

Without email configuration, users won't receive invitation emails. You'll need to:
- Manually approve users (change status to "Accepted" in database)
- Or share the workspace invite link directly

### How to Invite Members (Current Setup)

Since email is not configured:

**Option 1: Manual Approval (what we did)**
1. Invite user via UI → Status becomes "AllocatingSeat"
2. Manually update database: `UPDATE workspace_user_permissions SET status = 'Accepted' WHERE ...`

**Option 2: Use Invite Link**
1. Create an invite link in the workspace settings
2. Share the link directly with users
3. They click the link and get added automatically

### Next Steps

If you want email notifications to work:
1. Configure email settings (see above)
2. Users will receive invitation emails automatically
3. The `allocateSeats` function will run via background jobs

For now, the workspace is working with default Team Plan settings and all members are approved!
