import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { on } from "@ember/modifier";
import { service } from "@ember/service";
import { trustHTML } from "@ember/template";
import { block } from "discourse/blocks";
import { bind } from "discourse/lib/decorators";
import getURL from "discourse/lib/get-url";
import DAsyncContent from "discourse/ui-kit/d-async-content";
import dAvatar from "discourse/ui-kit/helpers/d-avatar";
import dCategoryLink from "discourse/ui-kit/helpers/d-category-link";
import dIcon from "discourse/ui-kit/helpers/d-icon";
import { i18n } from "discourse-i18n";

@block("theme:blokoto:topic-grid", {
  description: "A card grid of discussions, optionally filtered by tag",
  args: {
    eyebrow: { type: "string" },
    title: { type: "string", required: true },
    subtitle: { type: "string" },
    linkLabel: { type: "string" },
    linkUrl: { type: "string" },
    filter: { type: "string", default: "latest" },
    tag: { type: "string" },
    count: { type: "number", default: 6 },
    variant: {
      type: "string",
      enum: ["default", "featured"],
      default: "default",
    },
  },
})
export default class BlockTopicGrid extends Component {
  @service store;

  @tracked retryCount = 0;

  get placeholders() {
    return Array.from({ length: this.args.count });
  }

  get context() {
    return {
      filter: this.args.filter,
      tag: this.args.tag,
      count: this.args.count,
      retryCount: this.retryCount,
    };
  }

  @bind
  retry() {
    this.retryCount++;
  }

  @bind
  async fetchTopics({ filter, tag, count }) {
    const path = tag ? `tag/${encodeURIComponent(tag)}/l/${filter}` : filter;
    const topicList = await this.store.findFiltered("topicList", {
      filter: path,
    });
    const topics = topicList.topics?.slice(0, count) ?? [];
    return topics.length ? topics : null;
  }

  <template>
    <section class="blokoto-topic-grid --{{@variant}}">
      <header class="blokoto-section__header">
        <div class="blokoto-section__heading">
          {{#if @eyebrow}}
            <p class="blokoto-section__eyebrow">{{i18n
                (themePrefix @eyebrow)
              }}</p>
          {{/if}}
          <h2 class="blokoto-section__title">{{i18n (themePrefix @title)}}</h2>
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

      <DAsyncContent
        @asyncData={{this.fetchTopics}}
        @context={{this.context}}
        @retainWhileReloading={{true}}
      >
        <:loading>
          <div aria-busy="true" class="blokoto-topic-grid__grid">
            {{#each this.placeholders as |placeholder|}}
              <div
                class="blokoto-topic-card is-skeleton"
                data-placeholder={{placeholder}}
              >
                <div class="blokoto-topic-card__visual"></div>
                <div class="blokoto-topic-card__body">
                  <div class="blokoto-skeleton --title"></div>
                  <div class="blokoto-skeleton --text"></div>
                  <div class="blokoto-skeleton --text-short"></div>
                </div>
              </div>
            {{/each}}
          </div>
        </:loading>

        <:empty>
          <div class="blokoto-topic-grid__empty">
            {{dIcon "comments"}}
            <p>{{i18n (themePrefix "homepage.topic_grid.empty")}}</p>
          </div>
        </:empty>

        <:error>
          <div class="blokoto-topic-grid__empty --error">
            <p>{{i18n (themePrefix "homepage.topic_grid.load_error")}}</p>
            <button
              class="btn btn-default"
              type="button"
              {{on "click" this.retry}}
            >
              {{i18n (themePrefix "homepage.topic_grid.retry")}}
            </button>
          </div>
        </:error>

        <:content as |topics|>
          <div class="blokoto-topic-grid__grid">
            {{#each topics as |topic|}}
              <article class="blokoto-topic-card">
                <a
                  aria-hidden="true"
                  class="blokoto-topic-card__visual"
                  href={{topic.url}}
                  tabindex="-1"
                >
                  <span class="blokoto-topic-card__visual-grid"></span>
                  <span class="blokoto-topic-card__visual-icon">{{dIcon
                      "layer-group"
                    }}</span>
                </a>

                <div class="blokoto-topic-card__body">
                  <h3 class="blokoto-topic-card__title">
                    <a href={{topic.url}}>{{trustHTML topic.fancyTitle}}</a>
                  </h3>

                  {{#if topic.excerpt}}
                    <p class="blokoto-topic-card__excerpt">{{topic.excerpt}}</p>
                  {{/if}}

                  <div class="blokoto-topic-card__meta">
                    {{#if topic.creator}}
                      <span class="blokoto-topic-card__author">
                        {{dAvatar topic.creator imageSize="tiny"}}
                        <span>{{topic.creator.username}}</span>
                      </span>
                    {{/if}}

                    <span
                      aria-label={{i18n
                        (themePrefix "homepage.topic_grid.posts")
                      }}
                      class="blokoto-topic-card__stat"
                    >
                      {{dIcon "comments"}}
                      {{topic.posts_count}}
                    </span>

                    <span
                      aria-label={{i18n
                        (themePrefix "homepage.topic_grid.views")
                      }}
                      class="blokoto-topic-card__stat"
                    >
                      {{dIcon "eye"}}
                      {{topic.views}}
                    </span>
                  </div>

                  <div class="blokoto-topic-card__footer">
                    {{#if topic.category}}
                      {{dCategoryLink topic.category}}
                    {{/if}}
                  </div>
                </div>
              </article>
            {{/each}}
          </div>
        </:content>
      </DAsyncContent>
    </section>
  </template>
}
