import Component from "@glimmer/component";
import { block } from "discourse/blocks";
import DButton from "discourse/ui-kit/d-button";
import dIcon from "discourse/ui-kit/helpers/d-icon";
import { i18n } from "discourse-i18n";

@block("theme:blokoto:cta", {
  description: "A compact call to action for the homepage sidebar",
  args: {
    eyebrow: { type: "string" },
    title: { type: "string", required: true },
    description: { type: "string" },
    buttonLabel: { type: "string" },
    buttonUrl: { type: "string" },
  },
})
export default class BlockCta extends Component {
  <template>
    <section class="blokoto-cta">
      <span aria-hidden="true" class="blokoto-cta__spark">{{dIcon
          "bolt"
        }}</span>

      {{#if @eyebrow}}
        <p class="blokoto-cta__eyebrow">{{i18n (themePrefix @eyebrow)}}</p>
      {{/if}}
      <h2 class="blokoto-cta__title">{{i18n (themePrefix @title)}}</h2>
      {{#if @description}}
        <p class="blokoto-cta__description">{{i18n
            (themePrefix @description)
          }}</p>
      {{/if}}

      {{#if @buttonUrl}}
        <DButton
          class="btn-primary blokoto-cta__button"
          @href={{@buttonUrl}}
          @icon="arrow-right"
          @translatedLabel={{i18n (themePrefix @buttonLabel)}}
        />
      {{/if}}
    </section>
  </template>
}
