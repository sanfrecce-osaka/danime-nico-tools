# frozen_string_literal: true

module Form
  class SeasonSearch
    include ActiveModel::Model

    attr_accessor :keywords, :keyword_type

    def split_keywords
      keywords.split(%r([[:blank:]]))
    end
  end
end
