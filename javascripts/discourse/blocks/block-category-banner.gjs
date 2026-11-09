import Component from "@glimmer/component";
import { service } from "@ember/service";
import { block } from "discourse/blocks";
import CategoryLogo from "discourse/components/category-logo";
import dIcon from "discourse/ui-kit/helpers/d-icon";
import { i18n } from "discourse-i18n";

@block("theme:blokoto:category-banner", {
  description: "An island banner for category pages",
  args: {
    categoryIds: { type: "array", itemType: "number", default: [] },
    showDescription: { type: "boolean", default: true },
  },
})
export default class BlockCategoryBanner extends Component {
  @service discovery;

  get category() {
    const category = this.discovery.category;
    const ids = this.args.categoryIds ?? [];

    if (!category || !ids.length) {
      return category;
    }

    return ids.includes(category.id) ||
      ids.includes(category.parent_category_id)
      ? category
      : null;
  }

  <template>
    {{#if this.category}}
      <section class="blokoto-category-banner">
        <div aria-hidden="true" class="blokoto-category-banner__mark">
          {{#if this.category.uploaded_logo}}
            <CategoryLogo @category={{this.category}} />
          {{else}}
            {{dIcon "comments"}}
          {{/if}}
        </div>

        <div class="blokoto-category-banner__content">
          <p class="blokoto-category-banner__eyebrow">{{i18n
              (themePrefix "category_banner.eyebrow")
            }}</p>
          <h1 class="blokoto-category-banner__name">
            {{this.category.displayName}}
          </h1>
          {{#if @showDescription}}
            <p class="blokoto-category-banner__description">
              {{#if this.category.descriptionText}}
                {{this.category.descriptionText}}
              {{else}}
                {{i18n (themePrefix "category_banner.fallback_description")}}
              {{/if}}
            </p>
          {{/if}}
        </div>

        <div class="blokoto-category-banner__meta">
          {{i18n
            (themePrefix "category_banner.topics")
            count=this.category.topic_count
          }}
        </div>
      </section>
    {{/if}}
  </template>
}
