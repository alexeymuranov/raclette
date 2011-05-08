class CreateLessonInstructors < ActiveRecord::Migration
  def self.up
    create_table :lesson_instructors do |t|
      t.integer :lesson_supervision_id
      t.integer :instructor_id
      t.boolean :invited
      t.boolean :volunteer
      t.boolean :assistant

      t.timestamps
    end
  end

  def self.down
    drop_table :lesson_instructors
  end
end
