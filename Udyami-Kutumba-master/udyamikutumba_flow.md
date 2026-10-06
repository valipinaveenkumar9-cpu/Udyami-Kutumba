# Udyami Kutumba: Context and Flow of Completed Features

Here is a breakdown of the context and flow for the completed features in the app:

### 1. Authentication Flow (`auth` module)
*   **Context:** The entry point of the app. It relies on a mobile number and OTP (One-Time Password) system for login.
*   **Flow:** 
    *   The app launches and checks `SessionManager` (`main.dart`).
    *   If no session exists, the user is directed to the `LoginScreen`.
    *   User inputs their mobile number, receives a 4-digit OTP, and authenticates.
    *   Upon successful verification, the session is saved, profile data (`UserProfileModel`) is fetched via `ProfileAPI`, and the user is routed to the `MainScreen`.

### 2. Main Navigation Flow (`MainScreen`)
*   **Context:** `MainScreen` is the central hub of the application. It acts as the scaffold housing the bottom navigation bar (and likely a side drawer).
*   **Flow:** 
    *   The `MainScreen` maintains a list of primary screens (e.g., `HomeScreen`, `WardScreen`, `UcnScreen`, `CommunicationsScreen`, `JobsScreen`, `ExploreScreen`, `MemberDirectoryScreen`).
    *   Switching tabs updates the `_currentIndex` and swaps out the body widget without resetting the app state.

### 3. Udyami Kutumba Network (UCN) Flow (`ucn` module)
*   **Context:** This is a highly structured, hierarchical community networking feature—very similar to organizational or political networking (like BNI).
*   **Flow:**
    *   **Access Check:** When a user opens `UcnScreen`, it first checks their membership tier (`isPrime`). If they are just a standard 'Member', they are shown a prompt to upgrade.
    *   **Role-Based Dashboards:** If the user has a higher role (`Assembly President`, `Taluka Head`, `Circle Leader`, `Sector Head`), the UI dynamically renders specific grids for them.
    *   **Key Features:** From the UCN dashboard, users can navigate to view "Assembly Roles," use the "Assembly Console," check the "Assembly Scorecard," view "Members," record "Face-to-Face" meetings, and issue "Thank You Slips" (acknowledging business/help received).

### 4. Jobs, Training & Programmes Flow (`jobs` module)
*   **Context:** A dual-purpose module for employment and specialized upskilling programs.
*   **Flow:**
    *   **Jobs Portal:** `JobsScreen` uses a `DefaultTabController` to switch between "Search Jobs" and "My Applications". There is also a flow for employers to create jobs (`JobCreateScreen`).
    *   **Programmes & Training:** Deeply integrated into the jobs module are distinct screens for specialized initiatives, such as the `Childrens Programme`, `Prince & Princess Programme`, and a dedicated `Training Screen`.
    *   **Lead & Rewards:** Users can navigate to `lead_management_screen` to track business leads and `rewards_scree` to view gamified progress or incentives.

### 5. Ward & Geolocation Flow (`ward` & `geofence` modules)
*   **Context:** Designed for localized, region-specific tracking and governance.
*   **Flow:** Users can navigate to `WardScreen` to see data specific to their localized area. This connects to `area_chart_screen` for visual data representation and utilizes `geofence_screen` to manage or view location-bound constraints (e.g., ensuring a user is physically within a ward for certain actions).

### 6. Communications Flow (`communications` module)
*   **Context:** Centralized hub for announcements and network-wide messaging.
*   **Flow:** Powered by `CommunicationsViewModel` (injected at the top level via `Provider` in `main.dart`), allowing real-time updates and notifications across the app.

### Summary of the App's Purpose
**"Udyami Kutumba"** appears to be a robust socio-economic networking app. It combines **hierarchical community leadership (UCN)** with **employment/upskilling (Jobs & Training)**, and tracks local progress based on geographic **Wards**.
