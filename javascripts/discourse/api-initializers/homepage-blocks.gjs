import { apiInitializer } from "discourse/lib/api";
import BlockHome from "../blocks/block-home.gjs";

export default apiInitializer((api) => {
  api.renderBlocks("homepage-blocks", [
    {
      block: BlockHome,
      id: "home",
      args: {
        title: "home.title",
        subtitle: "home.subtitle",
        primaryLabel: "home.primary",
        primaryUrl: settings.homepage_primary_url,
        secondaryLabel: "home.secondary",
        secondaryUrl: settings.homepage_secondary_url,
        latestTitle: "home.latest",
        latestLinkLabel: "home.latest_link",
        count: settings.homepage_latest_count,
      },
    },
  ]);
});
