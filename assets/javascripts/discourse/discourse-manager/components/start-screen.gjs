import Component from "@glimmer/component";
import { service } from "@ember/service";
import { action } from "@ember/object";
import { on } from "@ember/modifier";

export default class StartScreen extends Component {
  @service gameState;

  @action
  async start() {
    await this.gameState.start();
  }

  <template>
    <div class="dm-start">
      <div class="dm-start__card">
        <h1 class="dm-start__title">discourse-manager</h1>
        <p class="dm-start__subtitle">You are the moderator.</p>

        <div class="dm-start__description">
          <p>
            A community of strangers needs you. Flags are coming in. Spam
            accounts are registering. Someone is about to post something
            that will generate 30 flags in 60 seconds.
          </p>
          <p>Keep the community healthy for 30 days.</p>
        </div>

        <div class="dm-start__meters-preview">
          <div class="dm-start__meter">
            <span>Community Health</span>
            <div class="dm-meter__bar"><div class="dm-meter__fill dm-meter__fill--green" style="width: 100%"></div></div>
          </div>
          <div class="dm-start__meter">
            <span>Response Time</span>
            <div class="dm-meter__bar"><div class="dm-meter__fill dm-meter__fill--green" style="width: 100%"></div></div>
          </div>
          <div class="dm-start__meter">
            <span>Spam Rate</span>
            <div class="dm-meter__bar"><div class="dm-meter__fill dm-meter__fill--green" style="width: 0%"></div></div>
          </div>
          <div class="dm-start__meter">
            <span>User Retention</span>
            <div class="dm-meter__bar"><div class="dm-meter__fill dm-meter__fill--green" style="width: 100%"></div></div>
          </div>
        </div>

        <button class="btn btn-primary dm-start__btn" {{on "click" this.start}}>
          Start Day 1
        </button>

        <p class="dm-start__hint">
          Approve flags, warn users, suspend bad actors. Don't over-moderate
          or you'll lose retention. Don't under-moderate or you'll lose everything else.
        </p>
      </div>
    </div>
  </template>
}
