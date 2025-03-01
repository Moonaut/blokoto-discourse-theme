# Canvas Theme Template

Kickstart your custom theme design with a pre-made template.

![Canvas Theme Template - Cover](assets/Cover.png)

Discussion, feedback and more info: https://meta.discourse.org/t/352730

## Custom properties

The template uses CSS custom properties (variables) for consistent styling across the theme.

### Canvas

Additional custom properties added for the template.

| Property Name                     | Description                                   | Undeclared Value               |
| --------------------------------- | --------------------------------------------- | ------------------------------ |
| **Layout**                        |
| `--canvas-nav-space`              | Vertical spacing for navigation-bar items     | `0.75rem`                      |
| `--canvas-content-padding`        | Top and bottom padding for main content       | `1.5rem`                       |
| `--canvas-topic-list-padding`     | Top and bottom padding for topic list items   | `0.8em`                        |
| **Base Styles**                   |
| `--canvas-background`             | Main background color of the theme            | `var(--secondary)`             |
| `--canvas-border`                 | Default border style                          | `1px solid var(--primary-500)` |
| `--canvas-border-light`           | Lighter border style for subtle separators    | `1px solid var(--primary-200)` |
| **Button Styles**                 |
| `--canvas-button-padding`         | Default padding for buttons                   | `0.5em 0.65em`                 |
| `--canvas-button-primary-padding` | Padding for prominent buttons                 | `0.5em 0.65em`                 |
| **Header**                        |
| `--canvas-header-background`      | Header background color\[^1]                  | `var(--header_background)`     |
| `--canvas-header-height`          | Height of the main header                     | `4rem`                         |
| `--canvas-header-border`          | Header bottom border style                    | `none`                         |
| `--canvas-header-shadow`          | Header shadow style                           | `var(--shadow-header)`         |
| **Sidebar**                       |
| `--canvas-sidebar-border`         | Sidebar border style                          | `1px solid var(--primary-low)` |
| `--canvas-sidebar-scrollbar`      | Sidebar scrollbar width, can be set to `none` | `var(--scrollbarWidth)`        |
| **Panels**                        |
| `--canvas-panel-background`       | Panel background color                        | `var(--secondary)`             |
| `--canvas-panel-padding`          | Padding for panels                            | `1rem 2rem`                    |
| `--canvas-panel-radius`           | Border radius for panels                      | `var(--d-border-radius-large)` |
| `--canvas-panel-border`           | Panel border style                            | `none`                         |
| `--canvas-panel-shadow`           | Panel shadow effect                           | `var(--shadow-header)`         |
| **Banners**                       |
| `--canvas-banner-background`      | Banner background style                       | `var(--secondary)`             |
| `--canvas-banner-color`           | Banner text color                             | `var(--primary)`               |
| `--canvas-banner-padding`         | Banner padding                                | `1rem 2rem 1.5rem`             |
| `--canvas-banner-radius`          | Banner border radius                          | `var(--d-border-radius-large)` |
| `--canvas-banner-border`          | Banner border style                           | `none`                         |
| `--canvas-banner-shadow`          | Banner shadow effect                          | `var(--shadow-header)`         |
| **Header Search**                 |
| `--canvas-header-search-border`   | Border style for header search                | `1px solid var(--primary-400)` |
| `--canvas-header-search-padding`  | Padding for header search                     | `0.5em`                        |

[^1]: Can be set as an alternative to the color scheme value `var(--header_background)` as it won't affect color calculations like `var(--header-primary-low-mid)`

### Discourse Core

You can also override any custom properties from Discourse core. Below is a small selection of common properties.

| Property Name                      | Description                                    | Default Value                   |
| ---------------------------------- | ---------------------------------------------- | ------------------------------- |
| **Layout**                         |
| `--d-max-width`                    | Maximum width of the main content area         | `1110px`                        |
| **Border Radius**                  |
| `--d-border-radius`                | Default border radius for elements             | `2px`                           |
| `--d-border-radius-large`          | Larger border radius for bigger elements       | `2px`                           |
| `--d-button-border-radius`         | Border radius for buttons                      | `2px`                           |
| `--d-input-border-radius`          | Border radius for input fields                 | `var(--d-button-border-radius)` |
| `--d-nav-pill-border-radius`       | Border radius for navigation pills             | `var(--d-button-border-radius)` |
| **Sidebar**                        |
| `--d-sidebar-width`                | Width of the sidebar                           | `17em`                          |
| `--d-sidebar-background`           | Sidebar background color                       | `var(--secondary)`              |
| `--d-sidebar-row-height`           | Height of sidebar rows                         | `2.2em`                         |
| `--d-sidebar-highlight-background` | Background color for highlighted sidebar items | `var(--primary-low)`            |
