# frozen_string_literal: true

module Form
  class SeasonSearch
    include ActiveModel::Model

    attr_accessor :keywords
    attr_writer :keyword_type

    def split_keywords
      keywords.split(%r([[:blank:]]))
    end

    def keyword_type
      @keyword_type&.to_sym
    end
  end
end
