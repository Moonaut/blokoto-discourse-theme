import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { on } from "@ember/modifier";
import { service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";
import { bind } from "discourse/lib/decorators";
import getURL from "discourse/lib/get-url";
import DAsyncContent from "discourse/ui-kit/d-async-content";
import { i18n } from "discourse-i18n";
import {
  endOfDay,
  formatEventDay,
  formatEventMonth,
  formatEventTime,
  parseEventDate,
} from "../lib/event-time.js";

const UPCOMING_WINDOW_DAYS = 180;
const SKELETON_ROWS = 3;

export default class BlokotoHomeEvents extends Component {
  @service siteSettings;

  @tracked retryCount = 0;

  get enabled() {
    return Boolean(
      this.siteSettings.discourse_events_enabled &&
      this.siteSettings.discourse_post_event_enabled
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
  async fetchEvents({ count }) {
    const now = new Date();
    const before = new Date(
      now.getTime() + UPCOMING_WINDOW_DAYS * 24 * 60 * 60 * 1000
    );
    const { events = [] } = await ajax("/discourse-post-event/events", {
      data: {
        after: now.toISOString(),
        before: before.toISOString(),
        include_ongoing: true,
        order: "asc",
        limit: count,
      },
    });

    const items = [];

    for (const event of events) {
      const startsAt = parseEventDate(event.starts_at, event.all_day);
      if (!startsAt) {
        continue;
      }

      const endsAt = parseEventDate(event.ends_at, event.all_day);
      const endsOn = endsAt
        ? event.all_day
          ? endOfDay(endsAt)
          : endsAt
        : event.all_day
          ? endOfDay(startsAt)
          : startsAt;

      if (endsOn <= now) {
        continue;
      }

      const topic = event.post?.topic;

      items.push({
        key: `${event.id}-${event.starts_at}`,
        title: event.name || topic?.title || null,
        url:
          event.post?.url ||
          (topic ? getURL(`/t/${topic.slug}/${topic.id}`) : null),
        startsAt,
        datetime: event.all_day
          ? String(event.starts_at).slice(0, 10)
          : startsAt.toISOString(),
        monthLabel: formatEventMonth(startsAt),
        dayLabel: formatEventDay(startsAt),
        timeLabel: formatEventTime(startsAt),
        allDay: Boolean(event.all_day),
        ongoing: startsAt <= now && endsOn > now,
      });
    }

    items.sort((a, b) => a.startsAt - b.startsAt);

    return items.length ? items.slice(0, count) : null;
  }

  <template>
    {{#if this.enabled}}
      <section
        aria-labelledby="blokoto-rail-events-title"
        class="blokoto-rail__section"
      >
        <header class="blokoto-rail__header">
          <h2 class="blokoto-rail__title" id="blokoto-rail-events-title">
            {{i18n (themePrefix "home.events.title")}}
          </h2>
          <a
            aria-label={{i18n (themePrefix "home.events.view_all")}}
            class="blokoto-rail__link"
            href={{getURL "/upcoming-events"}}
          >
            {{i18n (themePrefix "home.view_all")}}
          </a>
        </header>

        <DAsyncContent
          @asyncData={{this.fetchEvents}}
          @context={{this.context}}
          @retainWhileReloading={{true}}
        >
          <:loading>
            <div aria-busy="true" class="blokoto-rail__skeleton">
              {{#each this.placeholders as |placeholder|}}
                <div
                  class="blokoto-rail__skeleton-row"
                  data-placeholder={{placeholder}}
                >
                  <span class="blokoto-skeleton --date"></span>
                  <span class="blokoto-rail__skeleton-lines">
                    <span class="blokoto-skeleton --title"></span>
                    <span class="blokoto-skeleton --meta"></span>
                  </span>
                </div>
              {{/each}}
            </div>
          </:loading>

          <:content as |items|>
            <ul class="blokoto-rail__list">
              {{#each items as |item|}}
                <li class="blokoto-rail__item blokoto-rail__event">
                  <time
                    class="blokoto-rail__event-date"
                    datetime={{item.datetime}}
                  >
                    <span class="blokoto-rail__event-month">
                      {{item.monthLabel}}
                    </span>
                    <span class="blokoto-rail__event-day">
                      {{item.dayLabel}}
                    </span>
                  </time>

                  <div class="blokoto-rail__event-body">
                    <h3 class="blokoto-rail__event-title">
                      {{#if item.url}}
                        <a href={{item.url}}>
                          {{#if item.title}}
                            {{item.title}}
                          {{else}}
                            {{i18n (themePrefix "home.events.untitled")}}
                          {{/if}}
                        </a>
                      {{else if item.title}}
                        {{item.title}}
                      {{else}}
                        {{i18n (themePrefix "home.events.untitled")}}
                      {{/if}}
                    </h3>

                    <p class="blokoto-rail__event-meta">
                      {{#if item.ongoing}}
                        <span class="blokoto-rail__event-now">
                          {{i18n (themePrefix "home.events.now")}}
                        </span>
                      {{else if item.allDay}}
                        {{i18n (themePrefix "home.events.all_day")}}
                      {{else}}
                        {{item.timeLabel}}
                      {{/if}}
                    </p>
                  </div>
                </li>
              {{/each}}
            </ul>
          </:content>

          <:empty>
            <p class="blokoto-rail__empty">
              {{i18n (themePrefix "home.events.empty")}}
            </p>
          </:empty>

          <:error>
            <div class="blokoto-rail__error">
              <p>{{i18n (themePrefix "home.events.load_error")}}</p>
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
