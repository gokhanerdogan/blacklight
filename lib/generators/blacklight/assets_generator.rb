# frozen_string_literal: true
module Blacklight
  class Assets < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    def assets
      copy_file "blacklight.scss", "app/assets/stylesheets/blacklight.scss"

      return if has_blacklight_assets?

      contents = "\n//\n// Required by Blacklight\n"
      contents += "//= require jquery\n" if rails_5_1?
      contents += "//= require popper\n"
      contents += "// Twitter Typeahead for autocomplete\n"
      contents += "//= require twitter/typeahead\n"
      contents += "//= require bootstrap\n"

      # TODO: can we have the application use YARN/Webpacker and `yarn add blacklight-frontend`?
      contents += "//= require blacklight/blacklight\n"

      # That should pull blacklight + bootstrap stuff into the bundle
      # contents += "//= require bootstrap/util\n"
      # contents += "//= require bootstrap/collapse\n"
      # contents += "//= require bootstrap/dropdown\n"
      # contents += "//= require bootstrap/alert\n"
      # contents += "//= require bootstrap/modal\n"

      marker = if turbolinks?
                 '//= require turbolinks'
               elsif rails_5_1?
                 '//= require rails-ujs'
               else
                 '//= require jquery_ujs'
               end

      insert_into_file "app/assets/javascripts/application.js", :after => marker do
        contents
      end
    end

    # This is not a default in Rails 5.1
    def add_jquery
      gem 'jquery-rails' if rails_5_1?
    end

    private

    def rails_5_1?
      Rails.version =~ /5\.1/
    end

    def turbolinks?
      @turbolinks ||= IO.read("app/assets/javascripts/application.js").include?('turbolinks')
    end

    def has_blacklight_assets?
      IO.read("app/assets/javascripts/application.js").include?('blacklight/blacklight')
    end
  end
end
