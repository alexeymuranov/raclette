## encoding: UTF-8

class TicketBooksController < ManagerController

  class TicketBook < Accessors::TicketBook
    self.all_sorting_columns = [:tickets_number, :price]
    self.default_sorting_column = :start_date
  end

  def index
    @submit_button = params[:button]

    case request.format
    when Mime::HTML
      @attributes = [:tickets_number, :price]
    when Mime::XML, Mime::CSV, Mime::MS_EXCEL_2003_XML, Mime::CSV_ZIP, Mime::MS_EXCEL_2003_XML_ZIP
      @attributes = [:tickets_number, :price]
    end

    @column_types = TicketBook.column_db_types

    @ticket_books = TicketBook.scoped

    # Filter:
    @ticket_books = TicketBook.filter(@ticket_books,
                                      params[:filter],
                                      @attributes)
    @filtering_values = TicketBook.last_filter_values
    @filtered_ticket_books_count = @ticket_books.count

    # Sort:
    TicketBook.all_sorting_columns = @attributes
    sort_params = (params[:sort] && params[:sort][:ticket_books]) || {}
    @ticket_books = TicketBook.sort(@ticket_books, sort_params)
    @sorting_column = TicketBook.last_sort_column
    @sorting_direction = TicketBook.last_sort_direction

    @column_headers = TicketBook.human_column_headers

    respond_to do |requested_format|
      requested_format.html do

        # Paginate:
        @ticket_books = paginate(@ticket_books)

        # @title = t('ticket_books.index.title')  # or: TicketBook.model_name.human.pluralize
        render :index
      end

      requested_format.xml do
        render :xml  => @ticket_books,
               :only => @attributes
      end

      requested_format.ms_excel_2003_xml_zip do
        render :collection_ms_excel_2003_xml_zip => @ticket_books,
               :only                             => @attributes,
               :headers                          => @column_headers
      end

      requested_format.csv_zip do
        render :collection_csv_zip => @ticket_books,
               :only               => @attributes,
               :headers            => @column_headers
      end
    end
  end

  def show
    @attributes = [:tickets_number, :price]

    @ticket_book = TicketBook.find(params[:id])

    @column_types = TicketBook.column_db_types

    @title = t('ticket_books.show.title',
               :title => @ticket_book.virtual_long_title)
  end

  def new
    @ticket_book = TicketBook.new

    render_new_properly
  end

  def edit
    @ticket_book = TicketBook.find(params[:id])

    render_edit_properly
  end

  def create
    @ticket_book = TicketBook.new
    @ticket_book.assign_attributes(params[:ticket_book])

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
    @ticket_book = TicketBook.find(params[:id])

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
    @ticket_book = TicketBook.find(params[:id])
    @ticket_book.destroy

    flash[:notice] = t('flash.ticket_books.destroy.success',
                       :title => @ticket_book.virtual_long_title)

    redirect_to :action => :index
  end

  private

    def render_new_properly
      @attributes = [:tickets_number, :price]
      @column_types = TicketBook.column_db_types

      @title = t('ticket_books.new.title')

      render :new
    end

    def render_edit_properly
      @attributes = [:tickets_number, :price]
      @column_types = TicketBook.column_db_types

      @title =  t('ticket_books.edit.title',
                  :title => @ticket_book.virtual_long_title)

      render :edit
    end

end
