import Component from "@glimmer/component";
import { block } from "discourse/blocks";
import DButton from "discourse/components/d-button";
import { i18n } from "discourse-i18n";

@block("theme:blokoto:hero", {
  description:
    "Apresentação do produto para visitantes anônimos, com CTAs e mídia de gameplay",
  args: {
    title: { type: "string", required: true },
    subtitle: { type: "string" },
    playLabel: { type: "string" },
    playUrl: { type: "string" },
    signupLabel: { type: "string" },
    signupUrl: { type: "string" },
    videoUrl: { type: "string" },
    posterUrl: { type: "string" },
  },
})
export default class BlockHero extends Component {
  get hasMedia() {
    return !!(this.args.videoUrl || this.args.posterUrl);
  }

  <template>
    <div class="block-hero__layout">
      <div class="block-hero__content">
        <h1 class="block-hero__title">{{i18n (themePrefix @title)}}</h1>

        {{#if @subtitle}}
          <p class="block-hero__subtitle">{{i18n (themePrefix @subtitle)}}</p>
        {{/if}}

        <div class="block-hero__actions">
          {{#if @playUrl}}
            <DButton
              class="btn-primary block-hero__cta"
              @href={{@playUrl}}
              @icon="circle-play"
              @translatedLabel={{i18n (themePrefix @playLabel)}}
            />
          {{/if}}
          {{#if @signupUrl}}
            <DButton
              class="btn-default block-hero__cta"
              @href={{@signupUrl}}
              @translatedLabel={{i18n (themePrefix @signupLabel)}}
            />
          {{/if}}
        </div>
      </div>

      {{#if this.hasMedia}}
        <div class="block-hero__media">
          {{#if @videoUrl}}
            <video
              class="block-hero__video"
              controls
              preload="none"
              playsinline
              poster={{@posterUrl}}
            >
              <source src={{@videoUrl}} />
            </video>
          {{else}}
            <img class="block-hero__poster" src={{@posterUrl}} alt="" />
          {{/if}}
        </div>
      {{/if}}
    </div>
  </template>
}
