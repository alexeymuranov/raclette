class AssociateTicketBooksWithMemberships < ActiveRecord::Migration
  def up
    remove_index  'ticket_books', ['membership_type_id', 'tickets_number']

    add_column    'ticket_books', 'membership_id', :integer

    TicketBook.find_each do |tb|
      tb.membership_id =
        Membership.where(:membership_type_id => tb.membership_type_id).last.id
      tb.save!
    end

    change_column 'ticket_books', 'membership_id', :integer, :null => false

    remove_column 'ticket_books', 'membership_type_id'

    add_index     'ticket_books', ['membership_id', 'tickets_number'],
                                  :unique => true
  end

  def down
    remove_index  'ticket_books', ['membership_id', 'tickets_number']

    add_column    'ticket_books', 'membership_type_id', :integer

    TicketBook.find_each do |tb|
      tb.membership_type_id = Membership.find(tb.membership_id).type.id
      tb.save!
    end

    change_column 'ticket_books', 'membership_type_id', :integer, :null => false

    remove_column 'ticket_books', 'membership_id'

    add_index     'ticket_books', ['membership_type_id', 'tickets_number'],
                                  :unique => true
  end
end
