import Component from "@glimmer/component";
import { service } from "@ember/service";
import { action } from "@ember/object";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";

const FLAG_LABELS = {
  spam: "Spam",
  inappropriate: "Inappropriate",
  off_topic: "Off-topic",
  something_else: "Something else",
};

export default class FlagQueue extends Component {
  @service gameState;

  @action
  approveFlag(flag) {
    this.gameState.submitAction("approve_flag", { post_id: flag.id, user_id: flag.fake_user.id });
  }

  @action
  removePost(flag) {
    this.gameState.submitAction("remove_post", { post_id: flag.id, user_id: flag.fake_user.id });
  }

  @action
  warnUser(flag) {
    this.gameState.submitAction("warn_user", { post_id: flag.id, user_id: flag.fake_user.id });
  }

  @action
  suspendUser(flag) {
    this.gameState.submitAction("suspend_user", { post_id: flag.id, user_id: flag.fake_user.id });
  }

  @action
  banUser(flag) {
    this.gameState.submitAction("ban_user", { post_id: flag.id, user_id: flag.fake_user.id });
  }

  flagLabel(flagType) {
    return FLAG_LABELS[flagType] || flagType;
  }

  <template>
    <div class="dm-flag-queue">
      <h2 class="dm-flag-queue__heading">
        Review Queue
        <span class="dm-flag-queue__count">{{this.gameState.pendingFlags.length}}</span>
      </h2>

      {{#if this.gameState.pendingFlags.length}}
        {{#each this.gameState.pendingFlags as |flag|}}
          <div class="dm-flag-item">
            <div class="dm-flag-item__user">
              <span
                class="dm-avatar"
                style="background-color: {{flag.fake_user.avatar_color}}"
              >{{flag.fake_user.letter}}</span>
              <div class="dm-flag-item__user-info">
                <span class="dm-flag-item__username">{{flag.fake_user.username}}</span>
                <span class="dm-flag-item__trust">TL{{flag.fake_user.trust_level}}</span>
                {{#if flag.fake_user.warnings}}
                  <span class="dm-flag-item__warnings">{{flag.fake_user.warnings}} warnings</span>
                {{/if}}
              </div>
            </div>

            <div class="dm-flag-item__content">
              {{#if flag.topic_title}}
                <p class="dm-flag-item__topic">{{flag.topic_title}}</p>
              {{/if}}
              <p class="dm-flag-item__body">{{flag.body}}</p>
              <span class="dm-flag-item__type dm-flag-item__type--{{flag.flag_type}}">
                {{this.flagLabel flag.flag_type}}
              </span>
            </div>

            <div class="dm-flag-item__actions">
              <button class="btn btn-default" {{on "click" (fn this.approveFlag flag)}}>Approve</button>
              <button class="btn btn-danger"  {{on "click" (fn this.removePost flag)}}>Remove</button>
              <button class="btn btn-default" {{on "click" (fn this.warnUser flag)}}>Warn</button>
              <button class="btn btn-default" {{on "click" (fn this.suspendUser flag)}}>Suspend</button>
              <button class="btn btn-danger"  {{on "click" (fn this.banUser flag)}}>Ban</button>
            </div>
          </div>
        {{/each}}
      {{else}}
        <p class="dm-flag-queue__empty">Queue is clear. Enjoy it while it lasts.</p>
      {{/if}}
    </div>
  </template>
}
