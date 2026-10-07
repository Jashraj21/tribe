# Tribe - Live Concerts & Dine-In Booking App

> A premium, high-octane Android application built with **Flutter** for booking live stadium concerts, music festivals, comedy tours, and curated rooftop dine-in reservations with full authentication and multi-method payment gateway integration. Inspired by modern entertainment & nightlife platforms like Zomato District.

---

## 📱 App Highlights & Core Features

### 🎪 1. Mega Concerts & Stadium Tours
- **Curated Lineups**: Top headline stadium tours (Coldplay Music of the Spheres, Diljit Dosanjh DIL-LUMINATI, Sunburn Arena ft. Martin Garrix, Dua Lipa Radical Optimism, Trevor Noah Off The Record).
- **Interactive Tier Selection**: Choose from General Access, Grandstand Seated, Fan Pit (Front Row), and Infinity VIP Lounge with live benefits inspection.
- **Tour Add-Ons**: Official organic tour t-shirts, VIP stadium parking passes, and express F&B voucher packs.
- **Real-Time Indicators**: Live "FILLING FAST" and "HOT SELLING" badges with price-per-tier dynamic calculation.

### 🍽️ 2. Dine-In & Nightlife Table Reservations
- **Curated Hotspots**: Iconic restaurants & lounges (Bastian At The Top 48th Floor, The Piano Man Jazz Club, Toit Microbrewery, Olive Bar & Kitchen, Slink & Bardot).
- **Interactive Booking Flow**:
  - **Date Selector**: Today, Tomorrow, and upcoming calendar dates.
  - **Party Size Guest Selector**: 1 to 10+ guests with visual avatar indicators.
  - **Seating Preference**: Rooftop Skydeck (Sea Facing), Indoor Fine Dine, Velvet Bar Counter, Outdoor Garden Patio.
  - **Time Slots**: Lunch, Prime Sunset Dinner, and Nightlife DJ sets with discount tags (e.g. *15% Off*, *Early Bird*).
  - **Pre-Order Chef Specials**: Signature dishes (Butter Garlic Lobster, Truffle Dumplings, Woodfired Pizzas, Craft Beers) pre-ordered and adjusted against the final bill.

### 🔐 3. Authentication & Account Management
- **Sign In & Register**: Toggleable tabbed authentication with email, phone number, and password validation.
- **One-Tap VIP Demo Login**: Instant login without typing for immediate end-to-end evaluation.
- **Guest Mode**: Explore concerts, restaurants, and menu without friction; prompted gracefully only at checkout.
- **Social Login**: Google and Apple login simulations.
- **Session Persistence**: Automatic session restoration via `shared_preferences`.

### 💳 4. Payment Gateway Integration
- **Multi-Method Gateway**:
  - **UPI**: Google Pay, PhonePe, Paytm, and custom VPA (`username@bank`).
  - **Credit / Debit Cards**: Card number, expiry `MM/YY`, CVV, and simulated 3D Secure bank OTP dialog.
  - **Net Banking**: HDFC Bank, ICICI Bank, State Bank of India, Axis Bank, Kotak.
  - **Digital Wallets**: District Cash balance and wallet payments.
- **Promo Coupon Engine**:
  - `DISTRICT20`: 20% instant discount (up to ₹1,000).
  - `WELCOME500`: Flat ₹500 discount on bookings above ₹1,500.
  - `DINE50`: Flat 50% discount on table cover charge.
- **Transparent Pricing Breakdown**: Base Amount + 2.5% Convenience Fee + 18% GST on fees - Coupon Discounts.
- **Bank Gateway Handshake**: Realistic 256-bit encrypted bank authorization loader.

### 🎟️ 5. Scannable Digital Passes & QR Code Entry
- **Authentic Ticket Passes**: High-res QR code generated via `qr_flutter` formatted for stadium turnstiles and hostess check-in.
- **Perforated Ticket Styling**: Classic notched tickets with booking reference ID, transaction hash, and timestamp.
- **Wallet & Share**: Save pass to Google / Apple Wallet, copy reference, or view in "My Passes" anytime offline.

---

## 🛠️ Architecture & Tech Stack

| Component | Technology |
|---|---|
| **Framework** | [Flutter 3.47](https://flutter.dev) & [Dart 3.13](https://dart.dev) |
| **State Management** | [Provider](https://pub.dev/packages/provider) (`AuthProvider`, `BookingProvider`) |
| **Typography & Theme** | [Google Fonts](https://pub.dev/packages/google_fonts) (*Outfit* & *Plus Jakarta Sans*) with Midnight Obsidian Dark Mode |
| **QR Code Generation** | [qr_flutter](https://pub.dev/packages/qr_flutter) |
| **Storage & Persistence** | [shared_preferences](https://pub.dev/packages/shared_preferences) |
| **Formatting & Currency** | [intl](https://pub.dev/packages/intl) (Indian Rupee ₹ formatting, date & time formatters) |
| **Unique IDs** | [uuid](https://pub.dev/packages/uuid) |

---

## 📂 Project Structure

```
lib/
├── main.dart                          # Application entry point with MultiProvider & Theme
├── theme/
│   └── app_theme.dart                 # Design tokens, gradients, colors, Material 3 Dark theme
├── models/
│   ├── user_model.dart                # User profile model & serialization
│   ├── concert_model.dart             # Concert, TicketTier, and AddOn models
│   ├── restaurant_model.dart          # Restaurant, TimeSlot, and MenuItem models
│   └── booking_model.dart             # Unified BookingModel with QR data & receipts
├── data/
│   └── mock_data.dart                 # Curated concerts, restaurants, menus & city metadata
├── services/
│   ├── auth_service.dart              # Authentication & session persistence
│   └── payment_service.dart           # Multi-method payment gateway, coupon & fee calculator
├── providers/
│   ├── auth_provider.dart             # User auth state management
│   └── booking_provider.dart          # Passes, filters, favorites, city & booking state
├── widgets/
│   ├── app_button.dart                # Gradient button with loading & icon support
│   ├── glass_container.dart          # Glassmorphic elevated container
│   ├── category_chip.dart             # Filter pills with neon active states
│   ├── concert_card.dart              # Horizontal & vertical concert cards with status badges
│   ├── restaurant_card.dart           # Horizontal & vertical dine-in reservation cards
│   └── qr_ticket_modal.dart           # Digital entry pass with scannable QR & perforation notches
└── screens/
    ├── main_navigation_screen.dart    # Docked bottom navigation with pass count badges
    ├── auth/
    │   └── auth_screen.dart           # Sign In / Register / Guest / Demo login screen
    ├── home/
    │   └── home_screen.dart           # City selector, auto-carousel hero, trending sections
    ├── concerts/
    │   ├── concert_list_screen.dart   # Categorized concert explorer & genre filters
    │   ├── concert_detail_screen.dart # Event details, artist badge, highlights, rules
    │   └── ticket_selection_screen.dart # Tier selector (+/-), add-ons, subtotal tally
    ├── dine_in/
    │   ├── dine_in_list_screen.dart   # Curated restaurants & atmosphere filter
    │   ├── restaurant_detail_screen.dart # Ambience, chef specials preview, hours
    │   └── table_reservation_screen.dart # Date, guest size, seating area, pre-order
    ├── checkout/
    │   ├── checkout_screen.dart       # Payment methods, coupons, GST bill, gateway dialog
    │   └── booking_confirmation_screen.dart # Celebration, digital QR ticket pass, receipt
    ├── bookings/
    │   └── my_bookings_screen.dart    # Active passes & past history with instant QR modal
    └── profile/
        └── profile_screen.dart        # Profile details, saved cards, VIP club, settings
```

---

## 🚀 How to Run

### 1. Prerequisites
Ensure you have the Flutter SDK installed on your system.
Verify Flutter installation:
```bash
flutter --version
flutter doctor
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Run on Android Device / Emulator
Connect your Android phone via USB with USB Debugging enabled, or launch an Android emulator from Android Studio:
```bash
flutter run -d android
```

### 4. Run on Chrome / Web
```bash
flutter run -d chrome
```

### 5. Run on macOS Desktop
```bash
flutter run -d macos
```

### 6. Run Test Suite
```bash
flutter test
flutter analyze
```
All unit tests and analyzer checks pass with **0 errors and 0 warnings**.
