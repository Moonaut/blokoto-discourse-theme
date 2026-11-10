import Component from "@glimmer/component";
import { cached } from "@glimmer/tracking";
import { action } from "@ember/object";
import { service } from "@ember/service";
import getURL from "discourse/lib/get-url";
import { canDisplayCategory } from "discourse/lib/sidebar/helpers";
import Category from "discourse/models/category";
import dIcon from "discourse/ui-kit/helpers/d-icon";
import { i18n } from "discourse-i18n";

const TOP_SITE_CATEGORIES_TO_SHOW = 5;

// The Solar Icons component inlines its sprite, so these symbols can be
// referenced directly without adding them to about.json svg_icons.
const SOLAR_CATEGORY_ICONS = {
  general: "chat-round-line",
  "site-feedback": "lightbulb",
  staff: "shield-user",
};
const DEFAULT_SOLAR_CATEGORY_ICON = "folder";

export default class BlokotoCategoryNav extends Component {
  @service currentUser;
  @service header;
  @service router;
  @service site;
  @service siteSettings;

  @cached
  get categories() {
    return this.selectedCategories.filter((category) =>
      canDisplayCategory(category.id, this.siteSettings)
    );
  }

  get selectedCategories() {
    const sidebarCategoryIds = this.currentUser?.sidebarCategoryIds;

    if (sidebarCategoryIds?.length > 0) {
      return Category.findByIds(sidebarCategoryIds);
    }

    return this.site.categoriesList
      .filter(
        (category) =>
          !category.parent_category_id &&
          canDisplayCategory(category.id, this.siteSettings)
      )
      .slice(0, TOP_SITE_CATEGORIES_TO_SHOW);
  }

  get activeCategoryId() {
    const topicCategoryId = this.header.topicInfo?.category?.id;

    if (topicCategoryId) {
      return topicCategoryId;
    }

    const currentURL = this.router.currentURL?.split("?")[0];

    return this.categories
      .filter(
        (category) =>
          currentURL === category.url ||
          currentURL?.startsWith(`${category.url}/`)
      )
      .sort((a, b) => b.url.length - a.url.length)[0]?.id;
  }

  get visible() {
    return (
      this.categories.length > 0 &&
      !this.router.currentRouteName?.startsWith("admin")
    );
  }

  @action
  isActive(category) {
    return category.id === this.activeCategoryId;
  }

  @action
  solarIconFor(category) {
    if (category.styleType === "icon" && category.icon) {
      return category.icon;
    }

    const base =
      SOLAR_CATEGORY_ICONS[category.slug] ?? DEFAULT_SOLAR_CATEGORY_ICON;
    const style = this.isActive(category) ? "bold" : "linear";

    return `si-${base}-${style}`;
  }

  <template>
    {{#if this.visible}}
      <nav
        aria-label={{i18n (themePrefix "category_nav.label")}}
        class="blokoto-category-nav"
      >
        {{#each this.categories as |category|}}
          <a
            aria-current={{if (this.isActive category) "page"}}
            class="blokoto-category-nav__link"
            href={{getURL category.url}}
          >
            <span class="blokoto-category-nav__icon">
              {{dIcon (this.solarIconFor category)}}
            </span>
            <span class="blokoto-category-nav__label">
              {{category.displayName}}
            </span>
          </a>
        {{/each}}
      </nav>
    {{/if}}
  </template>
}
