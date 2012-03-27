## encoding: UTF-8

class TicketBooksController < ManagerController

  class TicketBook < TicketBook
    self.all_sorting_columns = [:tickets_number,
                                :price]
    self.default_sorting_column = :start_date
  end

  param_accessible /.+/

  def index
    @query_type = params[:query_type]
    @submit_button = params[:button]
    params.except!(:query_type, :commit, :button)

    if @query_type == 'filter' && @submit_button == 'clear_button'
      params.delete(:filter)
    end

    case request.format
    when Mime::HTML
      @attributes = [:tickets_number,
                     :price]
    when Mime::XML, Mime::CSV, Mime::MS_EXCEL_2003_XML
      @attributes = [:tickets_number,
                     :price]
    end

    set_column_types

    @ticket_books = TicketBook.scoped

    # Filter:
    @ticket_books = TicketBook.filter(@ticket_books,
                                      params[:filter],
                                      @attributes)
    @filtering_values = TicketBook.last_filter_values

    # Sort:
    TicketBook.all_sorting_columns = @attributes
    sort_params = (params[:sort] && params[:sort][:ticket_books]) || {}
    @ticket_books = TicketBook.sort(@ticket_books, sort_params)
    @sorting_column = TicketBook.last_sort_column
    @sorting_direction = TicketBook.last_sort_direction

    set_column_headers

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

      requested_format.ms_excel_2003_xml do
        render_ms_excel_2003_xml_for_download @ticket_books,
                                              @attributes,
                                              @column_headers
      end

      requested_format.csv do
        render_csv_for_download @ticket_books,
                                @attributes,
                                @column_headers
      end
    end
  end

  def show
    @attributes = [:tickets_number,
                   :price]

    @ticket_book = TicketBook.find(params[:id])

    @column_types = TicketBook.attribute_db_types
    # set_column_headers

    @title = t('ticket_books.show.title',
               :title => @ticket_book.unique_title )
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
                          :title => @ticket_book.unique_title)
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
                         :title => @ticket_book.unique_title)
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
                       :title => @ticket_book.unique_title)

    redirect_to :action => :index
  end

  private

    def render_new_properly
      @attributes = [:tickets_number,
                     :price]
      @column_types = TicketBook.attribute_db_types

      @title = t('ticket_books.new.title')

      render :new
    end

    def render_edit_properly
      @attributes = [:tickets_number,
                     :price]
      @column_types = TicketBook.attribute_db_types

      @title =  t('ticket_books.edit.title',
                  :title => @ticket_book.unique_title)

      render :edit
    end

    def set_column_types
      @column_types = {}
      TicketBook.columns_hash.each do |key, value|
        @column_types[key.to_sym] = value.type
      end
    end

    def set_column_headers
      @column_headers = {}
      @column_types.each do |attr, type|
        human_name = TicketBook.human_attribute_name(attr)

        case type
        when :boolean
          @column_headers[attr] = I18n.t('formats.attribute_name?',
                                         :attribute => human_name)
        else
          @column_headers[attr] = I18n.t('formats.attribute_name:',
                                         :attribute => human_name)
        end
      end
    end

end
