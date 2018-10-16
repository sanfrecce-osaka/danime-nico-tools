# frozen_string_literal: true

module Searchable
  extend ActiveSupport::Concern

  included do
    scope :search_by, -> (search_form) { ransack(search_conditions(search_form)).result }

    class << self
      private

      def key_for_keyword_search
        (targets_for_keyword_search.join('_or_') + '_cont').to_sym
      end
    end
  end
end
