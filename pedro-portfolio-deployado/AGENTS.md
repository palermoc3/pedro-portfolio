# AI Agent Guidance for `pedro-portfolio`

## Purpose

This file tells AI coding agents how to be productive in this public Rails portfolio repository.

## Key Repository Facts

- Ruby on Rails application using Rails `~> 8.1.1`.
- Tailwind CSS installed via `tailwindcss-rails`.
- The app is public and does not use authentication.
- There is no `User` model and no `users` table.
- The dashboard is public at `/dashboard`.
- Customer data is served through `/api/customers` from `public/customers_kaminari.json`.
- Current `Gemfile` includes `sqlite3` for development/test and `pg` only in production.

## Primary Workflow

1. Read the current README and tests before changing behavior.
2. Keep the app portfolio-focused and public.
3. Preserve responsive dark UI conventions.
4. Run `bin/rails test` after Rails changes.

## Build And Test Commands

- Start application locally: `bin/rails server`
- Run tests: `bin/rails test`
- Run system tests: `bin/rails test:system`
- Lint Ruby code: `bin/rubocop -f github`
- Security scans: `bin/brakeman`, `bin/bundler-audit`
- JavaScript dependency audit: `bin/importmap audit`

## Visual CSS Checks

- When changing layout, dashboard, or Tailwind styles, validate the page visually with Chromium/Selenium when possible.
- Chromium headless is useful for quick screenshots of `/dashboard` after starting Rails locally.
- Selenium/Chrome may need explicit approval outside the sandbox because it can manage ChromeDriver/cache or touch browser-level resources. Ask for that approval when a visual CSS check matters.
- For dashboard work, capture the chart area after the loader delay to confirm the loading overlay, Plotly rendering, spacing, and responsive layout.

## Relevant Files And Directories

- `app/views/dashboard/index.html.erb` — public dashboard UI.
- `app/controllers/api/customers_controller.rb` — Kaminari-compatible customers endpoint.
- `public/customers_kaminari.json` — generated customers/dashboard payload.
- `config/routes.rb` — public home, dashboard, KPI and API routes.
- `db/migrate/20260712234500_remove_users_for_public_portfolio.rb` — removes legacy `users` table.
