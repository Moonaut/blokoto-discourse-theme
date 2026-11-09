import { apiInitializer } from "discourse/lib/api";
import BlockCategoryHeading from "../blocks/block-category-heading.gjs";

export default apiInitializer((api) => {
  api.renderBlocks("main-outlet-blocks", [
    {
      block: BlockCategoryHeading,
      id: "category-heading",
      conditions: { type: "route", pages: ["CATEGORY_PAGES"] },
    },
  ]);
});
