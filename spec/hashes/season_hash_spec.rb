# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SeasonHash do
  describe '.already_created' do
    let(:already_created) { SeasonHash.already_created }

    it '作品の全てのfixtureを読み込んでいる' do
      expect(already_created.length).to eq 3
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
      )
      expect(already_created.map(&:file_path)).to eq expected
    end
  end
end
