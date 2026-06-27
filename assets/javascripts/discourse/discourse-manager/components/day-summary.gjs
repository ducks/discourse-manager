import Component from "@glimmer/component";
import { service } from "@ember/service";
import { action } from "@ember/object";
import { on } from "@ember/modifier";

export default class DaySummary extends Component {
  @service gameState;

  @action
  async nextDay() {
    await this.gameState.nextDay();
  }

  <template>
    <div class="dm-day-summary">
      <div class="dm-day-summary__card">
        <h2 class="dm-day-summary__title">Day {{this.gameState.day}} Complete</h2>

        <div class="dm-day-summary__stats">
          <div class="dm-day-summary__stat">
            <span class="dm-day-summary__stat-value">{{this.gameState.daySummary.flags_resolved}}</span>
            <span class="dm-day-summary__stat-label">Flags Resolved</span>
          </div>
          <div class="dm-day-summary__stat">
            <span class="dm-day-summary__stat-value">{{this.gameState.daySummary.users_banned}}</span>
            <span class="dm-day-summary__stat-label">Users Banned</span>
          </div>
          <div class="dm-day-summary__stat">
            <span class="dm-day-summary__stat-value">{{this.gameState.daySummary.events_handled}}</span>
            <span class="dm-day-summary__stat-label">Events Handled</span>
          </div>
          <div class="dm-day-summary__stat">
            <span class="dm-day-summary__stat-value">{{this.gameState.daySummary.score}}</span>
            <span class="dm-day-summary__stat-label">Score</span>
          </div>
        </div>

        <div class="dm-day-summary__health">
          Community health: <strong>{{this.gameState.daySummary.health}}</strong>
        </div>

        <button class="btn btn-primary dm-day-summary__btn" {{on "click" this.nextDay}}>
          Start Day {{this.gameState.nextDayNumber}}
        </button>
      </div>
    </div>
  </template>
}
