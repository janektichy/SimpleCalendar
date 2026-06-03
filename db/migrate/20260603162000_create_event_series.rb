class CreateEventSeries < ActiveRecord::Migration[8.1]
  def change
    create_table :event_series do |t|
      t.references :user, null: false, foreign_key: true
      t.string :repeat_frequency, null: false
      t.integer :occurrences_count, null: false

      t.timestamps
    end
  end
end
