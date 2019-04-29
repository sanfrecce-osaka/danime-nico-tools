# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Episode, type: :model do
  describe '#nico_url' do
    let(:episode) { create(:episode, :with_season) }

    it '妥当なURLを返す' do
      expect(episode.nico_url).to eq 'http://www.nicovideo.jp/watch/so1'
    end
  end

  describe '#full_title' do
    let(:episode) { create(:episode, :with_season, params) }
    let(:params) { { title: title, number_in_season: number_in_season } }
    let(:full_title) { episode.full_title(with_season_title) }

    context '作品タイトルと動画タイトルが同じかつ作品タイトル表示フラグがtrue' do
      context '話数が空' do
        let(:title) { '愛少女ポリアンナ物語' }
        let(:number_in_season) { '' }
        let(:with_season_title) { true }

        it '作品タイトル+#動画順を返す' do
          expect(full_title).to eq '愛少女ポリアンナ物語　#1'
        end
      end
    end
  end
end
