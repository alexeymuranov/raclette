## encoding: UTF-8

class MembersController < SecretaryController  # FIXME: untested work in progress

  def index
    @query_type = params[:query_type]
    @submit_button = params[:button]
    params.delete(:query_type)
    params.delete(:commit)
    params.delete(:button)

    if @query_type == 'filter' && @submit_button == 'clear_button'
      params.delete(:filter)
    end

    @attributes = [ :ordered_full_name,
                    :email,
                    :account_deactivated,
                    :tickets_count ]

    set_column_types

    # Filter:
    # html_table_id = :members
    @all_filtered_members = filter(Member.with_person_and_virtual_attributes,
                                   :members)

    # Sort:
    # html_table_id = :members
    @all_filtered_members = sort(@all_filtered_members, :members)

    # Paginate:
    @members = paginate(@all_filtered_members)

    # Compose mailing list:
    if params[:list_email_addresses]
      @mailing_list_members =
          @all_filtered_members.select { |member| !member.email.blank? }
      @mailing_list = @mailing_list_members.collect(&:formatted_email).join(', ')
    end

    @attributes_for_download = [ :last_name,
                                 :first_name,
                                 :nickname_or_other,
                                 :email ]

    set_column_headers
    set_column_headers_for_download

    respond_to do |requested_format|
      requested_format.html do
        # @title = t('members.index.title')  # or: Member.model_name.human.pluralize
        # raise "#{@members.to_sql}"

        render :index
      end

      requested_format.xml do
        render :xml  => @all_filtered_members,
               :only => @attributes_for_download
      end

      requested_format.js do
        case @query_type
        when 'show_email_addresses', 'hide_email_addresses'
          render :update_email_list
        end
      end

      requested_format.ms_excel_2003_xml do
        render_ms_excel_2003_xml_for_download\
            @all_filtered_members,
            @attributes_for_download, @column_types,
            @column_headers_for_download,
            "#{Member.model_name.human.pluralize}"\
            " #{Time.now.strftime('%Y-%m-%d %k_%M')}"\
            ".excel2003.xml"  # defined in ApplicationController
      end

      requested_format.csv do
        render_csv_for_download\
            @all_filtered_members,
            @attributes_for_download,
            @column_headers_for_download,
            "#{Member.model_name.human.pluralize}"\
            " #{Time.now.strftime('%Y-%m-%d %k_%M')}"\
            ".csv"  # defined in ApplicationController
      end
    end
  end

  def show
    @member = Member.with_person_and_virtual_attributes.find(params[:id])

    @attributes = [ :person_id,
                    :name_title,
                    :first_name,
                    :last_name,
                    :nickname_or_other,
                    :email,
                    :payed_tickets_count,
                    :free_tickets_count,
                    :account_deactivated,
                    :been_member_by ]

    set_column_types
    # set_column_headers

    @title = t('members.show.title', :name => @member.full_name)
  end

  def new
    @member = Member.new
    @member.build_person

    render_new_properly
  end

  def edit
    @member = Member.with_person_and_virtual_attributes.find(params[:id])

    render_edit_properly
  end

  def create

    params[:member].delete(:email)\
        if params[:member][:email].blank?

    # @acceptable_attributes = [ 'been_member_by', 'person_attributes' ]
    # params[:member].slice!(*@acceptable_attributes)

    # Because members primary key works as foreign key for people
    # (this is not recommended in general),
    # building an associated person and saving the member with person with
    # "@member.save" does not seem to work (probably causes stack overflow).
    # The only workaround seems to be to save the person first,
    # assign the foreign key manually, and then save the member.
    @person = Person.new
    @member = Member.new
    params[:member][:person_attributes].delete(:email)\
      if params[:member][:person_attributes][:email].blank?

    @person.attributes = params[:member][:person_attributes]
    @member.attributes = params[:member].except(:person_attributes)

    unless @person.save
      flash.now[:error] = t('flash.members.create.failure')
      @member.person = @person  # seems safe here

      render_new_properly
      return  # i believe render itself does not stop exectition of the method
    end

    @member.person_id = @person.id

    if @member.save
      flash[:success] = t('flash.members.create.success',
                          :name => @member.full_name)
      redirect_to @member
    else
      flash.now[:error] = t('flash.members.create.failure')

      render_new_properly
    end
  end

  def update
    @member = Member.with_person_and_virtual_attributes.find(params[:id])

    params[:member][:safe_ip_ids] ||= []

    params[:member].delete(:email)\
        if params[:member][:email].blank?

    params[:member].delete(:comments)\
        if params[:member][:comments].blank?

    unless params[:change_password]
      params.delete(:current_password)
      params[:member].except!(:new_password, :new_password_confirmation)
    end

    # @acceptable_attributes = [ 'been_member_by', 'person_attributes' ]
    # params[:member].slice!(*@acceptable_attributes)

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
                       :name => @member.full_name)

    redirect_to members_url
  end

  private

    def html_table_id_to_class(html_table_id)
      case html_table_id
      when :members then Member
      else nil
      end
    end

    def default_sort_column(html_table_id)
      case html_table_id
      when :members then :ordered_full_name
      else nil
      end
    end

    def render_new_properly
      @column_types = {}
      Member.columns_hash.each do |key, value|
        @column_types[key.intern] = value.type
      end

      @title = t('members.new.title')

      render :new
    end

    def render_edit_properly
      @column_types = {}
      Member.columns_hash.each do |key, value|
        @column_types[key.intern] = value.type
      end

      @title =  t('members.edit.title', :name => @member.full_name)

      render :edit
    end

    def set_column_types
      @column_types = {}
      Member.columns_hash.each do |key, value|
        @column_types[key.intern] = value.type
      end

      @column_types.merge!( :full_name           => :virtual_string,
                            :ordered_full_name   => :virtual_string,
                            :email               => :delegated_string,
                            :account_deactivated      => :virtual_boolean,
                            :payed_tickets_count => :integer,
                            :free_tickets_count  => :integer,
                            :tickets_count       => :virtual_integer )
      # NOTE: virtual_ includes "delegated_to_virtual_",
      #       but not "delegated_to_real_".
      #       "delegated_to_real_" is simply delegated_
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

    def set_column_headers_for_download
      @column_headers_for_download = {}
      @attributes_for_download.each do |attr|
        @column_headers_for_download[attr] = Member.human_attribute_name(attr)
      end
    end

end
