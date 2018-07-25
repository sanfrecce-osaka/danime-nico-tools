# frozen_string_literal: true

# Autoload Rails Models
# see https://github.com/ManageIQ/manageiq/blob/master/config/initializers/yaml_autoloader.rb

Psych::Visitors::ToRuby.prepend Module.new {
  def resolve_class(klass_name)
    klass_name && klass_name.safe_constantize || super
  end
}
