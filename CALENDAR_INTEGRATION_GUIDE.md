# 📅 How to Enable Calendar Integration (and other Desktop features)

You noticed that **Calendar Integration** is missing from your local setup. This is because **Calendar Integration is an Electron-exclusive feature** (due to browser security restrictions like CORS) and is disabled in the Web version of AFFiNE.

Since you are running the **Web Version** (even in Chrome App Mode), this feature is hidden.

## ✅ The Solution: Use the Official AFFiNE Client

To get Calendar Integration, Tabs, and a true native experience while keeping your data on your **Local Production Server**, you should use the **Official AFFiNE Desktop Client**.

### Step 1: Download the Official Client
Download the latest Windows client from the official release page:
[https://affine.pro/download](https://affine.pro/download)

### Step 2: Connect to Your Local Server
1.  Install and open the **AFFiNE Official Client**.
2.  On the startup screen (or in the workspace switcher), click **"Add Workspace"**.
3.  Select **"Self-Hosted"** (or "Connect to Server").
4.  Enter your local server URL:
    ```
    http://localhost:3010
    ```
5.  Click **Connect**.

### Step 3: Log In
1.  You will be prompted to log in.
2.  Use the admin account we just created:
    *   **Email**: `admin@affine.pro`
    *   **Password**: `Admin2024!@#`

### 🎉 Result
*   You will now have the **full Desktop experience**.
*   **Calendar Integration** will be available in Settings.
*   Your data is still stored **locally on your machine** (in the Docker container).
*   You get the best of both worlds: Official Client features + Self-Hosted Privacy.
