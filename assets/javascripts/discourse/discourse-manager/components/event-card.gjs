import Component from "@glimmer/component";
import { service } from "@ember/service";
import { action } from "@ember/object";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";

const RESOLUTION_LABELS = {
  close_topic:            "Close the topic",
  let_it_ride:            "Let it play out",
  pin_response:           "Pin a moderator response",
  ban_all:                "Ban all accounts",
  investigate:            "Investigate first",
  ignore:                 "Ignore for now",
  mediate:                "Step in and mediate",
  take_sides:             "Take a side",
  mass_remove:            "Remove all spam posts",
  silently_delete:        "Delete silently",
  warn_all:               "Warn the accounts",
  post_update:            "Post a status update",
  rollback_plugin:        "Roll back the plugin",
  welcome:                "Send a welcome reply",
  promote_tl1:            "Promote to TL1",
  pin_welcome_topic:      "Pin a welcome topic",
  lock_registrations:     "Temporarily lock registrations",
  do_nothing:             "Do nothing",
  rollback_update:        "Roll back the update",
  hotfix_live:            "Push a hotfix (risky)",
  post_status_update:     "Post a status update",
  escalate_immediately:   "Escalate immediately",
  post_maintenance_notice: "Post a maintenance notice",
  wait_and_see:           "Wait and see",
  restore_backup:         "Restore from backup",
  disable_writes:         "Disable writes temporarily",
  communicate_openly:     "Communicate openly with users",
  purge_cdn_cache:        "Purge the CDN cache",
  switch_cdn_provider:    "Switch CDN provider",
  post_workaround:        "Post a workaround for users",
  restore_from_backup:    "Restore from backup",
  notify_users:           "Notify affected users",
  cover_it_up:            "Hope nobody notices",
};

export default class EventCard extends Component {
  @service gameState;

  @action
  resolve(event, resolution) {
    this.gameState.submitAction("resolve_event", { event_id: event.id, resolution });
  }

  <template>
    {{#each this.gameState.pendingEvents as |event|}}
      <div class="dm-event-card dm-event-card--{{event.category}}">
        <div class="dm-event-card__header">
          <span class="dm-event-card__type dm-event-card__type--{{event.category}}">{{event.icon}} {{event.event_type}}</span>
        </div>
        <p class="dm-event-card__description">{{event.description}}</p>
        <div class="dm-event-card__actions">
          {{#each event.resolutions as |resolution|}}
            <button
              class="btn btn-default dm-event-card__resolution"
              {{on "click" (fn this.resolve event resolution)}}
            >
              {{RESOLUTION_LABELS.[resolution]}}
            </button>
          {{/each}}
        </div>
      </div>
    {{/each}}
  </template>
}
