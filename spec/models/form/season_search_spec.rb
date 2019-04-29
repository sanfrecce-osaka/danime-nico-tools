# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Form::SeasonSearch do
  let(:form) { Form::SeasonSearch.new(params) }

  describe '#split_keywords' do
    let(:keywords) { form.split_keywords }

    context 'キーワードが1つ' do
      let(:params) { { keywords: 'マジンガーZ', keyword_type: :season_title } }

      it 'キーワードの配列を返す' do
        expect(keywords.length).to eq 1
        expect(keywords).to eq ['マジンガーZ']
      end
    end

    context 'キーワードが2つ' do
      let(:params) { { keywords: keywords_params, keyword_type: :season_title } }

      context '半角スペース区切り' do
        let(:keywords_params) { 'マジンガーZ 暗黒大将軍' }

        it 'キーワードの配列を返す' do
          expect(keywords.length).to eq 2
          expect(keywords).to eq %w(マジンガーZ 暗黒大将軍)
        end
      end

      context '全角スペース区切り' do
        let(:keywords_params) { 'マジンガーZ　暗黒大将軍' }

        it 'キーワードの配列を返す' do
          expect(keywords.length).to eq 2
          expect(keywords).to eq %w(マジンガーZ 暗黒大将軍)
        end
      end
    end
  end

  describe '#keyword_type' do
    let(:params) { { keywords: 'マジンガーZ', keyword_type: :season_title } }

    it 'シンボルを返す' do
      expect(form.keyword_type.class).to eq Symbol
    end
  end
end
