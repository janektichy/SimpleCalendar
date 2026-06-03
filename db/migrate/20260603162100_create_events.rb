class CreateEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :events do |t|
      t.string :title, null: false
      t.text :description
      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false
      t.boolean :all_day, null: false, default: false
      t.string :location
      t.string :color, null: false, default: "slate"
      t.references :user, null: false, foreign_key: true
      t.references :event_series, foreign_key: true

      t.timestamps
    end

    add_index :events, %i[user_id starts_at]
  end
end
