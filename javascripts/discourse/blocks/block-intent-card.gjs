import Component from "@glimmer/component";
import { block } from "discourse/blocks";
import dIcon from "discourse/helpers/d-icon";
import Category from "discourse/models/category";
import { i18n } from "discourse-i18n";

@block("theme:blokoto:intent-card", {
  description:
    "Cartão de intenção: ícone, rótulo e contagem real de tópicos da categoria",
  args: {
    icon: { type: "string", required: true },
    label: { type: "string", required: true },
    href: { type: "string", required: true },
    categoryId: { type: "number" },
    fallbackMeta: { type: "string" },
  },
})
export default class BlockIntentCard extends Component {
  get topicCount() {
    const id = this.args.categoryId;
    if (!id) {
      return null;
    }
    return Category.findById(id)?.topic_count ?? null;
  }

  <template>
    <a href={{@href}} class="block-intent-card__layout">
      <span class="block-intent-card__icon">{{dIcon @icon}}</span>
      <span class="block-intent-card__label">{{i18n (themePrefix @label)}}</span>
      <span class="block-intent-card__meta">
        {{#if this.topicCount}}
          {{i18n (themePrefix "homepage.intents.topic_count") count=this.topicCount}}
        {{else if @fallbackMeta}}
          {{i18n (themePrefix @fallbackMeta)}}
        {{/if}}
      </span>
    </a>
  </template>
}
