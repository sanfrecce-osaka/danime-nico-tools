# frozen_string_literal: true

FactoryBot.define do
  factory :season do
    title { '愛少女ポリアンナ物語' }
    watchable { true }
    thumbnail_url { 'https://dammy.com' }
    outline { 'あらすじ' }
    cast { '[キャスト]<br>ポリアンナ:堀江美都子' }
    staff { '[スタッフ]<br>原作者:エレナ・ホグマン・ポーター' }
    produced_year { 1986 }
    copyright { '©NIPPON ANIMATION CO.,LTD.' }

    trait :with_episodes do
      after(:build) do |season|
        12.times { season.episodes << build(:episode) }
      end
    end
  end
end
