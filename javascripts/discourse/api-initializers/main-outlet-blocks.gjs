import { apiInitializer } from "discourse/lib/api";
import BlockCategoryBanner from "../blocks/block-category-banner.gjs";
import BlockHero from "../blocks/block-hero.gjs";

export default apiInitializer((api) => {
  const bannerCategoryIds = (settings.category_banner_category_ids ?? "")
    .split("|")
    .filter(Boolean)
    .map(Number);

  api.renderBlocks("main-outlet-blocks", [
    {
      block: BlockHero,
      id: "hero",
      args: {
        eyebrow: "hero.eyebrow",
        title: "hero.title",
        subtitle: "hero.subtitle",
        primaryLabel: "hero.primary",
        primaryUrl: settings.hero_primary_url,
        secondaryLabel: "hero.secondary",
        secondaryUrl: settings.hero_secondary_url,
      },
      conditions: { type: "route", pages: ["HOMEPAGE"] },
    },
    {
      block: BlockCategoryBanner,
      id: "category-banner",
      args: {
        categoryIds: bannerCategoryIds,
        showDescription: settings.category_banner_show_description,
      },
      conditions: { type: "route", pages: ["CATEGORY_PAGES"] },
    },
  ]);
});
