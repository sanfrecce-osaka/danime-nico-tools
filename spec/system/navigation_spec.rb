# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Navigation', type: :system do
  scenario 'ナビゲーションの適切なリンクのクラスにcurrrent-nav-linkが付加されている', js: true do
    visit root_path
    expect(find('nav').all('li')[0].has_css?('.current-nav-link')).to be_truthy
    expect(find('nav').all('li')[1].has_no_css?('.current-nav-link')).to be_truthy

    visit animes_path
    expect(find('nav').all('li')[0].has_no_css?('.current-nav-link')).to be_truthy
    expect(find('nav').all('li')[1].has_css?('.current-nav-link')).to be_truthy
  end
end
