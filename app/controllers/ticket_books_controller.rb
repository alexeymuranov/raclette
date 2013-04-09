## encoding: UTF-8

# TODO: implement params processing.

class TicketBooksController < ManagerController

  before_filter :find_membership, :except => :index

  def index
    case request.format
    when Mime::HTML
      @attribute_names = [:tickets_number, :price]
    when Mime::XML, Mime::CSV, Mime::MS_EXCEL_2003_XML,
         Mime::CSV_ZIP, Mime::MS_EXCEL_2003_XML_ZIP
      @attribute_names = [:tickets_number, :price]
    end

    # @ticket_books = @membership.ticket_books
    @ticket_books = TicketBook.scoped

    # Filter:
    @ticket_books = do_filtering(@ticket_books)
    @filtered_ticket_books_count = @ticket_books.count

    # Sort:
    sort_params = (params[:sort] && params[:sort][:ticket_books]) || {}
    @ticket_books = sort(@ticket_books, sort_params, :tickets_number)

    respond_to do |requested_format|
      requested_format.html do

        # Paginate:
        @ticket_books = paginate(@ticket_books)

        render :index
      end

      requested_format.xml do
        render :xml  => @ticket_books,
               :only => @attribute_names
      end

      requested_format.ms_excel_2003_xml_zip do
        render :collection_ms_excel_2003_xml_zip => @ticket_books,
               :only                             => @attribute_names
      end

      requested_format.csv_zip do
        render :collection_csv_zip => @ticket_books,
               :only               => @attribute_names
      end
    end
  end

  def show
    @ticket_book = TicketBook.find(params['id'])
    unless @ticket_book.membership.id == @membership.id
      redirect_to :back && return
    end

    @attribute_names = [:tickets_number, :price]

    @title = t('ticket_books.show.title',
               :title => @ticket_book.virtual_long_title)
  end

  def new
    @ticket_book = TicketBook.new

    render_new_properly
  end

  def edit
    @ticket_book = TicketBook.find(params['id'])
    unless @ticket_book.membership.id == @membership.id
      redirect_to :back && return
    end

    render_edit_properly
  end

  def create
    @ticket_book =
      TicketBook.new(
        params[:ticket_book].merge(:membership_id => params[:membership_id]))

    if @ticket_book.save
      flash[:success] = t('flash.ticket_books.create.success',
                          :title => @ticket_book.virtual_long_title)
      redirect_to :action => :show, :id => @ticket_book
    else
      flash.now[:error] = t('flash.ticket_books.create.failure')

      render_new_properly
    end
  end

  def update
    @ticket_book = TicketBook.find(params['id'])
    unless @ticket_book.membership.id == @membership.id
      redirect_to :back && return
    end

    if @ticket_book.update_attributes(params[:ticket_book])
      flash[:notice] = t('flash.ticket_books.update.success',
                         :title => @ticket_book.virtual_long_title)
      redirect_to :action => :show, :id => @ticket_book
    else
      flash.now[:error] = t('flash.ticket_books.update.failure')

      render_edit_properly
    end
  end

  def destroy
    @ticket_book = TicketBook.find(params['id'])
    unless @ticket_book.membership.id == @membership.id
      redirect_to :back && return
    end

    @ticket_book.destroy

    flash[:notice] = t('flash.ticket_books.destroy.success',
                       :title => @ticket_book.virtual_long_title)

    redirect_to :controller => :memberships,
                :action     => :show,
                :id         => @ticket_book.membership_id
  end

  private

    def find_membership
      @membership = Membership.find(params['membership_id'])
    end

    def render_new_properly
      @attribute_names = [:tickets_number, :price]

      @title = t('ticket_books.new.title')

      render :new
    end

    def render_edit_properly
      @attribute_names = [:tickets_number, :price]

      @title = t('ticket_books.edit.title',
                 :title => @ticket_book.virtual_long_title)

      render :edit
    end

  module AttributesFromParamsForCreate
    private
      # TODO: implement
  end
  include AttributesFromParamsForCreate

  module AttributesFromParamsForUpdate
    private
      # TODO: implement
  end
  include AttributesFromParamsForUpdate
end
