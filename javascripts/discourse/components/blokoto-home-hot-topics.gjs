import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { on } from "@ember/modifier";
import { service } from "@ember/service";
import { trustHTML } from "@ember/template";
import { bind } from "discourse/lib/decorators";
import getURL from "discourse/lib/get-url";
import DAsyncContent from "discourse/ui-kit/d-async-content";
import dCategoryLink from "discourse/ui-kit/helpers/d-category-link";
import dIcon from "discourse/ui-kit/helpers/d-icon";
import { i18n } from "discourse-i18n";

const SKELETON_ROWS = 3;

export default class BlokotoHomeHotTopics extends Component {
  @service store;

  @tracked retryCount = 0;

  get placeholders() {
    return Array.from({ length: SKELETON_ROWS });
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
      filter: "hot",
      params: { per_page: count },
    });
    const topics = topicList?.topics?.slice(0, count) ?? [];

    return topics.length ? topics : null;
  }

  <template>
    <section
      aria-labelledby="blokoto-rail-hot-title"
      class="blokoto-rail__section"
    >
      <header class="blokoto-rail__header">
        <h2 class="blokoto-rail__title" id="blokoto-rail-hot-title">
          {{i18n (themePrefix "home.hot.title")}}
        </h2>
        <a
          aria-label={{i18n (themePrefix "home.hot.view_all")}}
          class="blokoto-rail__link"
          href={{getURL "/hot"}}
        >
          {{i18n (themePrefix "home.view_all")}}
        </a>
      </header>

      <DAsyncContent
        @asyncData={{this.fetchTopics}}
        @context={{this.context}}
        @retainWhileReloading={{true}}
      >
        <:loading>
          <div aria-busy="true" class="blokoto-rail__skeleton">
            {{#each this.placeholders as |placeholder|}}
              <div
                class="blokoto-rail__skeleton-row --stacked"
                data-placeholder={{placeholder}}
              >
                <span class="blokoto-skeleton --title"></span>
                <span class="blokoto-skeleton --meta"></span>
              </div>
            {{/each}}
          </div>
        </:loading>

        <:content as |topics|>
          <ul class="blokoto-rail__list">
            {{#each topics as |topic|}}
              <li class="blokoto-rail__item">
                <h3 class="blokoto-rail__topic-title">
                  <a href={{topic.url}}>{{trustHTML topic.fancyTitle}}</a>
                </h3>

                <div class="blokoto-rail__topic-meta">
                  {{#if topic.category}}
                    {{dCategoryLink topic.category}}
                  {{/if}}

                  <span
                    aria-label={{i18n
                      (themePrefix "home.hot.replies")
                      count=topic.reply_count
                    }}
                    class="blokoto-rail__topic-replies"
                  >
                    {{dIcon "comments"}}
                    {{topic.reply_count}}
                  </span>
                </div>
              </li>
            {{/each}}
          </ul>
        </:content>

        <:empty>
          <p class="blokoto-rail__empty">
            {{i18n (themePrefix "home.hot.empty")}}
          </p>
        </:empty>

        <:error>
          <div class="blokoto-rail__error">
            <p>{{i18n (themePrefix "home.hot.load_error")}}</p>
            <button
              class="btn btn-default"
              type="button"
              {{on "click" this.retry}}
            >
              {{i18n (themePrefix "home.retry")}}
            </button>
          </div>
        </:error>
      </DAsyncContent>
    </section>
  </template>
}
