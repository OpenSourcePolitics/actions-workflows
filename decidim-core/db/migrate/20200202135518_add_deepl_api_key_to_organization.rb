# frozen_string_literal: true

class AddDeeplApiKeyToOrganization < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_organizations, :deepl_api_key, :string
  end
end
