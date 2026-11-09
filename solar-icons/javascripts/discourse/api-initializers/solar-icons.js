import { apiInitializer } from "discourse/lib/api";
import { ICON_MAP } from "../lib/solar-icon-map.js";

// Keep in sync with the styles baked into assets/icons-sprite.svg.
const STYLES = ["linear", "bold"];
const DEFAULT_STYLE = "linear";
const DEFAULT_STROKE_WIDTH = "1.5";

export default apiInitializer((api) => {
  const style = STYLES.includes(settings.icon_style)
    ? settings.icon_style
    : DEFAULT_STYLE;

  document.documentElement.style.setProperty(
    "--solar-icons-stroke-width",
    String(settings.stroke_width || DEFAULT_STROKE_WIDTH)
  );

  const ignored = new Set(
    (settings.ignored_icons || "")
      .split("|")
      .map((name) => name.trim())
      .filter(Boolean)
  );

  for (const [discourseIcon, solarIcon] of Object.entries(ICON_MAP)) {
    if (ignored.has(discourseIcon)) {
      continue;
    }

    api.replaceIcon(discourseIcon, `si-${solarIcon}-${style}`);
  }
});
