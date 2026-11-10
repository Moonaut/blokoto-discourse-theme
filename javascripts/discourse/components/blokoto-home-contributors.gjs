import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { on } from "@ember/modifier";
import { service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";
import { bind } from "discourse/lib/decorators";
import getURL from "discourse/lib/get-url";
import DAsyncContent from "discourse/ui-kit/d-async-content";
import dAvatar from "discourse/ui-kit/helpers/d-avatar";
import { i18n } from "discourse-i18n";

const SKELETON_ROWS = 3;

export default class BlokotoHomeContributors extends Component {
  @service currentUser;
  @service siteSettings;

  @tracked retryCount = 0;

  get enabled() {
    return (
      this.siteSettings.enable_user_directory !== false &&
      (!this.siteSettings.hide_user_profiles_from_public || this.currentUser)
    );
  }

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
  async fetchContributors({ count }) {
    const response = await ajax("/directory_items.json", {
      data: { period: "weekly", order: "post_count" },
    });

    const items = (response.directory_items ?? [])
      .map((item) => ({
        ...item,
        contributionCount: (item.post_count || 0) + (item.topic_count || 0),
        name: item.user.name || item.user.username,
        profileUrl: getURL(`/u/${item.user.username.toLowerCase()}`),
      }))
      .filter((item) => item.contributionCount > 0)
      .sort((a, b) => b.contributionCount - a.contributionCount)
      .slice(0, count)
      .map((item, index) => ({ ...item, rank: index + 1 }));

    return items.length ? items : null;
  }

  <template>
    {{#if this.enabled}}
      <section
        aria-labelledby="blokoto-rail-contributors-title"
        class="blokoto-rail__section"
      >
        <header class="blokoto-rail__header">
          <h2 class="blokoto-rail__title" id="blokoto-rail-contributors-title">
            {{i18n (themePrefix "home.contributors.title")}}
          </h2>
          <a
            aria-label={{i18n (themePrefix "home.contributors.view_all")}}
            class="blokoto-rail__link"
            href={{getURL "/u?period=weekly&order=post_count"}}
          >
            {{i18n (themePrefix "home.view_all")}}
          </a>
        </header>

        <DAsyncContent
          @asyncData={{this.fetchContributors}}
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

          <:content as |items|>
            <ol class="blokoto-rail__list blokoto-rail__contributors">
              {{#each items as |item|}}
                <li class="blokoto-rail__contributor">
                  <span class="blokoto-rail__rank">{{item.rank}}</span>

                  <a
                    aria-hidden="true"
                    class="blokoto-rail__avatar"
                    href={{item.profileUrl}}
                    tabindex="-1"
                  >
                    {{dAvatar item.user imageSize="small"}}
                  </a>

                  <a class="blokoto-rail__name" href={{item.profileUrl}}>
                    {{item.name}}
                  </a>

                  <span class="blokoto-rail__count">
                    {{i18n
                      (themePrefix "home.contributors.contributions")
                      count=item.contributionCount
                    }}
                  </span>
                </li>
              {{/each}}
            </ol>
          </:content>

          <:empty>
            <p class="blokoto-rail__empty">
              {{i18n (themePrefix "home.contributors.empty")}}
              <a
                class="blokoto-rail__empty-link"
                href={{getURL "/u?period=weekly&order=post_count"}}
              >
                {{i18n (themePrefix "home.contributors.empty_action")}}
              </a>
            </p>
          </:empty>

          <:error>
            <div class="blokoto-rail__error">
              <p>{{i18n (themePrefix "home.contributors.load_error")}}</p>
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
    {{/if}}
  </template>
}
