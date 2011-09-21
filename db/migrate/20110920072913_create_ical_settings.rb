class CreateIcalSettings < ActiveRecord::Migration
  def self.up
    create_table :ical_settings do |t|
      t.string :token, :null => false
      t.column :user_id, :integer, :null => false
      t.column :past, :integer, :null => false, :default => 1
      t.column :future, :integer, :null => false, :default => 10
      t.column :alerm, :boolean, :null => false, :default => true
      t.column :time_number, :integer, :null => false, :default => 10
      t.column :time_section, :string, :null => false, :default => "M"
      t.timestamps
    end
  end

  def self.down
    drop_table :ical_settings
  end
end
