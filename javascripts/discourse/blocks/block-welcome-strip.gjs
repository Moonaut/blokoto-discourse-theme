import Component from "@glimmer/component";
import { service } from "@ember/service";
import { block } from "discourse/blocks";
import DButton from "discourse/components/d-button";
import avatar from "discourse/helpers/avatar";
import { i18n } from "discourse-i18n";

@block("theme:blokoto:welcome-strip", {
  description:
    "Saudação compacta para membros logados — ocupa o lugar do hero sem repetir o pitch",
  args: {
    greeting: { type: "string", required: true },
    newTopicLabel: { type: "string" },
    unreadLabel: { type: "string" },
  },
})
export default class BlockWelcomeStrip extends Component {
  @service currentUser;

  get displayName() {
    return this.currentUser?.name || this.currentUser?.username;
  }

  <template>
    <div class="block-welcome-strip__layout">
      <div class="block-welcome-strip__identity">
        {{avatar this.currentUser imageSize="large"}}
        <span class="block-welcome-strip__greeting">
          {{i18n (themePrefix @greeting) name=this.displayName}}
        </span>
      </div>

      <div class="block-welcome-strip__actions">
        {{#if @unreadLabel}}
          <DButton
            class="btn-flat block-welcome-strip__action"
            @href="/unread"
            @translatedLabel={{i18n (themePrefix @unreadLabel)}}
          />
        {{/if}}
        {{#if @newTopicLabel}}
          <DButton
            class="btn-primary block-welcome-strip__action"
            @href="/new-topic"
            @translatedLabel={{i18n (themePrefix @newTopicLabel)}}
          />
        {{/if}}
      </div>
    </div>
  </template>
}
