# frozen_string_literal: true

FactoryBot.define do
  factory :episode do
    title { 'エピソード1' }
    description { 'あらすじ1' }
    overall_number { 1 }
    number_in_season { '第1話' }
    default_thread_id { 1 }
    thumbnail_url { 'http://dammy.com?i=1' }
    content_id { 'so1' }

    trait :with_season do
      season
    end
  end
end
