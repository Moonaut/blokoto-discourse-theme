import Component from "@glimmer/component";
import { block } from "discourse/blocks";
import DButton from "discourse/ui-kit/d-button";
import dIcon from "discourse/ui-kit/helpers/d-icon";
import { i18n } from "discourse-i18n";

@block("theme:blokoto:hero", {
  description: "The Blokoto homepage hero with an isometric island scene",
  args: {
    eyebrow: { type: "string" },
    title: { type: "string", required: true },
    subtitle: { type: "string" },
    primaryLabel: { type: "string" },
    primaryUrl: { type: "string" },
    secondaryLabel: { type: "string" },
    secondaryUrl: { type: "string" },
  },
})
export default class BlockHero extends Component {
  <template>
    <section class="blokoto-hero">
      <div class="blokoto-hero__content">
        <p class="blokoto-hero__eyebrow">
          <span aria-hidden="true" class="blokoto-hero__eyebrow-dot"></span>
          {{i18n (themePrefix @eyebrow)}}
        </p>

        <h1 class="blokoto-hero__title">
          {{i18n (themePrefix @title)}}
        </h1>

        {{#if @subtitle}}
          <p class="blokoto-hero__subtitle">
            {{i18n (themePrefix @subtitle)}}
          </p>
        {{/if}}

        <div class="blokoto-hero__actions">
          {{#if @primaryUrl}}
            <DButton
              class="btn-primary blokoto-hero__primary"
              @href={{@primaryUrl}}
              @icon="arrow-right"
              @translatedLabel={{i18n (themePrefix @primaryLabel)}}
            />
          {{/if}}

          {{#if @secondaryUrl}}
            <a class="blokoto-hero__secondary" href={{@secondaryUrl}}>
              {{i18n (themePrefix @secondaryLabel)}}
              {{dIcon "arrow-up-right"}}
            </a>
          {{/if}}
        </div>

        <ul
          aria-label={{i18n (themePrefix "hero.features_aria")}}
          class="blokoto-hero__features"
        >
          <li class="blokoto-hero__feature">
            {{dIcon "compass"}}
            {{i18n (themePrefix "hero.feature_worlds")}}
          </li>
          <li class="blokoto-hero__feature">
            {{dIcon "users"}}
            {{i18n (themePrefix "hero.feature_avatars")}}
          </li>
          <li class="blokoto-hero__feature">
            {{dIcon "fire"}}
            {{i18n (themePrefix "hero.feature_together")}}
          </li>
        </ul>
      </div>

      <div aria-hidden="true" class="blokoto-hero__scene">
        <div class="blokoto-hero__brand"></div>
        <div class="blokoto-hero__planet"></div>
        <div class="blokoto-hero__ring"></div>

        <div class="blokoto-cube --one">
          <span class="blokoto-cube__face --front"></span>
          <span class="blokoto-cube__face --right"></span>
          <span class="blokoto-cube__face --top"></span>
        </div>

        <div class="blokoto-cube --two">
          <span class="blokoto-cube__face --front"></span>
          <span class="blokoto-cube__face --right"></span>
          <span class="blokoto-cube__face --top"></span>
        </div>

        <div class="blokoto-cube --three">
          <span class="blokoto-cube__face --front"></span>
          <span class="blokoto-cube__face --right"></span>
          <span class="blokoto-cube__face --top"></span>
        </div>

        <div class="blokoto-hero__scene-floor"></div>
      </div>
    </section>
  </template>
}
