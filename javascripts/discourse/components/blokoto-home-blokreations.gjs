import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { on } from "@ember/modifier";
import didInsert from "@ember/render-modifiers/modifiers/did-insert";
import { service } from "@ember/service";
import { trustHTML } from "@ember/template";
import { ajax } from "discourse/lib/ajax";
import { bind } from "discourse/lib/decorators";
import getURL from "discourse/lib/get-url";
import Category from "discourse/models/category";
import DAsyncContent from "discourse/ui-kit/d-async-content";
import dIcon from "discourse/ui-kit/helpers/d-icon";
import { i18n } from "discourse-i18n";

const SKELETON_CARDS = 4;
const MAX_TOPICS = 100;

// Upload URLs are cooked relative to the site host. In production that host is
// the page host; behind a local port it needs the port added back.
function normalizeImageUrl(url) {
  if (!url?.startsWith("//")) {
    return url;
  }

  const imageUrl = new URL(`${window.location.protocol}${url}`);

  if (imageUrl.hostname === window.location.hostname) {
    imageUrl.port = window.location.port;
  }

  return imageUrl.href;
}

export default class BlokotoHomeBlokreations extends Component {
  @service store;

  @tracked retryCount = 0;
  @tracked canScrollPrev = false;
  @tracked canScrollNext = false;
  @tracked missingCategory = false;

  track = null;

  constructor(owner, args) {
    super(owner, args);
    window.addEventListener("resize", this.updateScrollState);
  }

  willDestroy() {
    window.removeEventListener("resize", this.updateScrollState);
    super.willDestroy(...arguments);
  }

  get enabled() {
    return Boolean(this.args.categorySlug?.trim());
  }

  get visible() {
    return this.enabled && !this.missingCategory;
  }

  get categoryPath() {
    return (this.args.categorySlug ?? "")
      .split("/")
      .map((part) => part.trim())
      .filter(Boolean);
  }

  get categoryUrl() {
    return this.enabled ? getURL(`/c/${this.categoryPath.join("/")}`) : null;
  }

  get prevDisabled() {
    return !this.canScrollPrev;
  }

  get nextDisabled() {
    return !this.canScrollNext;
  }

  get placeholders() {
    return Array.from({ length: SKELETON_CARDS });
  }

  get context() {
    return {
      count: this.args.count,
      categorySlug: this.args.categorySlug,
      retryCount: this.retryCount,
    };
  }

  @bind
  retry() {
    this.retryCount++;
  }

  @bind
  async fetchBlokreations({ count, categorySlug }) {
    const slugPath = (categorySlug ?? "")
      .split("/")
      .map((part) => part.trim())
      .filter(Boolean);
    if (!slugPath.length) {
      return null;
    }

    this.missingCategory = false;

    const path = slugPath.join("/");
    let category = Category.findBySlugPath(slugPath);

    if (!category) {
      try {
        const response = await ajax(`/c/${path}/find_by_slug.json`);
        category = response.category;
      } catch (error) {
        if (error?.jqXHR?.status === 404 || error?.status === 404) {
          this.missingCategory = true;
          return null;
        }
        throw error;
      }
    }

    if (!category?.id) {
      this.missingCategory = true;
      return null;
    }

    const topicList = await this.store.findFiltered("topicList", {
      filter: `c/${path}/${category.id}/l/latest`,
      params: { per_page: Math.min(count * 4, MAX_TOPICS) },
    });

    const topics = (topicList?.topics ?? [])
      .filter((topic) => topic.image_url)
      .slice(0, count)
      .map((topic) => ({
        topic,
        imageUrl: normalizeImageUrl(topic.image_url),
      }));

    return { topics };
  }

  @bind
  setupTrack(element) {
    this.track = element;
    this.updateScrollState();
  }

  @bind
  updateScrollState() {
    const element = this.track;

    if (!element) {
      return;
    }

    this.canScrollPrev = element.scrollLeft > 2;
    this.canScrollNext =
      element.scrollLeft + element.clientWidth < element.scrollWidth - 2;
  }

  @bind
  scrollPrev() {
    this.#scroll(-1);
  }

  @bind
  scrollNext() {
    this.#scroll(1);
  }

  #scroll(direction) {
    const element = this.track;

    if (!element) {
      return;
    }

    const reduceMotion = window.matchMedia(
      "(prefers-reduced-motion: reduce)"
    ).matches;

    element.scrollBy({
      left: direction * Math.round(element.clientWidth * 0.8),
      behavior: reduceMotion ? "auto" : "smooth",
    });
  }

  <template>
    {{#if this.visible}}
      <section
        aria-labelledby="blokoto-blokreations-title"
        class="blokoto-home__blokreations"
      >
        <header class="blokoto-blokreations__header">
          <h2
            class="blokoto-blokreations__heading"
            id="blokoto-blokreations-title"
          >
            {{i18n (themePrefix "home.blokreations.title")}}
          </h2>

          <div class="blokoto-blokreations__actions">
            <button
              aria-label={{i18n (themePrefix "home.blokreations.prev")}}
              class="blokoto-blokreations__nav"
              disabled={{this.prevDisabled}}
              type="button"
              {{on "click" this.scrollPrev}}
            >
              {{dIcon "angle-left"}}
            </button>

            <button
              aria-label={{i18n (themePrefix "home.blokreations.next")}}
              class="blokoto-blokreations__nav"
              disabled={{this.nextDisabled}}
              type="button"
              {{on "click" this.scrollNext}}
            >
              {{dIcon "angle-right"}}
            </button>

            <a
              aria-label={{i18n (themePrefix "home.blokreations.view_all")}}
              class="blokoto-blokreations__link"
              href={{this.categoryUrl}}
            >
              {{i18n (themePrefix "home.view_all")}}
            </a>
          </div>
        </header>

        <DAsyncContent
          @asyncData={{this.fetchBlokreations}}
          @context={{this.context}}
          @retainWhileReloading={{true}}
        >
          <:loading>
            <div aria-busy="true" class="blokoto-blokreations__track --loading">
              {{#each this.placeholders as |placeholder|}}
                <div
                  class="blokoto-blokreations__skeleton"
                  data-placeholder={{placeholder}}
                >
                  <span class="blokoto-skeleton --image"></span>
                  <span class="blokoto-skeleton --title"></span>
                </div>
              {{/each}}
            </div>
          </:loading>

          <:content as |data|>
            {{#if data.topics.length}}
              <ul
                aria-label={{i18n
                  (themePrefix "home.blokreations.carousel_label")
                }}
                class="blokoto-blokreations__track"
                tabindex="0"
                {{didInsert this.setupTrack}}
                {{on "scroll" this.updateScrollState}}
              >
                {{#each data.topics as |item|}}
                  <li class="blokoto-blokreations__item">
                    <a
                      class="blokoto-blokreations__card"
                      href={{item.topic.url}}
                    >
                      <span class="blokoto-blokreations__media">
                        <img
                          alt=""
                          decoding="async"
                          loading="lazy"
                          src={{item.imageUrl}}
                        />
                      </span>

                      <span class="blokoto-blokreations__card-title">
                        {{trustHTML item.topic.fancyTitle}}
                      </span>
                    </a>
                  </li>
                {{/each}}
              </ul>
            {{else}}
              <p class="blokoto-blokreations__empty">
                {{i18n (themePrefix "home.blokreations.empty")}}
                <a
                  class="blokoto-blokreations__empty-link"
                  href={{this.categoryUrl}}
                >
                  {{i18n (themePrefix "home.blokreations.empty_action")}}
                </a>
              </p>
            {{/if}}
          </:content>

          <:empty></:empty>

          <:error>
            <div class="blokoto-blokreations__error">
              <p>{{i18n (themePrefix "home.blokreations.load_error")}}</p>
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
