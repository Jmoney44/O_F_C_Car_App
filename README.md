# OFC Luxury

A mobile app for the OFC car showroom, built with Flutter and Firebase.

Customers browse the cars on sale, scan the QR code on a car to open its page,
save favourites, make price offers and request a reservation. Showroom staff
(admins) use the same app to add cars, print each car's QR label and handle
orders and offers.

## What is in the app

**Customers**

- Sign up, sign in and reset a password by email
- Home screen with featured cars, body-type shortcuts and latest arrivals
- Browse with search, filters (make, body type, condition, fuel,
  transmission, maximum price) and sorting
- Car page with photos, specification, description and status
- **Scan**: point the camera at the QR code on a car and its page opens
- Save cars, make an offer, and reserve a car (collection or delivery, bank
  transfer or pay at the showroom)
- Track orders and offers; cancel a reservation that is not yet confirmed

**Admins**

- Add, edit and delete cars, with photos
- **QR code for every car**: shown on screen, printable as an A6 label and
  shareable as a PDF. The code is created with the car and never changes
- Confirm or cancel orders and mark cars as sold (the car's status follows
  automatically)
- Accept or decline offers, with a note to the customer

No money moves inside the app. A reservation is a request; the showroom
confirms it and takes payment directly.

## Try it without Firebase (demo mode)

Until Firebase is connected the app runs on built-in sample cars, so you can
see every screen straight away:

```bash
flutter pub get
```

```bash
flutter run
```

Sign in with any email and password. Use an email containing `admin` (for
example `admin@ofc.com`) to see the admin area. Demo data is reset every time
the app restarts, and photo upload is switched off.

The sample cars use photos from Wikimedia Commons, bundled in `assets/demo/`
and credited in `assets/demo/CREDITS.md`. They add about 2 MB to the app;
delete that folder and its `pubspec.yaml` entry before release if you do not
want to ship them.

## Connect your Firebase project

1. Create a project in the [Firebase console](https://console.firebase.google.com).
2. In the project, turn on:
   - **Authentication** → Sign-in method → **Email/Password**
   - **Firestore Database** (production mode)
   - **Storage**
3. Install the tools and connect the app. This overwrites
   `lib/firebase_options.dart` with your project's settings:

   ```bash
   npm install -g firebase-tools
   ```

   ```bash
   firebase login
   ```

   ```bash
   dart pub global activate flutterfire_cli
   ```

   ```bash
   flutterfire configure
   ```

4. Deploy the security rules and indexes from this repo:

   ```bash
   firebase deploy --only firestore,storage
   ```

5. Run the app and create your own account with **Create an account**.
6. Make yourself the first admin: in the Firebase console open
   **Firestore → users → (your user document)** and change `role` from
   `customer` to `admin`. The admin area appears in the Account tab
   immediately. Customers cannot change their own role; this is enforced by
   `firestore.rules`.

## Settings to change before release

All in `lib/core/config.dart`:

| Setting | What it is |
| --- | --- |
| `currencySymbol` | Symbol shown in front of prices (default `$`) |
| `carLinkBase` | The link stored in every QR code (see below) |
| `showroomPhone`, `showroomEmail`, `showroomAddress` | Contact details |

Also replace the default Flutter launcher icon, and set up release signing
for Android (`android/app/build.gradle.kts` still signs with the debug key).

## How the QR codes work

Each code holds a link: `<carLinkBase>/<carId>`, for example
`https://your-domain/car/AbC123`. The in-app scanner reads the car id from
the end of the link and opens that car, so:

- codes keep working if you later change `carLinkBase`;
- the id is printed under the code and can be typed in by hand
  (**Scan → Enter code instead**).

To make the codes also work from an ordinary phone camera (opening the app
directly), point `carLinkBase` at a domain you control and set up
[Android App Links](https://docs.flutter.dev/cookbook/navigation/set-up-app-links)
and [iOS Universal Links](https://docs.flutter.dev/cookbook/navigation/set-up-universal-links)
for it. The app already routes `/car/<id>` to the car page. Do this before
printing labels in bulk.

## Project layout

```
lib/
  main.dart                 start-up: Firebase, or demo mode if not configured
  app.dart, router.dart     theme and navigation (sign-in and admin guards)
  providers.dart            app state (Riverpod)
  core/                     settings, theme, validation, QR link format
  models/                   Car, CarFilter, AppUser, Offer, CarOrder
  data/
    repositories.dart       the interfaces every screen talks to
    firebase/               Firebase implementation
    demo/                   in-memory sample data (demo mode and tests)
  features/                 one folder per area: auth, home, cars, scan,
                            favorites, offers, orders, account, admin
  widgets/                  shared UI pieces
firestore.rules, storage.rules, firestore.indexes.json, firebase.json
tool/rules_test/            emulator tests for the Firestore rules
```

Firestore collections: `users` (with a `favorites` subcollection), `cars`,
`offers`, `orders`. Car photos live in Storage under `cars/<carId>/`.

## Checks

```bash
flutter analyze
```

```bash
flutter test
```

Security rules (needs Node and Java for the Firebase emulator):

```bash
cd tool/rules_test && npm install && npm test
```

## Not built yet

- Online card payments (needs a payment provider and server-side code)
- Push notifications when an order or offer changes
- Google / Apple sign-in
- Test-drive booking
