import BlockGroup from "discourse/blocks/builtin/block-group";
import { apiInitializer } from "discourse/lib/api";
import BlockCategoryGrid from "../blocks/block-category-grid.gjs";
import BlockCta from "../blocks/block-cta.gjs";
import BlockLinks from "../blocks/block-links.gjs";
import BlockTopicGrid from "../blocks/block-topic-grid.gjs";

export default apiInitializer((api) => {
  const featuredTag = (settings.homepage_featured_tag ?? "")
    .split("|")
    .filter(Boolean)[0];

  const categoryIds = (settings.homepage_category_ids ?? "")
    .split("|")
    .filter(Boolean)
    .map(Number);

  api.renderBlocks("homepage-blocks", [
    {
      block: BlockCategoryGrid,
      id: "categories",
      args: {
        eyebrow: "homepage.categories.eyebrow",
        title: "homepage.categories.title",
        subtitle: "homepage.categories.subtitle",
        linkLabel: "homepage.categories.all",
        linkUrl: "/categories",
        categoryIds,
        count: settings.homepage_category_count,
      },
      conditions: {
        type: "setting",
        source: settings,
        name: "homepage_show_categories",
        enabled: true,
      },
    },
    {
      block: BlockTopicGrid,
      id: "featured",
      args: {
        eyebrow: "homepage.featured.eyebrow",
        title: "homepage.featured.title",
        subtitle: "homepage.featured.subtitle",
        linkLabel: "homepage.featured.link",
        linkUrl: `/tag/${encodeURIComponent(featuredTag ?? "")}`,
        tag: featuredTag,
        count: settings.homepage_featured_count,
        filter: "latest",
        variant: "featured",
      },
      conditions: [
        { type: "setting", name: "tagging_enabled", enabled: true },
        {
          type: "setting",
          source: settings,
          name: "homepage_show_featured",
          enabled: true,
        },
        {
          type: "setting",
          source: settings,
          name: "homepage_featured_tag",
          enabled: true,
        },
      ],
    },
    {
      block: BlockTopicGrid,
      id: "latest",
      args: {
        eyebrow: "homepage.latest.eyebrow",
        title: "homepage.latest.title",
        subtitle: "homepage.latest.subtitle",
        linkLabel: "homepage.latest.link",
        linkUrl: "/latest",
        count: settings.homepage_latest_count,
        filter: "latest",
        variant: "default",
      },
    },
    {
      block: BlockGroup,
      id: "sidebar",
      children: [
        {
          block: BlockLinks,
          id: "links",
          args: {
            title: "homepage.links.title",
            icon: "compass",
            links: [
              {
                label: "homepage.links.welcome",
                url: "/about",
                icon: "fire",
              },
              {
                label: "homepage.links.guidelines",
                url: "/guidelines",
                icon: "book-open",
              },
              {
                label: "homepage.links.faq",
                url: "/faq",
                icon: "comments",
              },
              {
                label: "homepage.links.discord",
                url: "https://discord.gg/Kv26CYbXsy",
                icon: "users",
                external: true,
              },
              {
                label: "homepage.links.support",
                url: "mailto:support@moonaut.com",
                icon: "compass",
                external: true,
              },
            ],
          },
          conditions: {
            type: "setting",
            source: settings,
            name: "homepage_show_links",
            enabled: true,
          },
        },
        {
          block: BlockCta,
          id: "cta",
          args: {
            eyebrow: "homepage.cta.eyebrow",
            title: "homepage.cta.title",
            description: "homepage.cta.description",
            buttonLabel: "homepage.cta.button",
            buttonUrl: settings.homepage_cta_url,
          },
        },
      ],
    },
  ]);
});
