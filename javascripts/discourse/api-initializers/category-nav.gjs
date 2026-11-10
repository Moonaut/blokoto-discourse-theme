import { apiInitializer } from "discourse/lib/api";
import BlokotoCategoryNav from "../components/blokoto-category-nav.gjs";

export default apiInitializer((api) => {
  api.renderInOutlet("before-header-panel", BlokotoCategoryNav);
});
