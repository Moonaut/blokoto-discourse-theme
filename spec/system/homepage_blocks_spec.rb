# frozen_string_literal: true

RSpec.describe "Blokoto homepage blocks" do
  let!(:theme) { upload_theme_or_component }

  fab!(:user)
  fab!(:category) { Fabricate(:category, name: "General", description: "Build together") }
  fab!(:topic) do
    Fabricate(
      :topic_with_op,
      title: "Show off your first Argila avatar",
      category:,
    )
  end

  before { sign_in(user) }

  def update_setting(name, value)
    theme.update_setting(name, value)
    theme.save!
  end

  it "renders the hero, category islands, and latest discussion cards" do
    visit("/")

    expect(page).to have_css(".blokoto-hero__title", text: "Build worlds.")
    expect(page).to have_css(".blokoto-hero__primary", text: "Join the community")
    expect(page).to have_css(".blokoto-category-card", text: category.name)
    expect(page).to have_css(".blokoto-topic-card", text: topic.title)
  end

  it "shows featured discussions for the configured tag" do
    SiteSetting.tagging_enabled = true
    tag = Fabricate(:tag, name: "featured")
    topic.tags = [tag]
    topic.save!
    update_setting(:homepage_featured_tag, "featured")

    visit("/")

    within(".homepage-blocks__block--featured") do
      expect(page).to have_css(".blokoto-topic-card", text: topic.title)
    end
  end

  it "renders the category banner on category pages" do
    visit(category.url)

    expect(page).to have_css(".blokoto-category-banner__name", text: category.name)
    expect(page).to have_css(
      ".blokoto-category-banner__description",
      text: "Build together",
    )
  end
end
