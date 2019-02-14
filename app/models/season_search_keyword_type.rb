# frozen_string_literal: true

class SeasonSearchKeywordType < ActiveHash::Base
  self.data = [
    { id: 1, type: :season_title, name: '作品タイトル' },
    { id: 2, type: :cast_name, name: '声優・キャラクター名' },
    { id: 3, type: :staff_name, name: 'スタッフ名' },
    { id: 4, type: :keyword, name: 'キーワード' }
  ]

  def season_title?
    type == :season_title
  end

  def cast_name?
    type == :cast_name
  end

  def staff_name?
    type == :staff_name
  end

  def keyword?
    type == :keyword
  end
end
