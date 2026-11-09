import Component from "@glimmer/component";
import { block } from "discourse/blocks";
import dIcon from "discourse/ui-kit/helpers/d-icon";
import { i18n } from "discourse-i18n";

@block("theme:blokoto:links", {
  description: "A panel of helpful starting points for the community",
  args: {
    title: { type: "string", required: true },
    icon: { type: "string" },
    links: { type: "array", default: [] },
  },
})
export default class BlockLinks extends Component {
  <template>
    {{#if @links.length}}
      <section class="blokoto-panel">
        <header class="blokoto-panel__header">
          {{#if @icon}}
            <span class="blokoto-panel__icon">{{dIcon @icon}}</span>
          {{/if}}
          <h2 class="blokoto-panel__title">{{i18n (themePrefix @title)}}</h2>
        </header>

        <ul class="blokoto-link-list">
          {{#each @links as |link|}}
            <li class="blokoto-link-list__item">
              <a
                class="blokoto-link-list__link"
                href={{link.url}}
                rel={{if link.external "noopener noreferrer"}}
                target={{if link.external "_blank"}}
              >
                <span class="blokoto-link-list__icon">{{dIcon link.icon}}</span>
                <span class="blokoto-link-list__label">{{i18n
                    (themePrefix link.label)
                  }}</span>
                {{dIcon "chevron-right"}}
              </a>
            </li>
          {{/each}}
        </ul>
      </section>
    {{/if}}
  </template>
}
