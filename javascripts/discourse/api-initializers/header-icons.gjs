import { apiInitializer } from "discourse/lib/api";

export default apiInitializer((api) => {
  api.modifyClass("component:header/contents", {
    get sidebarIcon() {
      return "discourse-sidebar";
    },
  });
});
