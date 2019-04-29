# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Episode, type: :model do
  describe '#nico_url' do
    let(:episode) { create(:episode, :with_season) }

    it '妥当なURLを返す' do
      expect(episode.nico_url).to eq 'http://www.nicovideo.jp/watch/so1'
    end
  end
end
