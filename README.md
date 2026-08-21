# Tema Blokoto

Tema completo para o Discourse com homepage customizada orientada a intenção, construído sobre a Blocks API e o modifier `custom_homepage`.

Requer Discourse com Blocks API (builds de 2026). Testado contra `v2026.8.0`.

## Instalação

1. Suba este diretório para um repositório git.
2. Em **Admin → Personalizar → Temas → Instalar → A partir de um repositório git**, cole a URL.
3. Marque como tema padrão.
4. Para desenvolvimento local, use o CLI: `discourse_theme watch .`

## Configuração obrigatória após instalar

Três coisas não funcionam sem ajuste manual:

**IDs de categoria.** Os cartões de intenção precisam de `support_category_id`, `suggestions_category_id` e `bugs_category_id`. Sem eles o cartão ainda aparece, mas mostra o texto de fallback em vez da contagem real de tópicos.

**Remover a sidebar.** Não é feito pelo tema. Em **Admin → Configurações**, mude `navigation_menu` de `sidebar` para `header_dropdown`. A navegação vira um menu no header e o espaço lateral some. A sidebar do admin é um sistema separado e não é afetada.

**Tag das Blokreations.** O padrão é `creation:avatar`, deduzido do print da homepage atual. Se vocês tiverem uma tag dedicada para criações, ajuste `blokreations_tag`.

## Estrutura

```
javascripts/discourse/
├── api-initializers/
│   ├── homepage-blocks.gjs      # monta a homepage
│   └── main-outlet-blocks.gjs   # back-link nas páginas internas
└── blocks/
    ├── block-hero.gjs           # pitch + trailer (anônimos)
    ├── block-welcome-strip.gjs  # saudação (logados)
    ├── block-stats-bar.gjs      # membros, ativos, posts, release
    ├── block-intent-grid.gjs    # container em grade
    ├── block-intent-card.gjs    # cartão individual
    ├── block-activity-list.gjs  # feed com abas
    ├── block-category-list.gjs  # categorias compactas
    ├── block-blokreations.gjs   # galeria por tag
    └── block-back-link.gjs      # seta de retorno
```

Um arquivo de initializer por outlet — a Blocks API não permite dois `renderBlocks` para outlets diferentes no mesmo arquivo.

## Como o hero aparece só para visitantes

Não há JavaScript de detecção. O hero e a faixa de boas-vindas são filhos de um `BlockHead`, que renderiza apenas o primeiro filho cuja condição passa:

```js
{
  block: BlockHead,
  children: [
    { block: BlockHero, conditions: { type: "user", loggedIn: false } },
    { block: BlockWelcomeStrip },  // sem condição = fallback
  ],
}
```

## Pontos a verificar na primeira execução

**Chaves de `/about.json`.** A barra de estatísticas lê `about.stats.user_count`, `active_users_7_days` e `posts_7_days`. Confirme os nomes acessando `https://seu-forum/about.json` — se algum diferir, o campo mostra `—` em vez de quebrar.

**Aba "sem resposta".** O feed usa `hot`, `latest` e `top`, que são filtros do core. "Sem resposta" não é um filtro nativo; se quiserem, dá para trocar `top` por uma consulta à rota `/filter` com `q=posts:1`, mas isso exige testar na instância de vocês.

**Miniaturas das Blokreations.** Dependem do modifier `topic_thumbnail_sizes` já declarado no `about.json` e de o tópico ter uma imagem no primeiro post. Sem imagem, o card cai num placeholder.

**`show_online_now`.** Desligado por padrão. Se ligarem sem o plugin `discourse-whos-online`, a requisição falha silenciosamente e o campo é omitido — nada quebra.
