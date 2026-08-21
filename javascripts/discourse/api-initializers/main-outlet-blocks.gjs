import { apiInitializer } from "discourse/lib/api";
import BlockBackLink from "../blocks/block-back-link";

// Como a navegação lateral permanente foi removida (site setting
// `navigation_menu` = header_dropdown), as páginas internas precisam de um
// caminho de volta explícito para a homepage.
export default apiInitializer((api) => {
  api.renderBlocks("main-outlet-blocks", [
    {
      block: BlockBackLink,
      id: "back-link",
      args: {
        label: "navigation.back_home",
        href: "/",
      },
      conditions: [
        {
          type: "route",
          pages: ["CATEGORY_PAGES", "TAG_PAGES", "DISCOVERY_PAGES"],
        },
        { not: { type: "route", pages: ["HOMEPAGE"] } },
        { type: "setting", source: settings, name: "show_back_link", enabled: true },
      ],
    },
  ]);
});
