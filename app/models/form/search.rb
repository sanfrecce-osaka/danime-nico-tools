# frozen_string_literal: true

module Form
  class Search
    include ActiveModel::Model

    attr_accessor :keywords, :category_type

    def split_keywords
      keywords.split(%r([[:blank:]]))
    end

    def category
      SearchCategory.find_by(type: category_type)
    end
  end
end
