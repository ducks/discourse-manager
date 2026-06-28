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
  @tracked daySummary = null;
  @tracked myStats = null;
  @tracked leaderboard = [];
  @tracked loading = true;
  @tracked hasSession = false;

  #messageBus = null;
  #channel = null;

  async load(messageBus) {
    this.#messageBus = messageBus;
    this.loading = true;
    try {
      const [stateResult, statsResult] = await Promise.allSettled([
        ajax("/discourse-manager/state"),
        ajax("/discourse-manager/my-stats"),
      ]);

      if (statsResult.status === "fulfilled") {
        this.myStats = statsResult.value;
      }

      if (stateResult.status === "fulfilled") {
        this.hasSession = true;
        this.onUpdate(stateResult.value);
        this.#subscribe();
      } else if (stateResult.reason?.jqXHR?.status === 404) {
        this.hasSession = false;
      } else {
        popupAjaxError(stateResult.reason);
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
      this.status = "generating";
      this.hasSession = true;
      this.#subscribe();
    } catch (e) {
      popupAjaxError(e);
    } finally {
      this.loading = false;
    }
  }

  unsubscribe(messageBus) {
    if (this.#channel) {
      messageBus.unsubscribe(this.#channel);
      this.#channel = null;
    }
  }

  #subscribe() {
    if (!this.#messageBus || !this.sessionId) return;
    this.#channel = `/discourse-manager/session/${this.sessionId}`;
    this.#messageBus.subscribe(this.#channel, (data) => this.onUpdate(data));
  }

  onUpdate(data) {
    const wasOver = this.isOver;
    this.sessionId = data.id ?? this.sessionId;
    this.day = data.day;
    this.score = data.score;
    this.status = data.status;
    this.meters = data.meters;
    this.pendingFlags = data.pending_flags;
    this.pendingEvents = data.pending_events;
    this.dayEndsAt = data.day_ends_at ? new Date(data.day_ends_at) : null;
    this.daySummary = data.day_summary ?? null;
    if (!wasOver && this.isOver) {
      this.#fetchLeaderboard();
    }
  }

  async #fetchLeaderboard() {
    try {
      const [board, stats] = await Promise.all([
        ajax("/discourse-manager/leaderboard"),
        ajax("/discourse-manager/my-stats"),
      ]);
      this.leaderboard = board;
      this.myStats = stats;
    } catch {
      // non-critical, ignore
    }
  }

  async nextDay() {
    try {
      const data = await ajax("/discourse-manager/next-day", { type: "POST" });
      this.onUpdate(data);
    } catch (e) {
      popupAjaxError(e);
    }
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

  get nextDayNumber() {
    return (this.day ?? 1) + 1;
  }

  get healthColor() { return meterColor(this.meters.health); }
  get retentionColor() { return meterColor(this.meters.retention); }
  get spamRateColor() { return meterColor(100 - this.meters.spam_rate); }
  get responseTimeColor() { return meterColor(this.meters.response_time); }
}
