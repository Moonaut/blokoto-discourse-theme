import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { on } from "@ember/modifier";
import { service } from "@ember/service";
import { trustHTML } from "@ember/template";
import { block } from "discourse/blocks";
import { bind } from "discourse/lib/decorators";
import getURL from "discourse/lib/get-url";
import DAsyncContent from "discourse/ui-kit/d-async-content";
import DButton from "discourse/ui-kit/d-button";
import dCategoryLink from "discourse/ui-kit/helpers/d-category-link";
import dIcon from "discourse/ui-kit/helpers/d-icon";
import { i18n } from "discourse-i18n";
import BlokotoHomeBlokreations from "../components/blokoto-home-blokreations.gjs";
import BlokotoHomeContributors from "../components/blokoto-home-contributors.gjs";
import BlokotoHomeEvents from "../components/blokoto-home-events.gjs";
import BlokotoHomeHotTopics from "../components/blokoto-home-hot-topics.gjs";

@block("theme:blokoto:home", {
  description:
    "A compact community introduction, a latest-discussions list, a community rail, and a Blokreations carousel",
  args: {
    title: { type: "string", required: true },
    subtitle: { type: "string" },
    primaryLabel: { type: "string" },
    primaryUrl: { type: "string" },
    secondaryLabel: { type: "string" },
    secondaryUrl: { type: "string" },
    latestTitle: { type: "string" },
    latestLinkLabel: { type: "string" },
    eventsCount: { type: "number", default: 3 },
    hotCount: { type: "number", default: 4 },
    contributorsCount: { type: "number", default: 5 },
    blokreationsCategory: { type: "string", default: "blokreations" },
    blokreationsCount: { type: "number", default: 8 },
    count: { type: "number", default: 6 },
  },
})
export default class BlockHome extends Component {
  @service store;

  @tracked retryCount = 0;

  get placeholders() {
    return Array.from({ length: this.args.count });
  }

  get context() {
    return { count: this.args.count, retryCount: this.retryCount };
  }

  @bind
  retry() {
    this.retryCount++;
  }

  @bind
  async fetchTopics({ count }) {
    const topicList = await this.store.findFiltered("topicList", {
      filter: "latest",
    });
    const topics = topicList.topics?.slice(0, count) ?? [];
    return topics.length ? topics : null;
  }

  <template>
    <section aria-labelledby="blokoto-home-title" class="blokoto-home">
      <div class="blokoto-home__layout">
        <div class="blokoto-home__main">
          <header class="blokoto-home__intro">
            <h1 class="blokoto-home__title" id="blokoto-home-title">
              {{i18n (themePrefix @title)}}
            </h1>

            {{#if @subtitle}}
              <p class="blokoto-home__subtitle">{{i18n
                  (themePrefix @subtitle)
                }}</p>
            {{/if}}

            <div class="blokoto-home__actions">
              {{#if @primaryUrl}}
                <DButton
                  class="btn-primary blokoto-home__primary"
                  @href={{@primaryUrl}}
                  @translatedLabel={{i18n (themePrefix @primaryLabel)}}
                />
              {{/if}}

              {{#if @secondaryUrl}}
                <a class="blokoto-home__secondary" href={{@secondaryUrl}}>
                  {{i18n (themePrefix @secondaryLabel)}}
                </a>
              {{/if}}
            </div>
          </header>

          <section
            aria-labelledby="blokoto-home-latest-title"
            class="blokoto-home__latest"
          >
            <header class="blokoto-home__latest-header">
              <h2
                class="blokoto-home__latest-title"
                id="blokoto-home-latest-title"
              >
                {{i18n (themePrefix @latestTitle)}}
              </h2>
              <a
                aria-label={{i18n (themePrefix "home.latest_link_aria")}}
                class="blokoto-home__latest-link"
                href={{getURL "/latest"}}
              >
                {{i18n (themePrefix @latestLinkLabel)}}
              </a>
            </header>

            <DAsyncContent
              @asyncData={{this.fetchTopics}}
              @context={{this.context}}
              @retainWhileReloading={{true}}
            >
              <:loading>
                <div aria-busy="true" class="blokoto-home__list">
                  {{#each this.placeholders as |placeholder|}}
                    <div
                      class="blokoto-home__skeleton"
                      data-placeholder={{placeholder}}
                    >
                      <span class="blokoto-skeleton --title"></span>
                      <span class="blokoto-skeleton --meta"></span>
                    </div>
                  {{/each}}
                </div>
              </:loading>

              <:empty>
                <div class="blokoto-home__empty">
                  <p>{{i18n (themePrefix "home.empty")}}</p>
                  <a href={{getURL "/new-topic"}}>
                    {{i18n (themePrefix "home.empty_action")}}
                  </a>
                </div>
              </:empty>

              <:error>
                <div class="blokoto-home__empty">
                  <p>{{i18n (themePrefix "home.load_error")}}</p>
                  <button
                    class="btn btn-default"
                    type="button"
                    {{on "click" this.retry}}
                  >
                    {{i18n (themePrefix "home.retry")}}
                  </button>
                </div>
              </:error>

              <:content as |topics|>
                <ol class="blokoto-home__list">
                  {{#each topics as |topic|}}
                    <li class="blokoto-home__topic">
                      <h3 class="blokoto-home__topic-title">
                        <a href={{topic.url}}>{{trustHTML topic.fancyTitle}}</a>
                      </h3>

                      <div class="blokoto-home__meta">
                        {{#if topic.category}}
                          {{dCategoryLink topic.category}}
                        {{/if}}

                        {{#if topic.creator}}
                          <span class="blokoto-home__author">
                            @{{topic.creator.username}}
                          </span>
                        {{/if}}

                        <span
                          aria-label={{i18n (themePrefix "home.replies")}}
                          class="blokoto-home__replies"
                        >
                          {{dIcon "comments"}}
                          {{topic.reply_count}}
                        </span>
                      </div>
                    </li>
                  {{/each}}
                </ol>
              </:content>
            </DAsyncContent>
          </section>
        </div>

        <aside
          aria-label={{i18n (themePrefix "home.rail_label")}}
          class="blokoto-home__rail"
        >
          <BlokotoHomeEvents @count={{@eventsCount}} />
          <BlokotoHomeHotTopics @count={{@hotCount}} />
          <BlokotoHomeContributors @count={{@contributorsCount}} />
        </aside>

        <BlokotoHomeBlokreations
          @categorySlug={{@blokreationsCategory}}
          @count={{@blokreationsCount}}
        />
      </div>
    </section>
  </template>
}
