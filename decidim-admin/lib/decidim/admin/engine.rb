# frozen_string_literal: true

require "rails"
require "active_support/all"

require "devise"
require "devise-i18n"
require "decidim/core"
require "jquery-rails"
require "sassc-rails"
require "foundation-rails"
require "foundation_rails_helper"
require "autoprefixer-rails"
require "rectify"
require "doorkeeper"
require "doorkeeper-i18n"
require "hashdiff"

module Decidim
  module Admin
    # Decidim's core Rails Engine.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Admin

      initializer "decidim_admin.mount_routes" do |_app|
        Decidim::Core::Engine.routes do
          mount Decidim::Admin::Engine => "/admin"
        end
      end

      initializer "decidim_admin.assets" do |app|
        app.config.assets.precompile += %w(decidim_admin_manifest.js)
      end

      initializer "decidim_admin.menu" do
        Decidim.menu :admin_menu do |menu|
          menu.item I18n.t("menu.dashboard", scope: "decidim.admin"),
                    decidim_admin.root_path,
                    icon_name: "dashboard",
                    position: 1,
                    active: ["decidim/admin/dashboard" => :show]

          menu.item I18n.t("menu.static_pages", scope: "decidim.admin"),
                    decidim_admin.static_pages_path,
                    icon_name: "book",
                    position: 4,
                    active: [%w(
                      decidim/admin/static_pages
                      decidim/admin/static_page_topics
                    ), []],
                    if: allowed_to?(:read, :static_page)

          menu.item I18n.t("menu.users", scope: "decidim.admin"),
                    allowed_to?(:read, :admin_user) ? decidim_admin.users_path : decidim_admin.impersonatable_users_path,
                    icon_name: "person",
                    position: 5,
                    active: [%w(user_groups users managed_users impersonatable_users authorization_workflows).map { |segment| "/decidim/admin/#{segment}" }, []],
                    if: allowed_to?(:read, :admin_user) || allowed_to?(:read, :managed_user)

          menu.item I18n.t("menu.newsletters", scope: "decidim.admin"),
                    decidim_admin.newsletters_path,
                    icon_name: "envelope-closed",
                    position: 6,
                    active: :inclusive,
                    if: allowed_to?(:index, :newsletter)

          menu.item I18n.t("menu.settings", scope: "decidim.admin"),
                    decidim_admin.edit_organization_path,
                    icon_name: "wrench",
                    position: 7,
                    active: [
                      %w(
                        decidim/admin/organization
                        decidim/admin/organization_appearance
                        decidim/admin/organization_homepage
                        decidim/admin/organization_homepage_content_blocks
                        decidim/admin/scopes
                        decidim/admin/scope_types
                        decidim/admin/areas decidim/admin/area_types
                        decidim/admin/help_sections
                      ),
                      []
                    ],
                    if: allowed_to?(:update, :organization, organization: current_organization)

          menu.item I18n.t("menu.admin_log", scope: "decidim.admin"),
                    decidim_admin.logs_path,
                    icon_name: "dashboard",
                    position: 10,
                    active: [%w(decidim/admin/logs), []],
                    if: allowed_to?(:read, :admin_log)

          menu.item I18n.t("menu.oauth_applications", scope: "decidim.admin"),
                    decidim_admin.oauth_applications_path,
                    icon_name: "dashboard",
                    position: 11,
                    active: [%w(decidim/admin/oauth_applications), []],
                    if: allowed_to?(:read, :oauth_application)
        end

        Decidim.menu :admin_settings_menu do |menu|
          menu.item I18n.t("menu.configuration", scope: "decidim.admin"),
                    decidim_admin.edit_organization_path,
                    position: 1,
                    active: [%w(decidim/admin/organization), []],
                    if: allowed_to?(:update, :organization, organization: current_organization)

          menu.item I18n.t("menu.appearance", scope: "decidim.admin"),
                    decidim_admin.edit_organization_appearance_path,
                    position: 2,
                    active: [%w(decidim/admin/organization_appearance), []],
                    if: allowed_to?(:update, :organization, organization: current_organization)

          menu.item I18n.t("menu.homepage", scope: "decidim.admin"),
                    decidim_admin.edit_organization_homepage_path,
                    position: 3,
                    active: [%w(decidim/admin/organization_homepage), []],
                    if: allowed_to?(:update, :organization, organization: current_organization)

          menu.item I18n.t("menu.scopes", scope: "decidim.admin"),
                    decidim_admin.scopes_path,
                    position: 4,
                    active: [%w(decidim/admin/scopes), []],
                    if: allowed_to?(:update, :organization, organization: current_organization)

          menu.item I18n.t("menu.scope_types", scope: "decidim.admin"),
                    decidim_admin.scope_types_path,
                    position: 5,
                    active: [%w(decidim/admin/scope_types), []],
                    if: allowed_to?(:update, :organization, organization: current_organization)

          menu.item I18n.t("menu.areas", scope: "decidim.admin"),
                    decidim_admin.areas_path,
                    position: 6,
                    active: [%w(decidim/admin/areas), []],
                    if: allowed_to?(:update, :organization, organization: current_organization)

          menu.item I18n.t("menu.area_types", scope: "decidim.admin"),
                    decidim_admin.area_types_path,
                    position: 7,
                    active: [%w(decidim/admin/area_types), []],
                    if: allowed_to?(:update, :organization, organization: current_organization)

          menu.item I18n.t("menu.help_sections", scope: "decidim.admin"),
                    decidim_admin.help_sections_path,
                    position: 8,
                    active: [%w(decidim/admin/area_types), []],
                    if: allowed_to?(:update, :help_sections)
        end
      end

      initializer "decidim_admin.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Admin::Engine.root}/app/cells")
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Admin::Engine.root}/app/views") # for partials
      end
    end
  end
end
