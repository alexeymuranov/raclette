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

    add_index :lesson_instructors, [ :lesson_supervision_id, :instructor_id ],
                  :name   => 'index_lesson_instructors_on'\
                             '_lesson_supervision_id_and_i_id',
                  :unique => true
    add_index :lesson_instructors, :instructor_id
    add_index :lesson_instructors, :invited
    add_index :lesson_instructors, :volunteer
    add_index :lesson_instructors, :assistant
  end

  def self.down
    drop_table :lesson_instructors
  end
end
