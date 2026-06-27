import Route from "@ember/routing/route";
import { service } from "@ember/service";

export default class PlayRoute extends Route {
  @service gameState;
  @service messageBus;

  async model() {
    await this.gameState.load();
  }

  activate() {
    if (!this.gameState.sessionId) return;
    this.messageBus.subscribe(
      `/discourse-manager/session/${this.gameState.sessionId}`,
      (data) => this.gameState.onUpdate(data)
    );
  }

  deactivate() {
    if (!this.gameState.sessionId) return;
    this.messageBus.unsubscribe(
      `/discourse-manager/session/${this.gameState.sessionId}`
    );
  }
}
