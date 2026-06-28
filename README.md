# discourse-manager

A community management sim that runs inside Discourse. You play as the moderator of a fake but realistic-looking forum - handling flags, bad actors, spam waves, and technical incidents - while keeping your community healthy for 30 days.

![discourse-manager screenshot](docs/screenshot.png)

## How it works

Fake users, fake posts, and fake drama are generated inside your Discourse instance and rendered with real Discourse UI components. It looks and feels identical to live forum activity.

You manage four meters:

- **Community Health** - degrades when flags pile up unresolved
- **Response Time** - how fast you're clearing the queue
- **Spam Rate** - climbs when spammer accounts aren't dealt with
- **User Retention** - drops when you over-moderate or let chaos reign

Each day is timed. Survive 30 days to win.

## Gameplay

**Flag queue** - Every flagged post shows the user profile, trust level, warning history, post body, and flag type. You can approve, remove, warn, suspend, or ban.

**Events** - Random events fire throughout the day and require a decision. Each resolution has different tradeoffs across the meters.

Community events:
- Viral topic exploding with flags
- Sockpuppet wave of new spam accounts
- Staff conflict in a public thread
- Spam flood
- Broken plugin with complaints mounting
- Great newcomer worth recognizing
- External link spike bringing new registrations

Technical incidents:
- Bad plugin update breaking features
- Server outage
- Database migration failure
- CDN failure breaking images sitewide
- Accidental data wipe

**Day summary** - At the end of each day you see what you resolved before moving on.

**Score persistence** - Your high score and best day are saved. A leaderboard shows top scores across the instance.

## Install

Clone into your Discourse plugins directory and restart:

```bash
cd /var/www/discourse/plugins
git clone https://github.com/ducks/discourse-manager
bundle exec rake db:migrate
```

Then enable the `discourse_manager_enabled` site setting and visit `/play`.

## Development

Uses [dv](https://github.com/discourse/dv) to manage Discourse dev containers.

```bash
# create a container with the plugin mounted
dv new discourse-manager-test --plugin-local /path/to/discourse-manager

# run migrations after pulling changes
dv run -- bundle exec rake db:migrate

# restart after Ruby changes
dv restart
```

A `shell.nix` is included for Nix users:

```bash
nix-shell
```

## Architecture

- `plugin.rb` - routes, requires, site setting
- `app/models/discourse_manager/`
  - `game_session.rb` - core game state, tick loop, meter logic
  - `event_registry.rb` - all event types in one place; add a new event by adding one entry here
  - `game_event.rb` - AR model delegating to the registry
  - `fake_user.rb` / `fake_post.rb` - generated community content
  - `user_stat.rb` - score persistence per user
- `app/jobs/` - Sidekiq jobs for tick advancement and fake data generation
- `assets/javascripts/discourse/discourse-manager/`
  - `services/game-state.js` - tracked state, MessageBus subscription
  - `components/` - play-page, game-hud, flag-queue, event-card, day-summary, start-screen
- Real-time updates via MessageBus push from server to client

## Status

Working prototype. Core loop is solid - flag queue, meter decay, event system, day transitions, score persistence, real-time updates. Not yet in production anywhere.
