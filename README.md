# Blokoto Community Theme

A full Discourse theme for `community.blokoto.com`, built to feel like the
Blokoto web platform: a deep-indigo grid canvas, floating island panels, warm
orange accents, Space Grotesk type, and a block-built custom homepage.

## Preview

| Dark | Light |
| --- | --- |
| ![Dark homepage](docs/preview-dark.webp) | ![Light homepage](docs/preview-light.webp) |

![Mobile homepage](docs/preview-mobile.webp)

![Category page](docs/preview-category.webp)

The theme uses Discourse's current theme conventions:

- a packaged full theme with light and dark color schemes;
- the Blocks API (`@block`, `api.renderBlocks`) with one initializer per outlet;
- the `custom_homepage` theme modifier;
- theme settings read in the layout initializer and passed to blocks as args;
- theme translations in English, Brazilian Portuguese, and Spanish;
- BEM SCSS with core container/viewport mixins, no viewport-width layout hacks;
- local font and image assets, no third-party CDN requests.

## What is included

### Custom homepage

`javascripts/discourse/api-initializers/main-outlet-blocks.gjs` renders the
hero on the `main-outlet-blocks` outlet. `homepage-blocks.gjs` composes the
homepage below it:

| Block | Purpose |
| --- | --- |
| `theme:blokoto:hero` | Headline, CTAs, community value props, and a CSS-only isometric voxel scene. |
| `theme:blokoto:category-grid` | Bento grid of the most active categories. Optional category IDs and count. |
| `theme:blokoto:topic-grid` | Card grid of discussions. Used for both the optional featured tag and the latest topics. |
| `theme:blokoto:links` | Sidebar panel of community starting points. |
| `theme:blokoto:cta` | Compact join call-to-action in the sidebar. |
| `theme:blokoto:category-banner` | Island banner on category pages. |
| `theme:blokoto:home-link` | "Community home" link in the sidebar. |

The homepage is assembled in `homepage-blocks.gjs`, so every setting,
condition, and slot is visible in one declarative layout. The block components
are small and reusable rather than homepage-only.

### Settings

| Setting | Default | Notes |
| --- | --- | --- |
| `homepage_show_categories` | `true` | Show the category grid. |
| `homepage_category_ids` | empty | Ordered category picker. Empty = most active top-level categories. |
| `homepage_category_count` | `6` | 1–12 categories. |
| `homepage_show_featured` | `true` | Show the featured discussions section. |
| `homepage_featured_tag` | empty | Tag picker; only the first tag is used. Section hides when empty. |
| `homepage_featured_count` | `3` | 1–6 cards. |
| `homepage_latest_count` | `6` | 1–12 cards. |
| `homepage_show_links` | `true` | Show the "Start here" panel. |
| `homepage_cta_url` | `/signup` | Sidebar CTA destination. |
| `hero_primary_url` | `/signup` | Hero primary button destination. |
| `hero_secondary_url` | `/latest` | Hero secondary link destination. |
| `category_banner_category_ids` | empty | Category picker for the banner, including subcategories. Empty = all categories. |
| `category_banner_show_description` | `true` | Show the category description. |

### Colors and tokens

The theme owns tokens under the `--t-Blokoto-*` namespace. Core `--d-*` and
Discourse color variables are overridden only where the layout needs it.

| Token | Light | Dark |
| --- | --- | --- |
| canvas | `#f2f7ff` | `#03051b` |
| surface | `#fff` | `#0e1337` |
| raised | `#f7fbff` | `#141a45` |
| border | `#d4e8ff` | `#1a2354` |
| accent | `#ff4f00` | `#ff5a1f` |
| button | `#cc3a00` | `#cc3a00` |
| text | `#03051b` | `#f5faff` |
| muted text | `#4d6bca` | `#b7d4ff` |

`#cc3a00` is used for filled buttons and active navigation so white labels
clear WCAG AA; the brighter brand orange is reserved for decorative accents,
borders, and glows. The custom homepage hero is intentionally dark in both
schemes.

The grid is drawn as a fixed, tinted mask over the canvas using the bundled
16×16 tile. The color follows the active scheme, so the same asset works for
light and dark.

## Local development

The theme was developed against a local Discourse 2026.11 instance running in
Docker. The `discourse_theme` gem uploads and watches a local checkout.

```bash
# once
gem install discourse_theme

# from the directory that contains this theme
export DISCOURSE_URL=http://localhost:8085
export DISCOURSE_API_KEY=your_admin_api_key

discourse_theme watch DiscourseTheme
```

`discourse_theme watch` will create the theme on first sync and print a preview
URL. Make it the active theme in **Admin → Customize → Themes**, then set it as
the default theme. The custom homepage is activated by the
`"custom_homepage": true` modifier in `about.json`; no page template override is
needed.

Useful commands:

```bash
# upload a one-off change after the theme id is stored by `watch`
discourse_theme upload DiscourseTheme

# validate JS, SCSS, and formatting
pnpm install
pnpm lint

# run the system specs against a configured Discourse checkout
discourse_theme rspec DiscourseTheme
```

### Local Docker notes

The local instance needs PostgreSQL with `pg_trgm`, `hstore`, and `vector`, plus
Redis. If you run the official `discourse/discourse` image yourself, use a
`pgvector/pgvector:pg16` database image and let Discourse run its migrations.
Do not mount an empty named volume over `/var/www/discourse/public/assets`; the
image needs its precompiled assets to boot.

## Structure

```text
about.json
settings.yml
locales/{en,pt_BR,es}.yml
assets/                         bundled fonts, logo, grid tile
common/common.scss              imports only
stylesheets/
  brand/                        fonts, color and size tokens
  app/                          core UI islands, header, sidebar, topics
  components/                   shared section, panel, skeleton styles
  blocks/                       one stylesheet per block
  layouts/                      homepage and outlet composition
javascripts/discourse/
  api-initializers/             one file per block outlet
  blocks/                       @block components
spec/system/                    homepage and category banner system specs
```

## Accessibility

- Text and button tokens meet WCAG AA in both schemes; the bright orange is not
  used for small text on white.
- The voxel scene and grid are decorative and are hidden from assistive
  technology.
- Focus styles are visible on links, cards, inputs, and buttons.
- Motion (cube float, orbit, skeleton pulse) is disabled under
  `prefers-reduced-motion`.
- Layout responds to its container, so the two-column homepage and three-column
  card grids collapse correctly when the Discourse sidebar is open.
- All interactive cards are links with visible titles; decorative visual areas
  are marked `aria-hidden`.

## Notes

- The header wordmark is a CSS mask of `assets/blokoto-logo-white.svg`, tinted by
  the active color scheme. Replace that asset (and the hero logo reference) if
  the brand mark changes.
- The hero planet and cubes are pure CSS, so there is no image payload and they
  remain crisp at any size.
- The homepage hides Discourse's discovery sidebar while the custom homepage is
  active. This is deliberate: the homepage is its own full-width composition.
