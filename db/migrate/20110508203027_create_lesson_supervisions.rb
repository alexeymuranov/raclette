class CreateLessonSupervisions < ActiveRecord::Migration
  def up
    create_table :lesson_supervisions do |t|
      t.string  :unique_names,      :limit => 128, :null => false
      t.integer :instructors_count, :limit =>   1,
                    :default => 1,                 :null => false
      t.string  :comment,           :limit => 255

      t.timestamps
    end

    add_index :lesson_supervisions, :unique_names,
                  :unique => true
    add_index :lesson_supervisions, :instructors_count
  end

  def down
    drop_table :lesson_supervisions
  end
end
