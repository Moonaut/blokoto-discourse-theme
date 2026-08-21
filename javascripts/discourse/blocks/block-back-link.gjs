import Component from "@glimmer/component";
import { block } from "discourse/blocks";
import dIcon from "discourse/helpers/d-icon";
import { i18n } from "discourse-i18n";

@block("theme:blokoto:back-link", {
  description:
    "Seta de retorno à homepage, exibida no topo das páginas de categoria e tag",
  args: {
    label: { type: "string", required: true },
    href: { type: "string", default: "/" },
  },
})
export default class BlockBackLink extends Component {
  <template>
    <a href={{@href}} class="block-back-link__layout">
      {{dIcon "arrow-left"}}
      <span class="block-back-link__label">{{i18n (themePrefix @label)}}</span>
    </a>
  </template>
}
