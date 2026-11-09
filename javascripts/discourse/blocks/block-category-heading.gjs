import Component from "@glimmer/component";
import { service } from "@ember/service";
import { block } from "discourse/blocks";

@block("theme:blokoto:category-heading", {
  description: "A plain category title and description for category pages",
})
export default class BlockCategoryHeading extends Component {
  @service discovery;

  get category() {
    return this.discovery.category;
  }

  <template>
    {{#if this.category}}
      <header class="blokoto-category-heading">
        <h2 class="blokoto-category-heading__title">
          {{this.category.displayName}}
        </h2>
        {{#if this.category.descriptionText}}
          <p class="blokoto-category-heading__description">
            {{this.category.descriptionText}}
          </p>
        {{/if}}
      </header>
    {{/if}}
  </template>
}
