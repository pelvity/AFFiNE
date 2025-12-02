# AFFiNE Production Desktop Setup

Since the native Electron app requires a complex build environment (Visual Studio C++ tools, specific Node versions) that is difficult to configure automatically, we have set up a **Production Desktop Experience** using Chrome App Mode.

This provides a dedicated window for AFFiNE that looks and feels like a native app, but connects directly to your local production server running in Docker.

## 🚀 How to Launch

Simply double-click the **`launch-desktop-prod.bat`** file in this directory.

## ⚙️ How it Works

1.  It uses your existing **Production Docker Environment** (which we just set up).
2.  It launches Chrome in `--app` mode pointing to `http://localhost:3010`.
3.  This ensures you are using the **exact same data and database** as your web production instance.
4.  It provides a clean, borderless window without browser toolbars.

## ✅ Benefits

*   **Zero Build Time**: No need to compile the Electron app.
*   **Unified Data**: Connects to the same PostgreSQL database as your web instance.
*   **Performance**: Uses the optimized Chrome rendering engine.
*   **Production Ready**: Uses the stable Docker production build.
