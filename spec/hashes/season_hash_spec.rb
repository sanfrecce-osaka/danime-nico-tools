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

  describe '#nonexistent_episodes' do
    let(:season) { SeasonHash.new(title: season_title) }
    let(:nonexistent_episodes) { season.nonexistent_episodes }

    context '本店のみに存在するエピソードを持つ作品として登録されている' do
      let(:season_title) { '愛少女ポリアンナ物語' }

      it '本店のみに存在するエピソードの配列を返す' do
        expect(nonexistent_episodes).to eq [EpisodeHash.new(episode_no: '', title: 'ニコニコ支店には存在しないエピソード')]
      end
    end

    context '本店のみに存在するエピソードを持つ作品として登録されていない' do
      let(:season_title) { 'アイドル事変' }

      it 'nilを返す' do
        expect(nonexistent_episodes).to eq nil
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

          expected_of_nico_branch = EpisodeHash.new(episode_no:'#01',title:'私が市会議員になっても')
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

  describe '#add_current_content_id' do
    let(:season) { SeasonHash.new(season_params) }
    let(:current_episode) { EpisodeHash.new(current_episode_params) }

    before(:each) do
      season.add_current_content_id(current_episode, current_overall_number)
    end

    context '作品タイトルとエピソードのタイトルが同じ' do
      context '話数が空' do
        context '引数で渡されたエピソードが作品の1つ目のエピソード' do
          let(:season_params) { { title: '異世界魔王と芹澤優と和氣あず未 クライマックス直前直後特番　-マジで最終回も来るとはな-' } }
          let(:current_episode_params) do
            {
              episode_no: '',
              title: '異世界魔王と芹澤優と和氣あず未 クライマックス直前直後特番　-マジで最終回も来るとはな-'
            }
          end
          let(:current_overall_number) { 1 }

          it '1つ目のエピソードのcontent_idが作品のcurrent_content_idに追加される' do
            expect(season.key?(:current_content_id)).to be_truthy
            expect(season.current_content_id).to eq 'so33925822'
          end
        end

        context '引数で渡されたエピソードが作品の2つ目以降のエピソード' do
          let(:season_params) do
            {
              title: '異世界魔王と芹澤優と和氣あず未 クライマックス直前直後特番　-マジで最終回も来るとはな-',
              before_episode: EpisodeHash.new(before_episode_params)
            }
          end
          let(:before_episode_params) do
            {
              episode_no: '',
              title: '異世界魔王と芹澤優と和氣あず未 クライマックス直前直後特番　-マジで最終回も来るとはな-',
              description: 'あらすじ1 次話→so33925821'
            }
          end
          let(:current_episode_params) do
            {
              episode_no: '',
              title: '異世界魔王と芹澤優と和氣あず未 クライマックス直前直後特番　-マジで最終回も来るとはな-'
            }
          end
          let(:current_overall_number) { 2 }

          it '2つ目のエピソードのcontent_idが作品のcurrent_content_idに追加される' do
            expect(season.key?(:current_content_id)).to be_truthy
            expect(season.current_content_id).to eq 'so33925821'
          end
        end
      end

      context '話数が空でない' do
        let(:season_params) { { title: '異世界魔王と芹澤優と和氣あず未 クライマックス直前直後特番　-マジで最終回も来るとはな-' } }
        let(:current_episode_params) do
          {
            episode_no: '#1',
            title: '異世界魔王と芹澤優と和氣あず未 クライマックス直前直後特番　-マジで最終回も来るとはな-'
          }
        end
        let(:current_overall_number) { 1 }

        it '作品にcurrent_content_idが追加されない' do
          expect(season.key?(:current_content_id)).to be_falsey
        end
      end
    end

    context '作品タイトルとエピソードのタイトルが異なる' do
      let(:season_params) { { title: '愛少女ポリアンナ物語' } }
      let(:current_episode_params) { { episode_no: '第1話', title: '教会の小さな娘' } }
      let(:current_overall_number) { 1 }

      it '作品にcurrent_content_idが追加されない' do
        expect(season.key?(:current_content_id)).to be_falsey
      end
    end
  end

  describe '#add_before_episode' do
    let(:season) { SeasonHash.new(season_params) }
    let(:current_episode) { EpisodeHash.new(current_episode_params) }

    before(:each) do
      season.add_before_episode(current_episode, current_overall_number)
    end

    context '作品タイトルとエピソードのタイトルが同じ' do
      context '話数が空' do
        context '引数で渡されたエピソードが作品の現在公開されている最後以外のエピソード' do
          let(:season_params) do
            {
              title: '異世界魔王と芹澤優と和氣あず未 クライマックス直前直後特番　-マジで最終回も来るとはな-',
              episodes: [current_episode, next_episode]
            }
          end
          let(:current_episode_params) do
            {
              episode_no: '',
              title: '異世界魔王と芹澤優と和氣あず未 クライマックス直前直後特番　-マジで最終回も来るとはな-',
              description: 'あらすじ1'
            }
          end
          let(:next_episode) { EpisodeHash.new(next_episode_params) }
          let(:next_episode_params) do
            {
              episode_no: '',
              title: '異世界魔王と芹澤優と和氣あず未 クライマックス直前直後特番　-マジで最終回も来るとはな-',
              description: 'あらすじ2'
            }
          end
          let(:current_overall_number) { 1 }

          it '作品のbefore_episodeに現在のエピソードが追加される' do
            expect(season.key?(:before_episode)).to be_truthy
            expect(season.before_episode.description).to eq current_episode.description
          end
        end

        context '引数で渡されたエピソードが作品の現在公開されている最後のエピソード' do
          let(:season_params) do
            {
              title: '異世界魔王と芹澤優と和氣あず未 クライマックス直前直後特番　-マジで最終回も来るとはな-',
              episodes: [current_episode]
            }
          end
          let(:current_episode_params) do
            {
              episode_no: '',
              title: '異世界魔王と芹澤優と和氣あず未 クライマックス直前直後特番　-マジで最終回も来るとはな-',
            }
          end
          let(:current_overall_number) { 1 }

          it '作品にbefore_episodeが追加されない' do
            expect(season.key?(:before_episode)).to be_falsey
          end
        end
      end

      context '話数が空でない' do
        let(:season_params) do
          {
            title: '異世界魔王と芹澤優と和氣あず未 クライマックス直前直後特番　-マジで最終回も来るとはな-',
            episodes: [current_episode, next_episode]
          }
        end
        let(:current_episode_params) do
          {
            episode_no: '#1',
            title: '異世界魔王と芹澤優と和氣あず未 クライマックス直前直後特番　-マジで最終回も来るとはな-',
            description: 'あらすじ1'
          }
        end
        let(:next_episode) { EpisodeHash.new(next_episode_params) }
        let(:next_episode_params) do
          {
            episode_no: '#2',
            title: '異世界魔王と芹澤優と和氣あず未 クライマックス直前直後特番　-マジで最終回も来るとはな-',
            description: 'あらすじ2'
          }
        end
        let(:current_overall_number) { 1 }

        it '作品にbefore_episodeが追加されない' do
          expect(season.key?(:before_episode)).to be_falsey
        end
      end
    end
    
    context '作品タイトルとエピソードのタイトルが異なる' do
      let(:season_params) do
        {
          title: '愛少女ポリアンナ物語',
          episodes: [current_episode, next_episode]
        }
      end
      let(:current_episode_params) do
        {
          episode_no: '第1話',
          title: '教会の小さな娘',
          description: 'あらすじ1'
        }
      end
      let(:next_episode) { EpisodeHash.new(next_episode_params) }
      let(:next_episode_params) do
        {
          episode_no: '第2話',
          title: '死なないで父さん',
          description: 'あらすじ2'
        }
      end
      let(:current_overall_number) { 1 }

      it '作品にbefore_episodeが追加されない' do
        expect(season.key?(:before_episode)).to be_falsey
      end
    end
  end

  describe '#not_begin_yet?' do
    let(:season) { SeasonHash.new(title: '愛少女ポリアンナ物語', watchable: watchable, episodes: episodes) }
    let(:episode) { EpisodeHash.new(episode_no: '第1話', title: '教会の小さな娘') }

    context '作品が公開されている' do
      context 'エピソードを持っていない' do
        let(:watchable) { true }
        let(:episodes) { [] }

        it 'trueを返す' do
          expect(season.not_begin_yet?).to be_truthy
        end
      end

      context 'エピソードを持っている' do
        let(:watchable) { true }
        let(:episodes) { [episode] }

        it 'falseを返す' do
          expect(season.not_begin_yet?).to be_falsey
        end
      end
    end

    context '作品が公開されていない' do
      let(:watchable) { false }
      let(:episodes) { [] }

      it 'falseを返す' do
        expect(season.not_begin_yet?).to be_falsey
      end
    end
  end

  describe '#original_or_different_title' do
    let(:season) { SeasonHash.new(title: title) }
    let(:original_or_different_title) { season.original_or_different_title }

    context '本店とエピソードで作品タイトルが異なる作品として登録されている' do
      let(:title) { 'ReLIFE"完結編"' }

      it '登録されている変換後のタイトルを返す' do
        expect(original_or_different_title).to eq 'ReLIFE”完結編”'
      end
    end

    context '本店とエピソードで作品タイトルが異なる作品として登録されていない' do
      let(:title) { '愛少女ポリアンナ物語' }

      it '実行したインスタンスが持つタイトルを返す' do
        expect(original_or_different_title).to eq '愛少女ポリアンナ物語'
      end
    end
  end

  describe '#fixture_no' do
    let(:season) { SeasonHash.already_created.find { |e| e.file_path.include?('season_00003.yml') } }
    let(:fixture_no) { season.fixture_no }

    it 'ファイル名に含まれるfixtureの番号を数値で返す' do
      expect(fixture_no).to eq 3
    end
  end
end
