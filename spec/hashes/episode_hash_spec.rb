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
    end
  end
end
