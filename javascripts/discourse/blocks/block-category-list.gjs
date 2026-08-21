import Component from "@glimmer/component";
import { service } from "@ember/service";
import { block } from "discourse/blocks";
import { i18n } from "discourse-i18n";

@block("theme:blokoto:category-list", {
  description:
    "Lista compacta de categorias de topo com contagem — substitui a sidebar de navegação",
  args: {
    title: { type: "string" },
    linkText: { type: "string" },
    linkUrl: { type: "string", default: "/categories" },
  },
})
export default class BlockCategoryList extends Component {
  @service site;

  get categories() {
    return (this.site.categories ?? [])
      .filter(
        (category) =>
          !category.parent_category_id &&
          !category.isUncategorizedCategory &&
          !category.read_restricted
      )
      .sort((a, b) => (a.position ?? 0) - (b.position ?? 0));
  }

  <template>
    <section class="block-category-list__layout">
      <div class="block-category-list__header">
        {{#if @title}}
          <h2 class="block-category-list__title">
            {{i18n (themePrefix @title)}}
          </h2>
        {{/if}}
        {{#if @linkText}}
          <a href={{@linkUrl}} class="block-category-list__link">
            {{i18n (themePrefix @linkText)}}
          </a>
        {{/if}}
      </div>

      <ul class="block-category-list__list">
        {{#each this.categories key="id" as |category|}}
          <li class="block-category-list__item">
            <a href={{category.url}} class="block-category-list__category">
              <span
                class="block-category-list__dot"
                style={{category.style}}
              ></span>
              <span class="block-category-list__name">{{category.name}}</span>
              <span class="block-category-list__count">
                {{category.topic_count}}
              </span>
            </a>
          </li>
        {{/each}}
      </ul>
    </section>
  </template>
}
