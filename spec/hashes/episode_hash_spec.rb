# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EpisodeHash do
  describe '#==' do
    let(:comparing) { EpisodeHash.new(comparing_params) }
    let(:compared) { EpisodeHash.new(compared_params) }

    context '話数が同じ' do
      context 'タイトルが同じ' do
        let(:comparing_params) { { episode_no: '第1話', title: '教会の小さな娘' } }
        let(:compared_params) { { episode_no: '第1話', title: '教会の小さな娘', description: 'あらすじ1' } }

        it '同一のエピソードと判定される' do
          expect(comparing).to eq compared
        end
      end

      context 'タイトルが異なる' do
        let(:comparing_params) { { episode_no: '第1話', title: '教会の小さな娘' } }
        let(:compared_params) { { episode_no: '第1話', title: '教会の大きな娘' } }

        it '別のエピソードと判定される' do
          expect(comparing).not_to eq compared
        end
      end
    end

    context '話数が異なる' do
      let(:comparing_params) { { episode_no: '第1話', title: '教会の小さな娘' } }
      let(:compared_params) { { episode_no: '#1', title: '教会の小さな娘' } }

      it '別のエピソードと判定される' do
        expect(comparing).not_to eq compared
      end
    end
  end

  describe 'nonexistent_episode?' do
    let(:nonexistent_episode) { EpisodeHash.new(episode_no: '', title: 'ニコニコ支店には存在しないエピソード') }
    let(:existent_episode) { EpisodeHash.new(episode_no: '第1話', title: '教会の小さな娘') }
    let(:season) { SeasonHash.new(season_params) }
    let(:is_nonexistent_episode) { target_episode.nonexistent_episode?(season) }

    context '本店のみに存在するエピソードを持つ作品として登録されている' do
      context '本店のみに存在するエピソードとして登録されている' do
        let(:season_params) { { title: '愛少女ポリアンナ物語', episodes: [existent_episode, nonexistent_episode] } }
        let(:target_episode) { nonexistent_episode }

        it 'trueを返す' do
          expect(is_nonexistent_episode).to be_truthy
        end
      end

      context '本店のみに存在するエピソードとして登録されていない' do
        let(:season_params) { { title: '愛少女ポリアンナ物語', episodes: [existent_episode] } }
        let(:target_episode) { existent_episode }

        it 'falseを返す' do
          expect(is_nonexistent_episode).to be_falsey
        end
      end
    end

    context '本店のみに存在するエピソードを持つ作品として登録されていない' do
      let(:season_params) { { title: '愛少女ポリアンナ物語2', episodes: [existent_episode, nonexistent_episode] } }
      let(:target_episode) { nonexistent_episode }

      it 'falseを返す' do
        expect(is_nonexistent_episode).to be_falsey
        expect(is_nonexistent_episode).to eq nil
      end
    end
  end

  describe '#update_only_different_title' do
    let(:season) do
      SeasonHash.new(
        title: 'アイドル事変',
        episodes: [episode_with_same_title.dup, episode_with_different_title.dup]
      )
    end
    let(:episode_with_different_title) { EpisodeHash.new(episode_no: '事変01', title: '私が国会議員になっても') }
    let(:episode_with_same_title) { EpisodeHash.new(episode_no: '事変02', title: '少女S') }
    let(:update_only_different_title) { target_episode.update_only_different_title(season) }

    context '本店と支店で異なるタイトルを持つエピソードとして登録されている' do
      let(:target_episode) { episode_with_different_title.dup }

      it '話数が支店のものに更新される' do
        expect { update_only_different_title }.to change { target_episode.episode_no }.from('事変01').to('#01')
      end

      it 'エピソードのタイトルが支店のものに更新される' do
        expect { update_only_different_title }
          .to change { target_episode.title }.from('私が国会議員になっても').to('私が市会議員になっても')
      end
    end

    context '本店と支店で異なるタイトルを持つエピソードとして登録されていない' do
      let(:target_episode) { episode_with_same_title.dup }

      it '話数・タイトルともに実行前と変わらない' do
        expect(update_only_different_title).to eq episode_with_same_title
      end
    end
  end
end
