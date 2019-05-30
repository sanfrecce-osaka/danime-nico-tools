# frozen_string_literal: true

module MetaTagsHelper
  def default_meta_tags
    {
      site: 'danime-nico-tools - dアニメストア ニコニコ支店のための検索サイト',
      reverse: true,
      charset: 'utf-8',
      description: 'dアニメストア ニコニコ支店のための検索サイト。',
      viewport: 'width=device-width, initial-scale=1, shrink-to-fit=no',
    }
  end
end
