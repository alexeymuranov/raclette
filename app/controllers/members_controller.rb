## encoding: UTF-8

class MembersController < SecretaryController  # FIXME: untested work in progress

  param_accessible({ 'member' => Set[
                       'person_attributes',
                       'last_name', 'first_name', 'name_title',
                       'nickname_or_other', 'email',
                       'free_tickets_count', 'account_deactivated'] },
                     :only => [:create, :update] )
  param_accessible({ 'member' => 'been_member_by' },
                     :only => :create )

  def index
    @query_type = params[:query_type]
    @submit_button = params[:button]
    params.delete(:query_type)
    params.delete(:commit)
    params.delete(:button)

    if @query_type == 'filter' && @submit_button == 'clear_button'
      params.delete(:filter)
    end

    case request.format
    when 'html'
      @attributes = [:ordered_full_name,
                     :email,
                     :account_deactivated,
                     :tickets_count]
    when 'xml', 'csv', 'ms_excel_2003_xml'
      @attributes = [:last_name,
                     :first_name,
                     :nickname_or_other,
                     :email,
                     :tickets_count]
    end

    @column_types = Member.attribute_db_types
    @sql_for_attributes = Member.sql_for_attributes

    @members = Member.joins(:person).
      with_virtual_attributes(*@attributes, :formatted_email)

    # Filter:
    @members = Member.filter(@members, params[:filter], @attributes)
    @filtering_values = Member.last_filter_values

    # Sort:
    Member.all_sorting_columns = @attributes
    Member.default_sorting_column = ( request.format == 'html' ?
                                      :ordered_full_name : :last_name )
    sort_params = (params[:sort] && params[:sort][:members]) || {}
    @members = Member.sort(@members, sort_params)
    @sorting_column = Member.last_sort_column
    @sorting_direction = Member.last_sort_direction

    # Compose mailing list:
    if params[:list_email_addresses]
      @mailing_list_members = @members.select { |member| !member.email.blank? }
      @mailing_list = @mailing_list_members.collect(&:formatted_email).
        join(', ')
    end

    set_column_headers

    respond_to do |requested_format|
      requested_format.html do
        # Paginate:
        @members = paginate(@members)

        # @title = t('members.index.title')  # or: Member.model_name.human.pluralize
        render :index
      end

      requested_format.js do
        case @query_type
        when 'show_email_addresses', 'hide_email_addresses'
          render :update_email_list
        end
      end

      # For download:
      requested_format.xml do
        render :xml  => @members,
               :only => @attributes
      end

      requested_format.ms_excel_2003_xml do
        render_ms_excel_2003_xml_for_download\
            @members,
            @attributes,
            @column_headers  # defined in ApplicationController
      end

      requested_format.csv do
        render_csv_for_download\
            @members,
            @attributes,
            @column_headers  # defined in ApplicationController
      end
    end
  end

  def show

    @attributes = [:person_id,
                   :name_title,
                   :first_name,
                   :last_name,
                   :nickname_or_other,
                   :email,
                   :payed_tickets_count,
                   :free_tickets_count,
                   :account_deactivated,
                   :been_member_by,
                   :full_name]

    @member = Member.joins(:person).with_virtual_attributes(*@attributes)\
                    .find(params[:id])

    @column_types = Member.attribute_db_types
    # set_column_headers

    @title = t('members.show.title', :name => @member.non_sql_full_name)
  end

  def new
    @member = Member.new
    @member.build_person

    render_new_properly
  end

  def edit
    @member = Member.joins(:person).with_virtual_attributes(:full_name)\
                    .find(params[:id])

    render_edit_properly
  end

  def create

    params[:member].delete(:email)\
        if params[:member][:email].blank?

    # Because members primary key works as foreign key for people
    # (this is not recommended in general),
    # building an associated person and saving the member with person with
    # "@member.save" does not seem to work in rails 3.0.9
    # (probably causes stack overflow).
    # The only workaround seems to be to save the person first,
    # assign the foreign key manually, and then save the member.
    @person = Person.new
    @member = Member.new
    params[:member][:person_attributes].delete(:email)\
      if params[:member][:person_attributes][:email].blank?

    @person.assign_attributes(params[:member][:person_attributes])
    @member.assign_attributes(params[:member].except(:person_attributes))

    unless @person.save
      flash.now[:error] = t('flash.members.create.failure')
      @member.person = @person  # seems safe here

      render_new_properly and return
    end

    @member.person_id = @person.id

    if @member.save
      flash[:success] = t('flash.members.create.success',
                          :name => @member.non_sql_full_name)
      redirect_to @member
    else
      flash.now[:error] = t('flash.members.create.failure')

      render_new_properly
    end
  end

  def update
    @member = Member.joins(:person).with_virtual_attributes(:full_name)\
                    .find(params[:id])

    params[:member][:person_attributes].delete(:email)\
        if params[:member][:email].blank?

    if @member.update_attributes(params[:member])
      flash[:notice] = t('flash.members.update.success',
                         :name => @member.full_name)
      redirect_to @member
    else
      flash.now[:error] = t('flash.members.update.failure')

      render_edit_properly
    end
  end

  def destroy
    @member = Member.find(params[:id])
    @member.destroy

    flash[:notice] = t('flash.members.destroy.success',
                       :name => @member.non_sql_full_name)

    redirect_to members_url
  end

  private

    def render_new_properly
      @column_types = Member.attribute_db_types

      @title = t('members.new.title')

      render :new
    end

    def render_edit_properly
      @column_types = Member.attribute_db_types

      @title =  t('members.edit.title', :name => @member.non_sql_full_name)

      render :edit
    end

    def set_column_headers
      @column_headers = {}
      @attributes.each do |attr|
        @column_headers[attr] = Member.human_attribute_name(attr)

        case @column_types[attr]
        when :boolean, :delegated_boolean, :virtual_boolean
          @column_headers[attr] = I18n.t('formats.attribute_name?',
              :attribute => @column_headers[attr])
        else
          @column_headers[attr] = I18n.t('formats.attribute_name:',
              :attribute => @column_headers[attr])
        end
      end
    end

end
