# frozen_string_literal: true

module Form
  class Search
    include ActiveModel::Model

    attr_accessor :keywords, :category

    def split_keywords
      keywords.split(%r([[:blank:]]))
    end
  end
end
