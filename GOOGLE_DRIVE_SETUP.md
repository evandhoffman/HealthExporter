# Google Drive Integration Setup

## Step 1: Create Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project (name it "HealthExporter")
3. Enable the **Google Drive API**:
   - Search for "Google Drive API"
   - Click "Enable"

## Step 2: Create OAuth 2.0 Credentials

1. Go to **Credentials** in the left sidebar
2. Click **Create Credentials** → **OAuth 2.0 Client ID**
3. Choose **iOS** as the application type
4. Fill in:
   - **App name**: HealthExporter
   - **Bundle ID**: `com.evanhoffman.HealthExporter` (from your Xcode project)
5. Download the credentials file
6. Copy your **Client ID** (looks like `xxxxx-xxxxxx.apps.googleusercontent.com`)

## Step 4: Configure Secrets File

1. Copy `Secrets.plist.example` to `Secrets.plist`:
   ```
   cp /Users/evanhoffman/git/HealthExporter/Secrets.plist.example /Users/evanhoffman/git/HealthExporter/Secrets.plist
   ```

2. Edit `Secrets.plist` and replace `YOUR_GOOGLE_CLIENT_ID_HERE` with your actual Client ID from Step 2

3. **Important**: `Secrets.plist` is in `.gitignore` and will not be committed to git

## Step 5: Configure Xcode URL Scheme

1. Open your project in Xcode
2. Go to **HealthExporter** target → **Info** tab
3. Add a new URL type:
   - **Identifier**: `com.google.IdentifierScheme`
   - **URL Schemes**: Paste your Client ID (the full one, including `.apps.googleusercontent.com`)

## Step 6: Install CocoaPods

1. Open Terminal and navigate to your project:
   ```
   cd /Users/evanhoffman/git/HealthExporter
   ```

2. Install dependencies:
   ```
   pod install
   ```

3. Close your current Xcode project and open the new `.xcworkspace` file instead:
   ```
   open HealthExporter.xcworkspace
   ```

## Important Notes

- From now on, **always open `HealthExporter.xcworkspace`** (not `.xcodeproj`)
- The Google Drive button appears in the data export screen
- Users must sign in once; subsequent uploads don't require re-authentication
- Files are uploaded to the root of their Google Drive
