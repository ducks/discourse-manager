import Component from "@glimmer/component";
import { service } from "@ember/service";

export default class GameHud extends Component {
  @service gameState;

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
    <div class="dm-hud">
      <div class="dm-hud__meta">
        <span class="dm-hud__day">Day {{this.gameState.day}}</span>
        <span class="dm-hud__score">Score: {{this.gameState.score}}</span>
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
