import Component from "@glimmer/component";
import { service } from "@ember/service";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { eq } from "truth-helpers";
import GameHud from "./game-hud";
import FlagQueue from "./flag-queue";
import EventCard from "./event-card";
import StartScreen from "./start-screen";
import DaySummary from "./day-summary";

export default class PlayPage extends Component {
  @service gameState;

  @action
  restart() {
    this.gameState.start();
  }

  <template>
    <div class="dm-play">
      {{#if this.gameState.loading}}
        <div class="dm-loading">
          <p>Loading...</p>
        </div>
      {{else if (eq this.gameState.status "generating")}}
        <div class="dm-loading">
          <p>Generating your community...</p>
        </div>
      {{else if this.gameState.isOver}}
        <div class="dm-game-over">
          {{#if (eq this.gameState.status "won")}}
            <h1>Community Thriving</h1>
            <p>You survived {{this.gameState.day}} days. Final score: {{this.gameState.score}}</p>
          {{else}}
            <h1>Community Collapsed</h1>
            <p>You made it to day {{this.gameState.day}}. Final score: {{this.gameState.score}}</p>
          {{/if}}

          {{#if this.gameState.myStats}}
            <div class="dm-game-over__personal">
              <p>Personal best: <strong>{{this.gameState.myStats.high_score}}</strong> &middot; Best day: <strong>{{this.gameState.myStats.best_day}}</strong> &middot; Games played: <strong>{{this.gameState.myStats.games_played}}</strong></p>
            </div>
          {{/if}}

          {{#if this.gameState.leaderboard.length}}
            <div class="dm-leaderboard">
              <h3>Leaderboard</h3>
              <ol class="dm-leaderboard__list">
                {{#each this.gameState.leaderboard as |entry|}}
                  <li class="dm-leaderboard__entry">
                    <span class="dm-leaderboard__username">{{entry.username}}</span>
                    <span class="dm-leaderboard__score">{{entry.high_score}}</span>
                    <span class="dm-leaderboard__day">day {{entry.best_day}}</span>
                  </li>
                {{/each}}
              </ol>
            </div>
          {{/if}}

          <button class="btn btn-primary" {{on "click" this.restart}}>Play Again</button>
        </div>
      {{else if (eq this.gameState.status "day_end")}}
        <DaySummary />
      {{else if this.gameState.hasSession}}
        <GameHud />
        <EventCard />
        <div class="dm-main">
          <FlagQueue />
        </div>
      {{else}}
        <StartScreen />
      {{/if}}
    </div>
  </template>
}
