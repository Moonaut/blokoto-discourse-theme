import { apiInitializer } from "discourse/lib/api";

const CHANNELS_SECTION = "chat-channels";

export default apiInitializer((api) => {
  const expandChannels = () => {
    api.container
      .lookup("service:sidebar-state")
      ?.expandSection(CHANNELS_SECTION);
  };

  expandChannels();
  api.onPageChange(expandChannels);
});
