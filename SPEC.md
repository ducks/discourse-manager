# discourse-manager

A Discourse plugin that turns your forum into a community management sim. You play
as the mod of a fake but realistic-looking forum, handling flags, bad actors,
topic creation, and user management under time pressure while keeping the community
healthy.

## Concept

Inspired by "You are the OS" - but you are the community manager. Fake users, fake
posts, and fake drama are generated inside your real Discourse instance and rendered
with actual Discourse components. It looks and feels identical to real forum
activity.

The game runs at `/play` - a dedicated route that boots the sim. Real forum
activity is untouched.

## Core mechanics

### Resource bars

Four meters the player must keep in the green:

- **Community health** - degrades when flags go unresolved, spam accumulates, or
  good users leave. Hits zero = game over.
- **Mod response time** - how fast you're clearing the queue. Slow response
  emboldens bad actors, spawns more flags.
- **Spam rate** - number of low-quality/spam posts as a % of total. Spikes when
  troll accounts aren't dealt with early.
- **User retention** - legitimate users leave if the community feels out of
  control or if you over-moderate. Chilling effect.

### The mod queue

Flags arrive in real time. Each flag is a decision:

- **Approve** - post stands, flag dismissed
- **Remove** - post deleted
- **Warn** - post stands, user gets a warning PM
- **Suspend** - user suspended for N days
- **Ban** - user removed permanently (careful - false bans tank retention)

Speed matters. A flag sitting unresolved for too long costs community health.

### Actions

Beyond the queue, the player can:

- **Create a topic** - seed discussion to boost health (costs time)
- **Pin a topic** - surface important content
- **Promote a user** - bump trust level, creates a new mod ally who auto-handles
  some flags
- **Send a PM** - reach out to a user on the edge before they become a problem
- **Close a topic** - stop a thread that's going sideways before it generates more flags
- **Merge topics** - clean up duplicate threads

### Event system

Random events interrupt the queue at increasing frequency as the game progresses:

- A spicy topic goes viral - 20 flags in 60 seconds
- A troll creates 8 sockpuppet accounts
- A long-standing member posts something controversial
- A plugin (fake) breaks - users are complaining in meta
- A new user asks a great question that needs a welcoming response
- Staff conflict - two high-trust users are fighting in a thread
- Spam wave - 15 accounts register in a minute
- A topic gets linked from outside - traffic spike, new registrations

Events have multiple resolution paths with different tradeoffs.

### Progression

- **Day structure** - each "day" is a timed session (3-5 min). Survive the day,
  next day starts harder.
- **Forum growth** - community size grows over days, more users = more flags =
  more events
- **Difficulty scaling** - event frequency and severity increase. Spam waves get
  bigger. Sockpuppet networks get more sophisticated.
- **Unlocks** - survive enough days to unlock new tools (auto-mod rules, trust
  level gates, category permissions)

### Win / lose

- Lose: any resource bar hits zero
- Win: survive N days (TBD - maybe 30 for a "thriving community" ending)
- Score: composite of avg health bars + days survived + actions taken

## Fake data generation

All game content is generated - no real user data involved.

### Users

Generated on game start and throughout play:

- Username (realistic but fake)
- Avatar (letter avatar with color, same as Discourse default)
- Trust level (0-4)
- Join date
- Post count
- Behavioral profile: lurker, contributor, troll, spammer, good-faith newbie

### Posts and topics

LLM-generated at game start, seeded into the sim's state. Categories mirror a
typical Discourse forum: General, Meta, Support, Announcements. Post content
should feel authentic - forum drama, support questions, off-topic tangents.

Generation happens server-side once on game init, stored in plugin tables, not
re-generated each session.

### Flags

Generated based on post content and user behavioral profiles. A spammer's posts
get flagged as spam. A troll's posts get flagged as inappropriate. Occasionally
legitimate posts get flagged incorrectly (player must judge).

## Technical architecture

### Plugin structure

```
discourse-manager/
├── plugin.rb
├── app/
│   ├── controllers/
│   │   └── discourse_manager/game_controller.rb
│   ├── models/
│   │   ├── discourse_manager/game_session.rb
│   │   ├── discourse_manager/fake_user.rb
│   │   ├── discourse_manager/fake_post.rb
│   │   └── discourse_manager/game_event.rb
│   └── jobs/
│       └── discourse_manager/event_scheduler.rb
├── assets/javascripts/discourse/
│   └── discourse-manager/
│       ├── routes/play.js
│       ├── components/
│       │   ├── game-hud.js        # resource bars
│       │   ├── flag-queue.js      # the main action surface
│       │   ├── event-card.js      # interrupt events
│       │   └── action-panel.js    # create topic, promote user, etc.
│       └── services/
│           └── game-state.js      # client-side game loop
├── config/
│   └── routes.rb
└── db/migrate/
    ├── create_game_sessions.rb
    ├── create_fake_users.rb
    ├── create_fake_posts.rb
    └── create_game_events.rb
```

### Data model

**game_sessions** - one per play session
- user_id, started_at, ended_at, score, day, health, response_time, spam_rate, retention

**fake_users** - generated fake community members
- username, display_name, avatar_color, trust_level, behavioral_profile, joined_day

**fake_posts** - generated content
- fake_user_id, topic_title, body, category, created_at, flagged, flag_type, resolved

**game_events** - scheduled and fired events
- game_session_id, event_type, fired_at, resolved_at, resolution

### Game loop

- Server: Rails job fires every N seconds, advances game state, generates new
  flags/events, pushes updates via MessageBus
- Client: Listens on MessageBus channel `/discourse-manager/session/:id`, updates
  HUD and queue in real time
- Player actions hit a REST API (`/discourse-manager/action`) that updates game
  state and returns new state

### Routes

- `GET /play` - game shell (Ember route)
- `POST /discourse-manager/start` - init a new session, generate fake data
- `POST /discourse-manager/action` - submit a player action
- `GET /discourse-manager/state` - current game state (polling fallback)

## UI

The game UI lives at `/play` and mimics the Discourse mod interface:

- Top bar: resource meters (health, response time, spam rate, retention) with
  color coding (green/yellow/red)
- Main panel: flag queue, styled like the real review queue
- Right sidebar: recent activity feed, upcoming events hint
- Event cards: modal-style interrupts that pause the queue until resolved
- Day timer: countdown to end of day in the top bar

Fake posts render with real Discourse post components where possible - avatars,
usernames, post bodies, action buttons. The intent is that it looks like the
real thing at a glance.

## Out of scope (v1)

- Multiplayer
- Real user data involvement
- Persistent leaderboard (maybe v2)
- Mobile layout
- Actual LLM calls at runtime (content pre-generated)
