import Component from "@glimmer/component";
import { service } from "@ember/service";
import { block } from "discourse/blocks";
import AsyncContent from "discourse/components/async-content";
import { ajax } from "discourse/lib/ajax";
import { bind } from "discourse/lib/decorators";
import { shortDateNoYear } from "discourse/lib/formatter";
import { i18n } from "discourse-i18n";

@block("theme:blokoto:stats-bar", {
  description:
    "Sinais de vida da comunidade: membros, ativos na semana, posts na semana e último release",
  args: {
    membersLabel: { type: "string", required: true },
    activeLabel: { type: "string", required: true },
    postsLabel: { type: "string", required: true },
    releaseLabel: { type: "string", required: true },
    onlineLabel: { type: "string" },
    releaseTag: { type: "string" },
    showOnline: { type: "boolean", default: false },
  },
})
export default class BlockStatsBar extends Component {
  @service store;

  compact(value) {
    if (typeof value !== "number") {
      return "—";
    }
    return new Intl.NumberFormat(undefined, {
      notation: "compact",
      maximumFractionDigits: 1,
    }).format(value);
  }

  async fetchOnlineCount() {
    // O plugin discourse-whos-online é opcional. Se não estiver instalado a
    // rota devolve 404 e o slot simplesmente não é renderizado.
    try {
      const data = await ajax("/whos-online.json");
      return data?.users?.length ?? null;
    } catch {
      return null;
    }
  }

  async fetchLatestRelease(tag) {
    if (!tag) {
      return null;
    }
    try {
      const topicList = await this.store.findFiltered("topicList", {
        filter: `tag/${tag}/l/latest`,
      });
      return topicList?.topics?.[0] ?? null;
    } catch {
      return null;
    }
  }

  @bind
  async fetchStats() {
    const [about, release, online] = await Promise.all([
      ajax("/about.json"),
      this.fetchLatestRelease(this.args.releaseTag),
      this.args.showOnline ? this.fetchOnlineCount() : Promise.resolve(null),
    ]);

    const stats = about?.about?.stats ?? {};

    return {
      members: this.compact(stats.user_count),
      active: this.compact(stats.active_users_7_days),
      posts: this.compact(stats.posts_7_days),
      online: typeof online === "number" ? this.compact(online) : null,
      releaseTitle: release?.title ?? null,
      releaseUrl: release?.url ?? null,
      releaseDate: release?.created_at
        ? shortDateNoYear(new Date(release.created_at))
        : null,
    };
  }

  <template>
    <AsyncContent @asyncData={{this.fetchStats}}>
      <:loading>
        <div class="block-stats-bar__layout --loading"></div>
      </:loading>

      <:content as |stats|>
        <dl class="block-stats-bar__layout">
          <div class="block-stats-bar__stat">
            <dt class="block-stats-bar__label">{{i18n
                (themePrefix @membersLabel)
              }}</dt>
            <dd class="block-stats-bar__value">{{stats.members}}</dd>
          </div>

          {{#if stats.online}}
            <div class="block-stats-bar__stat">
              <dt class="block-stats-bar__label">{{i18n
                  (themePrefix @onlineLabel)
                }}</dt>
              <dd class="block-stats-bar__value">{{stats.online}}</dd>
            </div>
          {{/if}}

          <div class="block-stats-bar__stat">
            <dt class="block-stats-bar__label">{{i18n
                (themePrefix @activeLabel)
              }}</dt>
            <dd class="block-stats-bar__value">{{stats.active}}</dd>
          </div>

          <div class="block-stats-bar__stat">
            <dt class="block-stats-bar__label">{{i18n
                (themePrefix @postsLabel)
              }}</dt>
            <dd class="block-stats-bar__value">{{stats.posts}}</dd>
          </div>

          {{#if stats.releaseTitle}}
            <div class="block-stats-bar__stat --release">
              <dt class="block-stats-bar__label">{{i18n
                  (themePrefix @releaseLabel)
                }}</dt>
              <dd class="block-stats-bar__value">
                <a
                  class="block-stats-bar__release-link"
                  href={{stats.releaseUrl}}
                >{{stats.releaseTitle}}</a>
                <span class="block-stats-bar__release-date">{{stats.releaseDate}}</span>
              </dd>
            </div>
          {{/if}}
        </dl>
      </:content>
    </AsyncContent>
  </template>
}
