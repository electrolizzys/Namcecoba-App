# Namtsetsoba (Namcecoba-App)

iOS app for **surplus-food surprise bags** in Georgia. Venues publish discounted “mystery” baskets; customers discover, order, and pick them up. Admins onboard venues and oversee the platform.

Built with **SwiftUI**, **Supabase** (Auth, Postgres, Storage, Edge Functions), and clean architecture.

---

## Roles

| Role | DB `profiles.role` | What they do |
|------|--------------------|--------------|
| **Customer** | `customer` | Browse offers & stores, order bags, favourites, ratings, analytics (“My Impact”), support chat |
| **Venue** | `venue` → app `.business` | Publish/edit baskets, manage incoming orders, venue analytics, store logo, support chat |
| **Admin** | `admin` | Dashboard, stores CRUD, add venue accounts, sales/orders/offers oversight, support inbox |

Venue accounts are **not self-serve** — an admin creates the store + login via **Add Venue** (edge function `admin-create-venue`).

---

## Features (by area)

### Customer
- Offers feed (search, category, sort: price, rating, distance, favourites, best deal)
- Stores list & detail, map explore
- Checkout (**demo payment** — no real card charge)
- Orders + pickup codes; confirm pickup; rate store
- Favourites, notifications (orders / favourite offers)
- Profile: impact analytics, language (EN / KA), password

### Venue
- My Products — create / edit / remove baskets
- Incoming orders — mark ready / picked up / cancel
- Analytics tab
- Store appearance (logo upload to Storage)

### Admin
- Dashboard stats, Stores, Add Venue
- Admin Panel: sales, orders, offers, users, statistics
- **Support chat** inbox — two-way messaging with customers and venues (admin can start a chat)

### Shared
- Floating glass tab bar; pull-to-refresh on main lists
- Push notifications (device tokens + `send-push-notification` function)
- In-app support chat (Help Center for users; Admin Panel / Alerts for admins)

---

## Architecture

```
PresentationLayer  →  DomainLayer (use cases)  →  DataLayer (gateways)  →  NetworkLayer (Supabase client)
         ↑
        App (AppContainer, AppState, ContentView)
```

| Layer | Responsibility |
|-------|----------------|
| **NetworkLayer** | Shared `SupabaseClient` only |
| **DataLayer** | API models, `Api*Gateway` implementations |
| **DomainLayer** | Domain models, gateway protocols, use cases |
| **PresentationLayer** | SwiftUI views + `@Observable` view models |
| **App** | Composition root (`AppContainer`), session/`AppState` |

Views depend on **use cases**, not Supabase types.

Xcode project: `Namtsetsoba/Namtsetsoba.xcodeproj`

---

## Tech stack

- SwiftUI, Observation (`@Observable`)
- Supabase Swift SDK (Auth, PostgREST, Storage, Functions)
- MapKit / CoreLocation (store map & distance sort)
- Localization: English + Georgian (`L10n` / `Translations`)

---

## Project layout

```
Namcecoba-App/
├── Namtsetsoba/                 # Xcode app
│   └── Namtsetsoba/
│       ├── App/                 # AppContainer, AppState, ContentView
│       ├── NetworkLayer/
│       ├── DataLayer/
│       ├── DomainLayer/
│       └── PresentationLayer/   # Auth, Home, Stores, Orders, Admin, Support, …
├── supabase/functions/          # Edge Functions
│   ├── admin-create-venue/
│   ├── send-push-notification/
│   └── submit-support-request/
├── index.html / public/         # Auth email redirect landing (GitHub Pages)
├── tools/                       # e.g. sync_project.rb
└── README.md
```

---

## Getting started

### Requirements
- Xcode (recent stable) with iOS Simulator or device
- A Supabase project with schema, RLS, Storage buckets, and Edge Functions deployed

### Run the app
1. Open `Namtsetsoba/Namtsetsoba.xcodeproj`
2. Set team/signing if needed
3. Confirm Supabase URL + anon key in `NetworkLayer/SupabaseClientProvider.swift`
4. Build & run (`Namtsetsoba` scheme)

### Auth redirect
Password reset / email confirmation use:

`https://electrolizzys.github.io/Namcecoba-App/`

(`index.html` / `public/index.html` — publish via GitHub Pages.)

### Test accounts
Create manually in Supabase Auth + `profiles`:

1. Register a **customer** in the app  
2. Promote an admin: `update profiles set role = 'admin' where email = '…';`  
3. Create a **venue** from the admin **Add Venue** tab  

---

## Backend notes

- **Auth:** email/password in `auth.users`; app role & `store_id` in `profiles` (`id` = auth user id). Venue role in DB is `venue`.
- **Storage:** e.g. `store-logos` — set `stores.logo_url` to the public URL after upload.
- **Checkout:** demo mode; orders are created without real payment.
- **Support chat:** tables/RPC for conversations & messages (run your project’s support SQL in the Supabase SQL editor if not already applied). Admins message customers/venues in-thread; alerts use type `support`.
- **Edge Functions** (deploy with Supabase CLI / dashboard):
  - `admin-create-venue` — store + venue auth user + profile  
  - `send-push-notification` — push on notification insert  
  - `submit-support-request` — legacy/fallback one-shot support submit  

---

## Localization

UI strings go through `L(.key)` with EN/KA dictionaries in `PresentationLayer/Common/Localization/`. Switching language in Profile rebuilds the UI immediately.

---

## Conventions

- Prefer use cases from `AppContainer.shared` (inject in tests)
- Keep Supabase/`Api*` types out of views
- Match existing design tokens (`DesignTokens`) and list/scroll fillers for the floating tab bar
- Don’t commit secrets outside the established client config pattern; prefer env/`Secrets.xcconfig` for new secrets (see `.gitignore`)

---

## License / status

Student / course project for Namtsetsoba surplus-food marketplace. Not production payment-ready.
