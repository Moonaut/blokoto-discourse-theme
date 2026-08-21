import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { concat, fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { htmlSafe } from "@ember/template";
import { block } from "discourse/blocks";
import avatar from "discourse/helpers/avatar";
import categoryLink from "discourse/helpers/category-link";
import replaceEmoji from "discourse/helpers/replace-emoji";
import { shortDateNoYear } from "discourse/lib/formatter";
import { eq } from "discourse/truth-helpers";
import { i18n } from "discourse-i18n";

const FILTERS = ["hot", "latest", "top"];

@block("theme:blokoto:activity-list", {
  description:
    "Feed principal da comunidade com abas de filtro (em alta, recentes, melhores)",
  args: {
    title: { type: "string" },
    count: { type: "number", default: 6 },
    defaultFilter: { type: "string", oneOf: FILTERS, default: "hot" },
  },
})
export default class BlockActivityList extends Component {
  @service store;

  @tracked items = null;
  @tracked activeFilter;
  @tracked loading = true;

  filters = FILTERS;

  constructor() {
    super(...arguments);
    this.activeFilter = this.args.defaultFilter || "hot";
    this.load(this.activeFilter);
  }

  willDestroy() {
    super.willDestroy(...arguments);
    this.items = null;
  }

  normalize(topic) {
    const replyCount =
      topic.reply_count ?? Math.max((topic.posts_count ?? 1) - 1, 0);

    return {
      id: topic.id,
      url: topic.url,
      fancyTitle: topic.fancy_title,
      category: topic.category,
      creator: topic.creator,
      creatorPath: topic.creator?.path,
      replyCount,
      dateLabel: topic.bumped_at
        ? shortDateNoYear(new Date(topic.bumped_at))
        : null,
    };
  }

  async load(filter) {
    this.loading = true;
    try {
      const topicList = await this.store.findFiltered("topicList", { filter });
      const topics = (topicList?.topics ?? []).slice(0, this.args.count || 6);
      this.items = topics.map((topic) => this.normalize(topic));
    } catch {
      this.items = [];
    } finally {
      this.loading = false;
    }
  }

  @action
  switchFilter(filter) {
    if (filter === this.activeFilter) {
      return;
    }
    this.activeFilter = filter;
    this.load(filter);
  }

  <template>
    <section class="block-activity-list__layout">
      <div class="block-activity-list__header">
        {{#if @title}}
          <h2 class="block-activity-list__title">
            {{i18n (themePrefix @title)}}
          </h2>
        {{/if}}

        <div class="block-activity-list__tabs" role="tablist">
          {{#each this.filters as |filter|}}
            <button
              type="button"
              role="tab"
              aria-selected={{if (eq filter this.activeFilter) "true" "false"}}
              class="block-activity-list__tab
                {{if (eq filter this.activeFilter) 'is-active'}}"
              {{on "click" (fn this.switchFilter filter)}}
            >
              {{i18n (themePrefix (concat "homepage.activity.tabs." filter))}}
            </button>
          {{/each}}
        </div>
      </div>

      {{#if this.loading}}
        <div class="block-activity-list__loading"><div class="spinner" /></div>
      {{else if this.items.length}}
        <ol class="block-activity-list__list">
          {{#each this.items key="id" as |item|}}
            <li class="block-activity-list__item">
              <a href={{item.creatorPath}} class="block-activity-list__avatar">
                {{avatar item.creator imageSize="small"}}
              </a>

              <div class="block-activity-list__body">
                <a href={{item.url}} class="block-activity-list__topic-title">
                  {{htmlSafe (replaceEmoji item.fancyTitle)}}
                </a>
                <div class="block-activity-list__meta">
                  {{categoryLink item.category}}
                  {{#if item.dateLabel}}
                    <span class="block-activity-list__age">
                      {{item.dateLabel}}
                    </span>
                  {{/if}}
                </div>
              </div>

              <div class="block-activity-list__replies">
                <span class="block-activity-list__replies-count">
                  {{item.replyCount}}
                </span>
                <span class="block-activity-list__replies-label">
                  {{i18n
                    (themePrefix "homepage.activity.replies")
                    count=item.replyCount
                  }}
                </span>
              </div>
            </li>
          {{/each}}
        </ol>
      {{else}}
        <p class="block-activity-list__empty">{{i18n "topics.none.latest"}}</p>
      {{/if}}
    </section>
  </template>
}
