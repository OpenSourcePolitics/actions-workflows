# frozen_string_literal: true

require "spec_helper"
require "decidim/core/test/shared_examples/has_contextual_help"

describe "Initiatives", type: :system do
  let(:organization) { create(:organization) }
  let(:base_initiative) do
    create(:initiative, organization: organization)
  end

  before do
    switch_to_host(organization.host)
  end

  context "when there are some published initiatives" do
    let!(:initiative) { base_initiative }
    let!(:unpublished_initiative) do
      create(:initiative, :created, organization: organization)
    end

    before do
      visit decidim_initiatives.initiatives_path
    end

    it_behaves_like "shows contextual help" do
      let(:index_path) { decidim_initiatives.initiatives_path }
      let(:manifest_name) { :initiatives }
    end

    it_behaves_like "editable content for admins"

    context "when accessing from the homepage" do
      it "the menu link is shown" do
        visit decidim.root_path

        within ".main-nav" do
          expect(page).to have_content("Initiatives")
          click_link "Initiatives"
        end

        expect(page).to have_current_path(decidim_initiatives.initiatives_path)
      end
    end

    it "lists all the initiatives" do
      within "#initiatives-count" do
        expect(page).to have_content("1")
      end

      within "#initiatives" do
        expect(page).to have_content(translated(initiative.title, locale: :en))
        expect(page).to have_content(initiative.author_name, count: 1)
        expect(page).not_to have_content(translated(unpublished_initiative.title, locale: :en))
      end
    end

    context "when the initiative is 'created' or 'technical validation'" do
      shared_examples_for "invalid state for index" do
        it "does not list initiative" do
          within "#initiatives" do
            expect(page).not_to have_content(translated(initiative.title, locale: :en))
            expect(page).not_to have_content(initiative.author_name, count: 1)
            expect(page).not_to have_content(translated(unpublished_initiative.title, locale: :en))
          end
        end
      end

      it_behaves_like "invalid state for index" do
        let!(:base_initiative) { create(:initiative, :created, organization: organization) }
      end

      it_behaves_like "invalid state for index" do
        let!(:base_initiative) { create(:initiative, :validating, organization: organization) }
      end
    end

    it "links to the individual initiative page" do
      click_link(translated(initiative.title, locale: :en))
      expect(page).to have_current_path(decidim_initiatives.initiative_path(initiative))
    end

    it "displays the filter initiative type filter" do
      within ".new_filter[action='/initiatives']" do
        expect(page).to have_css("#filter_type")
      end
    end

    context "when there is a unique initiative type" do
      let!(:unpublished_initiative) { nil }

      it "doesn't display the initiative type filter" do
        within ".new_filter[action='/initiatives']" do
          expect(page).not_to have_css("#filter_type")
        end
      end
    end

    context "when in a manual state" do
      shared_examples_for "initiative card" do
        it "displays the correct badge status" do
          within "#initiative_#{base_initiative.id}" do
            expect(page).to have_css(".#{state_class}.card__text--status")
            expect(find("span.#{state_class}.card__text--status").text).to eq(base_initiative.state.upcase)
          end
        end
      end
      it_behaves_like "initiative card" do
        let(:base_initiative) { create(:initiative, :debatted, organization: organization) }
        let(:state_class) { "success" }
      end
      it_behaves_like "initiative card" do
        let(:base_initiative) { create(:initiative, :examinated, organization: organization) }
        let(:state_class) { "warning" }
      end
    end
  end
end
