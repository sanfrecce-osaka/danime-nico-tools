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
    let(:params) { { title: episode_title, number_in_season: number_in_season } }
    let(:full_title) { episode.full_title(with_season_title) }

    context '作品タイトルと動画タイトルが同じ' do
      context '作品タイトル表示フラグがtrue' do
        context '話数が空' do
          let(:episode_title) { '愛少女ポリアンナ物語' }
          let(:number_in_season) { '' }
          let(:with_season_title) { true }

          it '作品タイトル+#動画順を返す' do
            expect(full_title).to eq '愛少女ポリアンナ物語　#1'
          end
        end

        context '話数が空でない' do
          let(:episode_title) { '愛少女ポリアンナ物語' }
          let(:number_in_season) { '第1話' }
          let(:with_season_title) { true }

          it '作品タイトル+話数を返す' do
            expect(full_title).to eq '愛少女ポリアンナ物語　第1話'
          end
        end
      end
    end

    context '作品タイトルと動画タイトルが同じ' do
      context '作品タイトル表示フラグがfalse' do
        context '話数が空' do
          let(:episode_title) { '愛少女ポリアンナ物語' }
          let(:number_in_season) { '' }
          let(:with_season_title) { false }

          it '作品タイトル+#動画順を返す' do
            expect(full_title).to eq '愛少女ポリアンナ物語　#1'
          end
        end

        context '話数が空でない' do
          let(:episode_title) { '愛少女ポリアンナ物語' }
          let(:number_in_season) { '第1話' }
          let(:with_season_title) { false }

          it '作品タイトル+話数を返す' do
            expect(full_title).to eq '愛少女ポリアンナ物語　第1話'
          end
        end
      end
    end

    context '作品タイトルと動画タイトルが異なる' do
      context '作品タイトル表示フラグがtrue' do
        context '話数が空' do
          let(:episode_title) { 'エピソード1' }
          let(:number_in_season) { '' }
          let(:with_season_title) { true }

          it '作品タイトル+動画タイトルを返す' do
            expect(full_title).to eq '愛少女ポリアンナ物語　エピソード1'
          end
        end

        context '話数が空でない' do
          let(:episode_title) { 'エピソード1' }
          let(:number_in_season) { '第1話' }
          let(:with_season_title) { true }

          it '作品タイトル+話数+動画タイトルを返す' do
            expect(full_title).to eq '愛少女ポリアンナ物語　第1話　エピソード1'
          end
        end
      end
    end

    context '作品タイトルと動画タイトルが異なる' do
      context '作品タイトル表示フラグがfalse' do
        context '話数が空' do
          let(:episode_title) { 'エピソード1' }
          let(:number_in_season) { '' }
          let(:with_season_title) { false }

          it '動画タイトルを返す' do
            expect(full_title).to eq 'エピソード1'
          end
        end

        context '話数が空でない' do
          let(:episode_title) { 'エピソード1' }
          let(:number_in_season) { '第1話' }
          let(:with_season_title) { false }

          it '話数+動画タイトルを返す' do
            expect(full_title).to eq '第1話　エピソード1'
          end
        end
      end
    end
  end

  describe '#thumbnail_https_url' do
    let(:episode) { build(:episode) }
    let(:thumbnail_https_url) { episode.thumbnail_https_url }

    it 'httpsに変換されたサムネイルのURLを返す' do
      expect(thumbnail_https_url).to eq 'https://dammy.com?i=1'
    end
  end
end
