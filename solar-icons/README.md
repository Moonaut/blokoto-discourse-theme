# Solar Icons

A Discourse theme component. Replaces the default solid icons from Font Awesome
with the open-source [Solar icon set](https://solar-icons.dev/docs/v2) by
[480 Design](https://www.figma.com/community/file/1166831539721848736).

It follows the same approach as
[discourse-lucide-icons](https://github.com/discourse/discourse-lucide-icons):
a single SVG sprite named `icons-sprite` is handed to Discourse's icon pipeline,
and an API initializer maps Font Awesome icon names onto the Solar symbols.

## Install

Install as a theme component, then add it to your theme under
**Admin → Customize → Themes → Components**.

```bash
# from the repository root
discourse_theme upload DiscourseTheme/solar-icons
```

On a local instance, `watch` gives you live reload:

```bash
discourse_theme watch DiscourseTheme/solar-icons
```

## Settings

| Setting | Default | Notes |
| --- | --- | --- |
| `icon_style` | `linear` | `linear` (outline) or `bold` (solid). Both styles ship in the sprite. |
| `stroke_width` | `1.5` | 1 – 2 px. Only affects `linear` icons; filled `bold` glyphs ignore it. |
| `ignored_icons` | *empty* | Pipe-separated Discord icon names to leave on Font Awesome. |

`ignored_icons` matches the *Font Awesome* name, not the Solar name:
`heart|star|comments`.

## How it works

```text
assets/icons-sprite.svg                     generated sprite, si-<icon>-<style> symbols
javascripts/discourse/
  api-initializers/solar-icons.js           reads settings, calls api.replaceIcon()
  lib/solar-icon-map.js                     generated Font Awesome => Solar map
scripts/
  icon-map.json                             source of truth for the mapping
  build-sprite.mjs                          regenerates the sprite and the map
common/common.scss                          --solar-icons-stroke-width wiring
```

`api.replaceIcon("comments", "si-chat-round-line-linear")` rewrites the icon name
Discourse renders. The referenced `<symbol>` is already in the document because
Discourse inlines the theme sprite (the asset key must stay `icons-sprite`).

The sprite is 397 KB for 198 icons × 2 styles. Discourse rejects theme sprites
above 1 MB, so the build script fails before that happens.

Duplicate Font Awesome names are collapsed into one Solar symbol: `heart`,
`far-heart`, `d-liked`, `notification.liked` and friends all use
`si-heart-linear`.

## Changing the icon set

1. Edit `scripts/icon-map.json`. Keys are Discourse/Font Awesome icon names;
   values are Solar icon names (the file stem, without the style suffix), from
   the [Solar catalog](https://solar-icons.dev/icons).
2. Rebuild:

   ```bash
   node scripts/build-sprite.mjs
   ```

   The script validates every referenced icon exists in every style, downloads
   `@solar-icons/static@2.3.4` once into `scripts/.cache/` (git-ignored), then
   rewrites `assets/icons-sprite.svg` and
   `javascripts/discourse/lib/solar-icon-map.js`.
3. Commit all three files.

The Solar package version is pinned in `scripts/build-sprite.mjs`. Bump
`SOLAR_VERSION` to take a new release.

## Style choice

`linear` is the outlined family and matches what the Blokoto Frontend uses for
most icons (1.5px stroke, 24×24 grid). `bold` is Solar's solid family and is what
the Frontend uses for filled/active states. Both are shipped so the style can be
switched per-site without a rebuild; there is no per-icon style override,
because Discourse renders every icon through the same substitution table.

The `outline`, `broken` and duotone styles are not shipped to stay well under
the sprite size limit. To use one instead, change `STYLES` in
`scripts/build-sprite.mjs`, rebuild, and update the `icon_style` choices in
`settings.yml` and `STYLES` in the initializer.

## Attribution

Icons are by 480 Design under
[CC BY 4.0](https://creativecommons.org/licenses/by/4.0/). See
[LICENSE_SOLAR](LICENSE_SOLAR). The component's own code is MIT; see
[LICENSE](LICENSE).

Icons are converted mechanically from `@solar-icons/static` (path data only,
`<svg>` re-rooted as `<symbol>`); the artwork is unchanged.

## Notes

- Icons not listed in `scripts/icon-map.json` keep their Font Awesome glyph, so
  a partial map degrades gracefully.
- `stroke_width` is applied through a CSS custom property on `svg.d-icon`; the
  sprite symbols intentionally carry no `stroke-width` attribute so inheritance
  can reach the cloned paths.
- The sprite is inlined on every page by Discourse. Keep additions deliberate.
