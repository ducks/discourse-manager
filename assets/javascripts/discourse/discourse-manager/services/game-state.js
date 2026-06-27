import Service from "@ember/service";
import { tracked } from "@glimmer/tracking";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";

function meterColor(value) {
  if (value >= 70) return "green";
  if (value >= 40) return "yellow";
  return "red";
}

export default class GameStateService extends Service {
  @tracked sessionId = null;
  @tracked day = 1;
  @tracked score = 0;
  @tracked status = null;
  @tracked meters = { health: 100, response_time: 100, spam_rate: 0, retention: 100 };
  @tracked pendingFlags = [];
  @tracked pendingEvents = [];
  @tracked dayEndsAt = null;
  @tracked loading = true;

  async load() {
    this.loading = true;
    try {
      const data = await ajax("/discourse-manager/state");
      this.sessionId = data.id;
      this.onUpdate(data);
    } catch (e) {
      if (e.jqXHR?.status === 404) {
        await this.start();
      } else {
        popupAjaxError(e);
      }
    } finally {
      this.loading = false;
    }
  }

  async start() {
    this.loading = true;
    try {
      const data = await ajax("/discourse-manager/start", { type: "POST" });
      this.sessionId = data.session_id;
    } catch (e) {
      popupAjaxError(e);
    } finally {
      this.loading = false;
    }
  }

  onUpdate(data) {
    this.sessionId = data.id ?? this.sessionId;
    this.day = data.day;
    this.score = data.score;
    this.status = data.status;
    this.meters = data.meters;
    this.pendingFlags = data.pending_flags;
    this.pendingEvents = data.pending_events;
    this.dayEndsAt = data.day_ends_at ? new Date(data.day_ends_at) : null;
  }

  async submitAction(actionType, params = {}) {
    try {
      const data = await ajax("/discourse-manager/action", {
        type: "POST",
        data: { action_type: actionType, ...params },
      });
      this.onUpdate(data);
    } catch (e) {
      popupAjaxError(e);
    }
  }

  get isOver() {
    return this.status === "won" || this.status === "lost";
  }

  get healthColor() { return meterColor(this.meters.health); }
  get retentionColor() { return meterColor(this.meters.retention); }
  get spamRateColor() { return meterColor(100 - this.meters.spam_rate); }
  get responseTimeColor() { return meterColor(this.meters.response_time); }
}
