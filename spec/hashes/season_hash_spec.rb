# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SeasonHash do
  describe '.already_created' do
    let(:already_created) { SeasonHash.already_created }

    it '作品の全てのfixtureを読み込んでいる' do
      expect(already_created.length).to eq 1
    end

    it '全てのfixtureが読み込み元のpathを持っている' do
      expect(already_created.all? { |season| season.has_key?(:file_path) }).to be_truthy
      expect(already_created.map(&:file_path).all? { |path| path.include?('./spec/fixtures/seasons/') }).to be_truthy
    end
  end
end
