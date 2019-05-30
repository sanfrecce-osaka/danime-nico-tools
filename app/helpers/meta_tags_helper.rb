# frozen_string_literal: true

module MetaTagsHelper
  def default_meta_tags
    {
      site: 'danime-nico-tools - dアニメストア ニコニコ支店のための検索サイト',
      reverse: true,
      charset: 'utf-8',
      description: 'dアニメストア ニコニコ支店のための検索サイト。',
      viewport: 'width=device-width, initial-scale=1, shrink-to-fit=no',
      og: {
        title: :title,
        type: 'website',
        site_name: 'danime-nico-tools',
        description: :description,
        image: 'https://danime-nico-tools.herokuapp.com/ogp.png',
        url: 'https://danime-nico-tools.herokuapp.com'
      },
      twitter: {
        card: 'summary',
        site: '@danime-nico-tools',
        description: :description,
        image: 'https://danime-nico-tools.herokuapp.com/ogp.png',
        domain: 'https://danime-nico-tools.herokuapp.com'
      }
    }
  end
end
