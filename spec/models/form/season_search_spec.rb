# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Form::SeasonSearch do
  let(:form) { Form::SeasonSearch.new(params) }

  describe '#split_keywords' do
    context 'キーワードが1つ' do
      let(:params) { { keywords: 'マジンガーZ', keyword_type: :season_title } }

      it 'キーワードの配列を返す' do
        keywords = form.split_keywords
        expect(keywords.length).to eq 1
        expect(keywords).to eq ['マジンガーZ']
      end
    end
  end
end
