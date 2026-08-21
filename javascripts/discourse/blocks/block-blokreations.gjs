import Component from "@glimmer/component";
import { service } from "@ember/service";
import { htmlSafe } from "@ember/template";
import { block } from "discourse/blocks";
import AsyncContent from "discourse/components/async-content";
import dIcon from "discourse/helpers/d-icon";
import replaceEmoji from "discourse/helpers/replace-emoji";
import { bind } from "discourse/lib/decorators";
import { i18n } from "discourse-i18n";

@block("theme:blokoto:blokreations", {
  description:
    "Galeria visual de criações da comunidade, filtrada por tag, com miniatura e curtidas",
  args: {
    title: { type: "string" },
    linkText: { type: "string" },
    linkUrl: { type: "string" },
    tag: { type: "string", required: true },
    count: { type: "number", default: 4 },
    filter: { type: "string", default: "top" },
  },
})
export default class BlockBlokreations extends Component {
  @service store;

  thumbnailFor(topic) {
    const thumbnails = topic.thumbnails ?? [];
    if (!thumbnails.length) {
      return topic.image_url ?? null;
    }
    // Prefere a menor miniatura que ainda cubra o card (400px de largura).
    const usable = thumbnails
      .filter((thumb) => thumb.url && (thumb.max_width ?? 0) >= 400)
      .sort((a, b) => (a.max_width ?? 0) - (b.max_width ?? 0));

    return usable[0]?.url ?? thumbnails[0].url;
  }

  @bind
  async fetchCreations() {
    const tag = this.args.tag;
    const filter = `tag/${tag}/l/${this.args.filter || "top"}`;

    const topicList = await this.store.findFiltered("topicList", { filter });
    const topics = topicList?.topics ?? [];

    if (!topics.length) {
      return null;
    }

    return topics.slice(0, this.args.count || 4).map((topic) => ({
      id: topic.id,
      url: topic.url,
      fancyTitle: topic.fancy_title,
      likeCount: topic.like_count ?? 0,
      creator: topic.creator?.username,
      thumbnail: this.thumbnailFor(topic),
    }));
  }

  <template>
    <AsyncContent @asyncData={{this.fetchCreations}}>
      <:loading>
        <div class="block-blokreations__loading"><div class="spinner" /></div>
      </:loading>

      <:empty>
        {{! Sem criações ainda: não renderiza nada em vez de mostrar um vazio triste }}
      </:empty>

      <:content as |creations|>
        <section class="block-blokreations__layout">
          <div class="block-blokreations__header">
            {{#if @title}}
              <h2 class="block-blokreations__title">
                {{i18n (themePrefix @title)}}
              </h2>
            {{/if}}
            {{#if @linkUrl}}
              <a href={{@linkUrl}} class="block-blokreations__link">
                {{i18n (themePrefix @linkText)}}
              </a>
            {{/if}}
          </div>

          <div class="block-blokreations__grid">
            {{#each creations key="id" as |creation|}}
              <a href={{creation.url}} class="block-blokreations__card">
                <div class="block-blokreations__thumb">
                  {{#if creation.thumbnail}}
                    <img
                      src={{creation.thumbnail}}
                      alt=""
                      loading="lazy"
                      class="block-blokreations__image"
                    />
                  {{else}}
                    <span class="block-blokreations__placeholder">
                      {{dIcon "far-gem"}}
                    </span>
                  {{/if}}
                </div>
                <span class="block-blokreations__name">
                  {{htmlSafe (replaceEmoji creation.fancyTitle)}}
                </span>
                <span class="block-blokreations__meta">
                  {{dIcon "heart"}}
                  {{creation.likeCount}}
                </span>
              </a>
            {{/each}}
          </div>
        </section>
      </:content>
    </AsyncContent>
  </template>
}
