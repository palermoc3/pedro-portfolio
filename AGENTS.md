# AI Agent Guidance for `pedro-portfolio`

## Purpose
This file tells AI coding agents how to be productive in this Rails portfolio repository.

## Key repository facts
- Ruby on Rails application using Rails `~> 8.1.1`.
- Tailwind CSS installed via `tailwindcss-rails`.
- Authentication expected with Devise.
- Charts should use `chartkick` and a JavaScript charting backend.
- External API integration should use `httparty`.
- Current `Gemfile` includes `sqlite3` for development/test and `pg` only in production.
- The user’s active project plan is in `PROMPT.md`; follow it as the authoritative roadmap.

## Primary workflow
1. Read `PROMPT.md` before making any feature changes.
2. Implement the project one step at a time, exactly as the prompt describes.
3. Before running any command, explain what it does and why it is needed.
4. After each step, report what changed and ask the user whether to continue.
5. If an error is encountered, stop and diagnose it before proceeding.

## Important conventions
- Preserve the dark design palette and naming defined in `PROMPT.md`.
- Keep implementations responsive, mobile-first, and Tailwind-based.
- The user expects explanations of data/model design decisions, not just code changes.
- When creating models, explicitly show the resulting schema and explain each column.

## Build and test commands
- Start application locally: `bin/rails server`
- Run tests: `bin/rails test`
- Run system tests: `bin/rails test:system`
- Lint Ruby code: `bin/rubocop -f github`
- Security scans: `bin/brakeman`, `bin/bundler-audit`
- JavaScript dependency audit: `bin/importmap audit`

## Relevant files and directories
- `PROMPT.md` — project plan and user instructions.
- `config/database.yml` — current database setup uses SQLite and unusual multiple production databases.
- `.github/workflows/ci.yml` — CI pipeline and test commands.
- `app/` — controllers, models, views, services.
- `app/services/` — target location for API integration service objects.
- `app/views/` — place to customize Devise templates and dashboard views.
- `config/routes.rb` — add public home and dashboard routes.

## How to use this guidance
- Prefer `AGENTS.md` as the rulebook for coding behavior in this repository.
- Do not overwrite the user’s prompt in `PROMPT.md`; link to it for details.
- If a requested task is outside the prompt plan, ask the user first.

## Notes for future customization
- This repository does not currently have `.github/copilot-instructions.md` or AGENT-specific files.
- If more detailed role-specific guidance is needed, consider adding separate instruction files for frontend and backend tasks.
