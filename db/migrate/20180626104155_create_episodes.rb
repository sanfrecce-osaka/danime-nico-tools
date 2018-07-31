# frozen_string_literal: true

class CreateEpisodes < ActiveRecord::Migration[5.2]
  def change
    create_table :episodes do |t|
      t.string :title, index: true
      t.text :description
      t.string :number_in_season
      t.integer :overall_number, null: false
      t.integer :default_thread_id, null: false
      t.string :thumbnail_url
      t.string :content_id, index: true
      t.references :season, index: true, foreign_key: true

      t.timestamps null: false
    end

    add_presence_constraint :episodes, :title
    add_presence_constraint :episodes, :description
    add_presence_constraint :episodes, :thumbnail_url
    add_presence_constraint :episodes, :content_id
  end
end
