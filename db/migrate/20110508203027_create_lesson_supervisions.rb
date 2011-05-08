class CreateLessonSupervisions < ActiveRecord::Migration
  def self.up
    create_table :lesson_supervisions do |t|
      t.string :unique_names
      t.integer :instructors_count
      t.string :comment

      t.timestamps
    end
  end

  def self.down
    drop_table :lesson_supervisions
  end
end
