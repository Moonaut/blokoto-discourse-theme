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
        eventsCount: settings.homepage_events_count,
        hotCount: settings.homepage_hot_count,
        contributorsCount: settings.homepage_contributors_count,
        blokreationsCategory: settings.homepage_blokreations_category,
        blokreationsCount: settings.homepage_blokreations_count,
      },
    },
  ]);
});
