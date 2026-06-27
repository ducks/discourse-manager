import Component from "@glimmer/component";
import { service } from "@ember/service";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { modifier } from "ember-modifier";

export default class GameHud extends Component {
  @service gameState;
  @tracked timeLeft = "--:--";

  #timer = null;

  startTimer = modifier(() => {
    this.#tick();
    this.#timer = setInterval(() => this.#tick(), 1000);
    return () => clearInterval(this.#timer);
  });

  #tick() {
    const { dayEndsAt } = this.gameState;
    if (!dayEndsAt) {
      this.timeLeft = "--:--";
      return;
    }
    const diff = Math.max(0, Math.floor((dayEndsAt - Date.now()) / 1000));
    const m = Math.floor(diff / 60).toString().padStart(2, "0");
    const s = (diff % 60).toString().padStart(2, "0");
    this.timeLeft = `${m}:${s}`;
  }

  get meters() {
    const { meters } = this.gameState;
    return [
      { label: "Community Health", value: meters.health,        color: this.gameState.healthColor },
      { label: "Response Time",    value: meters.response_time, color: this.gameState.responseTimeColor },
      { label: "Spam Rate",        value: meters.spam_rate,     color: this.gameState.spamRateColor, inverted: true },
      { label: "User Retention",   value: meters.retention,     color: this.gameState.retentionColor },
    ];
  }

  <template>
    <div class="dm-hud" {{this.startTimer}}>
      <div class="dm-hud__meta">
        <span class="dm-hud__day">Day {{this.gameState.day}}</span>
        <span class="dm-hud__score">Score: {{this.gameState.score}}</span>
        <span class="dm-hud__timer">{{this.timeLeft}}</span>
      </div>
      <div class="dm-hud__meters">
        {{#each this.meters as |meter|}}
          <div class="dm-meter dm-meter--{{meter.color}}">
            <span class="dm-meter__label">{{meter.label}}</span>
            <div class="dm-meter__bar">
              <div class="dm-meter__fill" style="width: {{meter.value}}%"></div>
            </div>
            <span class="dm-meter__value">{{meter.value}}</span>
          </div>
        {{/each}}
      </div>
    </div>
  </template>
}
