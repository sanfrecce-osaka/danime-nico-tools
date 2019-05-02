# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SeasonHash do
  describe '.already_created' do
    let(:already_created) { SeasonHash.already_created }

    it '作品の全てのfixtureを読み込んでいる' do
      expect(already_created.length).to eq 1
    end
  end
end
