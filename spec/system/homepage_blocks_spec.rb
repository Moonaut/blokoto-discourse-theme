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

  it "renders one compact intro and a latest-discussion list" do
    visit("/")

    expect(page).to have_css(
      ".blokoto-home__title",
      text: "The online sandbox, together.",
    )
    expect(page).to have_css(".blokoto-home__topic-title", text: topic.title)
    expect(page).to have_css(".blokoto-home__latest-title", text: "Latest discussions")
  end

  it "renders a plain category heading on category pages" do
    visit(category.url)

    expect(page).to have_css(
      ".blokoto-category-heading__title",
      text: category.name,
    )
    expect(page).to have_css(
      ".blokoto-category-heading__description",
      text: "Build together",
    )
  end

  it "respects the configured latest discussion count" do
    theme.update_setting(:homepage_latest_count, 1)
    theme.save!
    3.times do |index|
      Fabricate(
        :topic_with_op,
        title: "Another discussion #{index}",
        category:,
      )
    end

    visit("/")

    expect(page).to have_css(".blokoto-home__topic", count: 1)
  end
end
