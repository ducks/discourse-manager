import { withPluginApi } from "discourse/lib/plugin-api";

export default {
  name: "discourse-manager",

  initialize() {
    withPluginApi("2.0.0", () => {
      // plugin loaded
    });
  },
};
