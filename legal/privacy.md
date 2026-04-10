# Privacy Policy for Nurr

Last updated: April 10, 2026

This Privacy Policy explains how Nurr handles information when you use the app.

## Overview

Nurr is a Quran and dua app. The app does not require account creation and currently does not include in-app advertising, payment processing, or user profile creation.

The app stores some data locally on your device and uses third-party services for selected content and location-based features.

## Information Stored Locally on Your Device

Nurr stores certain app settings and app state locally on your device using local app storage such as `SharedPreferences`.

Depending on the feature you use, this may include:

- selected app language
- selected Quran reading language
- selected theme and background
- last-read Quran or Mushaf page
- bookmark data
- prayer checklist or prayer-history data
- tasbih counter state and selected dhikr
- intro or tutorial status
- other feature-related app preferences needed to restore your last state

This data is stored locally on your device to provide app functionality. It is not tied to an account and is not synced by the app to a personal user profile.

## Location Data

The prayer times feature can use your current location to calculate local prayer times.

- On Android and iOS, the app may request location permission through the system permission dialog.
- On web, the browser may request location permission.
- If direct location access is unavailable on web, the app may use an IP-based fallback through `https://ipapi.co/json/` to estimate an approximate location.

The app does not currently create user accounts or maintain an internal location history for profiling. However, location-related data may be processed by third-party services when prayer times are requested.

## External Services and Data Transfers

The app currently makes requests to third-party services for certain features.

### 1. Quran content

Service:
- `https://api.alquran.cloud/`

Purpose:
- loading Quran metadata
- loading surah and translation content

Data sent:
- standard technical request data such as IP address, request metadata, and device/browser network information

### 2. Hadith content

Service:
- `https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1/`

Purpose:
- loading Hadith content used in the app

Data sent:
- standard technical request data such as IP address, request metadata, and device/browser network information

### 3. Prayer times

Service:
- `https://api.aladhan.com/v1/timings`

Purpose:
- calculating prayer times for the selected or detected location

Data sent:
- latitude and longitude in the request URL when prayer times are requested
- standard technical request data such as IP address and request metadata

### 4. IP-based location fallback on web

Service:
- `https://ipapi.co/json/`

Purpose:
- estimating approximate location when direct browser geolocation is unavailable or not used on web

Data sent:
- your IP address and standard request metadata are necessarily processed by that service to return an approximate location

### 5. Fonts

The app uses the `google_fonts` package. Depending on platform, build, and caching behavior, fonts may be loaded from Google font infrastructure such as `fonts.gstatic.com`.

Purpose:
- rendering selected fonts in the app

Data sent:
- standard technical request data such as IP address and request metadata

## Permissions

The current app configuration includes:

- internet access
- coarse location
- fine location

On iOS, the app also declares location usage descriptions for prayer time calculation.

## Data Sharing

The app does not sell personal data. The app does not currently use advertising networks or analytics SDKs based on the current project configuration.

However, when you use features that rely on external services, the relevant request data is necessarily processed by those providers.

## Data Retention

Locally stored app data remains on your device until you remove it, clear the app's storage, or uninstall the app, subject to your platform's behavior.

Data processed by third-party providers is subject to the privacy and retention practices of those providers.

## Children

The app is intended for a general audience and does not knowingly collect personal information through account registration or user profile creation.

## Security

No method of transmission or storage is completely secure. While much of the app state is stored locally on your device, any use of third-party network services depends on those providers and the security of your device, browser, operating system, and internet connection.

## Changes to This Privacy Policy

This Privacy Policy may be updated from time to time. The latest version should be published with the app listing, website, support page, or legal page used for distribution.

## Contact

For privacy questions or requests, please contact:

- `nurrquran9@gmail.com`
