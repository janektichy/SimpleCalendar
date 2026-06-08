class AddSettingsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :default_upcoming_days, :integer, null: false, default: 1
    add_column :users, :default_calendar_view, :string, null: false, default: "month"
  end
end
