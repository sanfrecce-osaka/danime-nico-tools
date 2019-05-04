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
end
