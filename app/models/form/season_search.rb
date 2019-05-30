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

    def keyword_type_name
      SeasonSearchKeywordType.find_by(type: @keyword_type&.to_sym).name
    end

    def season_list_title
      keywords.present? ? "#{keyword_type_name} × #{keywords}の検索結果" : '作品一覧'
    end

    def to_meta_tags
      { title: season_list_title }
    end
  end
end
