# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Season, type: :model do
  describe '#not_begin_yet?' do
    context '作品が公開されていてEpisodeを持っている' do
      let(:season) { create(:season, :with_episodes, watchable: watchable) }
      let(:watchable) { true }

      it 'falseを返す' do
        expect(season.not_begin_yet?).to be_falsey
      end
    end

    context '作品が公開されていてEpisodeを持っていない' do
      let(:season) { create(:season, watchable: watchable) }
      let(:watchable) { true }

      it 'trueを返す' do
        expect(season.not_begin_yet?).to be_truthy
      end
    end

    context '作品が公開されていなくてEpisodeを持っている' do
      let(:season) { create(:season, :with_episodes, watchable: watchable) }
      let(:watchable) { false }

      it 'falseを返す' do
        expect(season.not_begin_yet?).to be_falsey
      end
    end

    context '作品が公開されていなくてEpisodeを持っていない' do
      let(:season) { create(:season, watchable: watchable) }
      let(:watchable) { false }

      it 'falseを返す' do
        expect(season.not_begin_yet?).to be_falsey
      end
    end
  end

  describe '#to_h' do
    let(:season) { create(:season, :with_episodes) }
    let(:season_hash) { season.to_h }

    it 'SeasonとEpisodeがSeasonHashとEpisodeHashに変換される' do
      expect(season_hash.class).to eq SeasonHash
      season_hash.episodes.each do |episode|
        expect(episode.class).to eq EpisodeHash
      end
    end
  end
end
