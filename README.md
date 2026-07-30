# Namcecoba-App

iOS app for surplus-food surprise bags (Namtsetsoba).

## Architecture

Clean architecture with strict layer boundaries:

- **NetworkLayer** — Supabase client only
- **DataLayer** — API models and gateways
- **DomainLayer** — models, gateway protocols, use cases
- **PresentationLayer** — SwiftUI views + MVVM view models
- **App** — composition root (`AppContainer`, `AppState`)

Presentation talks to domain use cases only; no Supabase types above the data layer.

## Backend

Supabase project (Auth, Postgres, Storage, Edge Functions under `supabase/functions/`).
Email confirmation / password-recovery landing page: `index.html` (published via GitHub Pages; `public/index.html` mirrors it).
