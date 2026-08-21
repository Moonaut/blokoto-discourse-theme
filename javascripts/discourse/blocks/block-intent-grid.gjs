import Component from "@glimmer/component";
import { block } from "discourse/blocks";
import { i18n } from "discourse-i18n";

@block("theme:blokoto:intent-grid", {
  description:
    "Container em grade para os cartões de intenção do topo da homepage",
  container: true,
  args: {
    title: { type: "string" },
  },
})
export default class BlockIntentGrid extends Component {
  <template>
    <section class="block-intent-grid__layout">
      {{#if @title}}
        <h2 class="block-intent-grid__title">{{i18n (themePrefix @title)}}</h2>
      {{/if}}

      <div class="block-intent-grid__grid">
        {{#each @children key="key" as |child|}}
          <child.Component />
        {{/each}}
      </div>
    </section>
  </template>
}
