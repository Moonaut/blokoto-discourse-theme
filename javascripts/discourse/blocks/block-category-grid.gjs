import Component from "@glimmer/component";
import { concat } from "@ember/helper";
import { service } from "@ember/service";
import { trustHTML } from "@ember/template";
import { block } from "discourse/blocks";
import getURL from "discourse/lib/get-url";
import dIcon from "discourse/ui-kit/helpers/d-icon";
import { i18n } from "discourse-i18n";

@block("theme:blokoto:category-grid", {
  description: "A bento grid of the community's most active categories",
  args: {
    eyebrow: { type: "string" },
    title: { type: "string", required: true },
    subtitle: { type: "string" },
    linkLabel: { type: "string" },
    linkUrl: { type: "string" },
    categoryIds: { type: "array", itemType: "number", default: [] },
    count: { type: "number", default: 6 },
  },
})
export default class BlockCategoryGrid extends Component {
  @service site;

  get categories() {
    const all = this.site.categories ?? [];
    const ids = this.args.categoryIds ?? [];

    if (ids.length) {
      return ids
        .map((id) => all.find((category) => category.id === id))
        .filter(Boolean)
        .slice(0, this.args.count);
    }

    return all
      .filter((category) => !category.parent_category_id)
      .sort((a, b) => (b.topic_count ?? 0) - (a.topic_count ?? 0))
      .slice(0, this.args.count);
  }

  <template>
    {{#if this.categories.length}}
      <section
        aria-labelledby="blokoto-categories-title"
        class="blokoto-categories"
      >
        <header class="blokoto-section__header">
          <div class="blokoto-section__heading">
            {{#if @eyebrow}}
              <p class="blokoto-section__eyebrow">{{i18n
                  (themePrefix @eyebrow)
                }}</p>
            {{/if}}
            <h2 class="blokoto-section__title" id="blokoto-categories-title">
              {{i18n (themePrefix @title)}}
            </h2>
            {{#if @subtitle}}
              <p class="blokoto-section__subtitle">{{i18n
                  (themePrefix @subtitle)
                }}</p>
            {{/if}}
          </div>

          {{#if @linkUrl}}
            <a class="blokoto-section__link" href={{getURL @linkUrl}}>
              {{i18n (themePrefix @linkLabel)}}
              {{dIcon "arrow-right"}}
            </a>
          {{/if}}
        </header>

        <div class="blokoto-categories__grid">
          {{#each this.categories as |category|}}
            <a class="blokoto-category-card" href={{category.url}}>
              <span
                aria-hidden="true"
                class="blokoto-category-card__index"
              ></span>

              <span class="blokoto-category-card__top">
                <span
                  aria-hidden="true"
                  class="blokoto-category-card__dot"
                  style={{trustHTML
                    (concat "background-color: #" category.color)
                  }}
                ></span>
                <span aria-hidden="true" class="blokoto-category-card__arrow">
                  {{dIcon "arrow-up-right"}}
                </span>
              </span>

              <span class="blokoto-category-card__body">
                <span
                  class="blokoto-category-card__title"
                >{{category.displayName}}</span>

                {{#if category.descriptionText}}
                  <span class="blokoto-category-card__description">
                    {{category.descriptionText}}
                  </span>
                {{/if}}
              </span>

              <span class="blokoto-category-card__meta">
                {{i18n
                  (themePrefix "homepage.categories.topics")
                  count=category.topic_count
                }}
              </span>
            </a>
          {{/each}}
        </div>
      </section>
    {{/if}}
  </template>
}
