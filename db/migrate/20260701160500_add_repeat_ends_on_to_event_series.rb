class AddRepeatEndsOnToEventSeries < ActiveRecord::Migration[8.1]
  def change
    add_column :event_series, :repeat_ends_on, :date

    reversible do |dir|
      dir.up do
        execute <<~SQL.squish
          UPDATE event_series
          SET repeat_ends_on = (
            SELECT DATE(MAX(events.starts_at))
            FROM events
            WHERE events.event_series_id = event_series.id
          )
        SQL
      end
    end

    change_column_null :event_series, :repeat_ends_on, false
  end
end
