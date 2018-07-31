# frozen_string_literal: true

class CreateSeasons < ActiveRecord::Migration[5.2]
  def change
    create_table :seasons do |t|
      t.string :title, index: true
      t.boolean :watchable, default: false, null: false
      t.string :thumbnail_url
      t.text :outline
      t.text :cast
      t.text :staff
      t.integer :produced_year, index: true
      t.string :copyright

      t.timestamps null: false
    end

    add_presence_constraint :seasons, :title
  end
end
