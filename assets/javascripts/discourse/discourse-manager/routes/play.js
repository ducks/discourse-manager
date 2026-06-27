import Route from "@ember/routing/route";
import { service } from "@ember/service";

export default class PlayRoute extends Route {
  @service gameState;
  @service messageBus;

  async model() {
    await this.gameState.load(this.messageBus);
  }

  deactivate() {
    this.gameState.unsubscribe(this.messageBus);
  }
}
