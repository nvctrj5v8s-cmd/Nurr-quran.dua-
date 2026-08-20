# Nurr UI redesign rollback

The pre-redesign `HomePage` implementation remains in `lib/main.dart` and was not deleted.

To return to the previous shell:

1. In `_MainPageState`, replace `ModernHomePage(...)` with `HomePage(appLanguage: _appLanguage)`.
2. Replace the Material 3 `NavigationBar` with the prior `BottomNavigationBar` implementation from Git history.
3. Remove the onboarding routing in `_MyAppState` and route language selection directly to `MainPage`.
4. Remove these redesign-only files if they are no longer wanted:
   - `lib/modern_home_page.dart`
   - `lib/nurr_design.dart`
   - `lib/nurr_onboarding_page.dart`

The onboarding uses only Flutter gradients, shapes and Material icons; there are no onboarding raster assets to restore or remove.

Quran data, bookmarks, prayer tracking, settings and all other persisted user data are independent of the redesign and must not be cleared during a rollback.
