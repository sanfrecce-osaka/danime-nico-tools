# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SeasonHash do
  describe '.already_created' do
    let(:already_created) { SeasonHash.already_created }

    it '作品の全てのfixtureを読み込んでいる' do
      expect(already_created.length).to eq 4
    end

    it '全てのfixtureが読み込み元のpathを持っている' do
      expect(already_created.all? { |season| season.has_key?(:file_path) }).to be_truthy
      expect(already_created.map(&:file_path).all? { |path| path.include?('./spec/fixtures/seasons/') }).to be_truthy
    end

    it 'fixtureの番号順にソートされている' do
      expected = %w(
        ./spec/fixtures/seasons/season_00001.yml
        ./spec/fixtures/seasons/season_00003.yml
        ./spec/fixtures/seasons/season_00005.yml
        ./spec/fixtures/seasons/season_01958.yml
      )
      expect(already_created.map(&:file_path)).to eq expected
    end
  end

  describe '.on_air' do
    it '放送中作品リストに記載されている作品のみが抽出される' do
      expect(SeasonHash.on_air.map(&:title)).to eq ['アイドル事変', 'アイドル天使 ようこそようこ']
    end
  end

  describe '#==' do
    context '作品タイトルが同じ' do
      it '同一の作品と判定される' do
        only_title = SeasonHash.new(title: 'アイドル事変')
        with_description = SeasonHash.new(title: 'アイドル事変', description: 'あらすじ1')
        expect(only_title).to eq with_description
      end
    end

    context '作品タイトルが異なる' do
      it '別の作品と判定される' do
        original_title = SeasonHash.new(title: 'アイドル事変', description: 'あらすじ1')
        different_title = SeasonHash.new(title: 'アイドル事変2', description: 'あらすじ1')
        expect(original_title).not_to eq different_title
      end
    end
  end

  describe '#has_nonexistent_episode?' do
    context '自身がニコニコ支店に存在しないエピソードがある作品として登録されている' do
      it 'trueを返す' do
        expect(SeasonHash.new(title: '愛少女ポリアンナ物語').has_nonexistent_episode?).to be_truthy
      end
    end

    context '自身がニコニコ支店に存在しないエピソードがある作品として登録されていない' do
      it 'falseを返す' do
        expect(SeasonHash.new(title: 'アイドル事変').has_nonexistent_episode?).to be_falsey
      end
    end
  end

  describe '#has_different_title_episode?' do
    context '自身が本店とニコニコ支店でタイトルの異なるエピソードがある作品として登録されている' do
      it 'trueを返す' do
        expect(SeasonHash.new(title: 'アイドル事変').has_different_title_episode?).to be_truthy
      end
    end

    context '自身が本店とニコニコ支店でタイトルの異なるエピソードがある作品として登録されていない' do
      it 'falseを返す' do
        expect(SeasonHash.new(title: 'アイドル天使 ようこそようこ').has_different_title_episode?).to be_falsey
      end
    end
  end

  describe '#find_different_title_episode' do
    let(:target_season) { SeasonHash.new(title: target_season_title) }
    let(:target_episode) { EpisodeHash.new(episode_no: target_episode_no, title: target_episode_title) }
    let(:different_title_episode) { target_season.find_different_title_episode(target_episode) }

    context '引数として渡したエピソードを持つ作品が本店とニコニコ支店でタイトルの異なるエピソードを持つ作品として登録されている' do
      context '渡したエピソードが本店の情報' do
        let(:target_season_title) { 'アイドル事変' }
        let(:target_episode_no) { '事変01' }
        let(:target_episode_title) { '私が国会議員になっても' }

        it '本店とニコニコ支店のエピソードの情報を格納したHashを返す' do
          expect(different_title_episode.class).to eq Hashie::Mash
          expect(different_title_episode.keys).to eq %w(head nico_branch)

          expected_of_head = EpisodeHash.new(episode_no:'事変01',title:'私が国会議員になっても')
          expect(different_title_episode.head).to eq expected_of_head

          expected_of_nico_branch = EpisodeHash.new(episode_no:'事変01',title:'私が市会議員になっても')
          expect(different_title_episode.nico_branch).to eq expected_of_nico_branch
        end
      end

      context '渡したエピソードがニコニコ支店の情報' do
        let(:target_season_title) { 'アイドル事変' }
        let(:target_episode_no) { '事変01' }
        let(:target_episode_title) { '私が市会議員になっても' }

        it 'nilを返す' do
          expect(different_title_episode).to eq nil
        end
      end
    end

    context '引数として渡したエピソードを持つ作品が本店とニコニコ支店でタイトルの異なるエピソードを持つ作品として登録されていない' do
      let(:target_season_title) { '愛少女ポリアンナ物語' }
      let(:target_episode_no) { '事変01' }
      let(:target_episode_title) { '私が国会議員になっても' }

      it 'nilを返す' do
        expect(different_title_episode).to eq nil
      end
    end
  end
end
