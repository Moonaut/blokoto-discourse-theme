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

  it "renders the community rail beside the latest discussions" do
    visit("/")

    expect(page).to have_css(".blokoto-home__main .blokoto-home__latest")
    expect(page).to have_css(".blokoto-home__rail")

    within(".blokoto-home__rail") do
      expect(page).to have_css(".blokoto-rail__title", text: "Hot topics")
      expect(page).to have_css(
        ".blokoto-rail__title",
        text: "Best weekly contributors",
      )
    end
  end

  it "hides the events block when the events feature is disabled" do
    SiteSetting.discourse_events_enabled = false
    SiteSetting.discourse_post_event_enabled = false

    visit("/")

    expect(page).not_to have_css(
      ".blokoto-rail__title",
      text: "Next events",
    )
  end

  it "renders the Blokreations carousel for the configured category" do
    theme.update_setting(:homepage_blokreations_category, category.slug)
    theme.save!

    upload = Fabricate(:image_upload)
    blokreation = Fabricate(
      :topic,
      title: "Show off your first Blokreation",
      category:,
    )
    Fabricate(:post, topic: blokreation, raw: "![A Blokreation](#{upload.url})")

    visit("/")

    expect(page).to have_css(".blokoto-home__blokreations")
    expect(page).to have_css(
      ".blokoto-blokreations__heading",
      text: "Latest Blokreations",
    )
    expect(page).to have_css(".blokoto-blokreations__card", count: 1)
    expect(page).to have_css(".blokoto-blokreations__card img")
  end

  it "hides the Blokreations section when no category is configured" do
    theme.update_setting(:homepage_blokreations_category, "")
    theme.save!

    visit("/")

    expect(page).not_to have_css(".blokoto-home__blokreations")
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
