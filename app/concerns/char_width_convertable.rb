# frozen_string_literal: true

module CharWidthConvertable
  extend ActiveSupport::Concern
  included { extend CharWidthConvertable }

  def half_to_full(str)
    str.tr('0-9a-zA-Z', '０-９ａ-ｚＡ-Ｚ')
  end

  def full_to_half(str)
    str.tr('０-９ａ-ｚＡ-Ｚ', '0-9a-zA-Z')
  end
end
