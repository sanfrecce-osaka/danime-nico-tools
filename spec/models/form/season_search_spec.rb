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

  describe '#keyword_type_name' do
    let(:params) { { keywords: 'マジンガーZ', keyword_type: keyword_type_params } }
    let(:keyword_type_name) { form.keyword_type_name }

    context 'キーワードタイプが作品タイトル' do
      let(:keyword_type_params) { :season_title }

      it '"作品タイトル"を返す' do
        expect(keyword_type_name).to eq '作品タイトル'
      end
    end

    context 'キーワードタイプが声優・キャラクター名' do
      let(:keyword_type_params) { :cast_name }

      it '"声優・キャラクター名"を返す' do
        expect(keyword_type_name).to eq '声優・キャラクター名'
      end
    end

    context 'キーワードタイプがスタッフ名' do
      let(:keyword_type_params) { :staff_name }

      it '"スタッフ名"を返す' do
        expect(keyword_type_name).to eq 'スタッフ名'
      end
    end

    context 'キーワードタイプがキーワード' do
      let(:keyword_type_params) { :keyword }

      it '"キーワード"を返す' do
        expect(keyword_type_name).to eq 'キーワード'
      end
    end
  end

  describe '#season_list_title' do
    let(:params) { { keywords: keywords_params, keyword_type: :season_title } }
    let(:title) { form.season_list_title }

    context 'キーワードが空' do
      let(:keywords_params) { '' }

      it '作品一覧を返す' do
        expect(title).to eq '作品一覧'
      end
    end

    context 'キーワードが空でない' do
      let(:keywords_params) { 'マジンガーZ' }

      it '"キーワードタイプ × キーワードの検索結果"を返す' do
        expect(title).to eq '作品タイトル × マジンガーZの検索結果'
      end
    end
  end
end
