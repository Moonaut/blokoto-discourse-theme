import BlockGroup from "discourse/blocks/builtin/block-group";
import BlockHead from "discourse/blocks/builtin/block-head";
import { apiInitializer } from "discourse/lib/api";
import BlockActivityList from "../blocks/block-activity-list";
import BlockBlokreations from "../blocks/block-blokreations";
import BlockCategoryList from "../blocks/block-category-list";
import BlockHero from "../blocks/block-hero";
import BlockIntentCard from "../blocks/block-intent-card";
import BlockIntentGrid from "../blocks/block-intent-grid";
import BlockStatsBar from "../blocks/block-stats-bar";
import BlockWelcomeStrip from "../blocks/block-welcome-strip";

export default apiInitializer((api) => {
  api.renderBlocks("homepage-blocks", [
    // Cabeçalho da página: BlockHead renderiza apenas o primeiro filho cuja
    // condição passa. Visitante vê o pitch completo; membro vê a saudação.
    {
      block: BlockHead,
      id: "hero-head",
      children: [
        {
          block: BlockHero,
          id: "hero",
          args: {
            title: "homepage.hero.title",
            subtitle: "homepage.hero.subtitle",
            playLabel: "homepage.hero.play",
            playUrl: settings.hero_play_url,
            signupLabel: "homepage.hero.signup",
            signupUrl: settings.hero_signup_url,
            videoUrl: settings.hero_video_url,
            posterUrl: settings.hero_poster_url,
          },
          conditions: { type: "user", loggedIn: false },
        },
        {
          block: BlockWelcomeStrip,
          id: "welcome-strip",
          args: {
            greeting: "homepage.welcome.greeting",
            newTopicLabel: "homepage.welcome.new_topic",
            unreadLabel: "homepage.welcome.unread",
          },
        },
      ],
    },

    {
      block: BlockStatsBar,
      id: "stats-bar",
      args: {
        membersLabel: "homepage.stats.members",
        onlineLabel: "homepage.stats.online",
        activeLabel: "homepage.stats.active",
        postsLabel: "homepage.stats.posts",
        releaseLabel: "homepage.stats.release",
        releaseTag: settings.release_tag,
        showOnline: settings.show_online_now,
      },
    },

    {
      block: BlockIntentGrid,
      id: "intents",
      args: { title: "homepage.intents.title" },
      children: [
        {
          block: BlockIntentCard,
          id: "intent-help",
          args: {
            icon: "headset",
            label: "homepage.intents.help",
            href: "/new-topic?category_id=" + settings.support_category_id,
            categoryId: settings.support_category_id,
            fallbackMeta: "homepage.intents.help_meta",
          },
        },
        {
          block: BlockIntentCard,
          id: "intent-idea",
          args: {
            icon: "far-lightbulb",
            label: "homepage.intents.idea",
            href: "/new-topic?category_id=" + settings.suggestions_category_id,
            categoryId: settings.suggestions_category_id,
            fallbackMeta: "homepage.intents.idea_meta",
          },
        },
        {
          block: BlockIntentCard,
          id: "intent-bug",
          args: {
            icon: "bug",
            label: "homepage.intents.bug",
            href: "/new-topic?category_id=" + settings.bugs_category_id,
            categoryId: settings.bugs_category_id,
            fallbackMeta: "homepage.intents.bug_meta",
          },
        },
        {
          block: BlockIntentCard,
          id: "intent-roadmap",
          args: {
            icon: "flask",
            label: "homepage.intents.roadmap",
            href: settings.roadmap_url,
            fallbackMeta: "homepage.intents.roadmap_meta",
          },
        },
      ],
    },

    {
      block: BlockActivityList,
      id: "activity",
      args: {
        title: "homepage.activity.title",
        count: settings.activity_count,
        defaultFilter: settings.activity_default_filter,
      },
    },

    {
      block: BlockGroup,
      id: "homepage-side",
      children: [
        {
          block: BlockCategoryList,
          id: "categories",
          args: {
            title: "homepage.categories.title",
            linkText: "homepage.categories.link_text",
            linkUrl: "/categories",
          },
        },
      ],
    },

    {
      block: BlockBlokreations,
      id: "blokreations",
      args: {
        title: "homepage.blokreations.title",
        linkText: "homepage.blokreations.link_text",
        linkUrl: `/tag/${settings.blokreations_tag}`,
        tag: settings.blokreations_tag,
        count: settings.blokreations_count,
        filter: "top",
      },
      conditions: [
        { type: "setting", name: "tagging_enabled", enabled: true },
        {
          type: "setting",
          source: settings,
          name: "blokreations_tag",
          enabled: true,
        },
      ],
    },
  ]);
});
