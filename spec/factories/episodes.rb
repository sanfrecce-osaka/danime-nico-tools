# frozen_string_literal: true

FactoryBot.define do
  sequence :title do |n| "エピソード#{n}" end
  sequence :description do |n| "あらすじ#{n}" end
  sequence :overall_number do |n| n end
  sequence :number_in_season do |n| "第#{n}話" end
  sequence :default_thread_id do |n| n end
  sequence :thumbnail_url do |n| "http://dammy.com?i=#{n}" end
  sequence :content_id do |n| "so#{n}" end
  
  factory :episode do
    title
    description
    overall_number
    number_in_season
    default_thread_id
    thumbnail_url
    content_id

    trait :with_season do
      season
    end
  end
end
