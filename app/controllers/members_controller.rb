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

    @attributes = [ :full_name, :email, :account_active, :tickets_count ]
    set_column_types

    # Filter:
    @all_filtered_members = filter(Member.default_join, :members)  # html_table_id = :members

    # Sort:
    @all_filtered_members = sort(@all_filtered_members, :members)  # html_table_id = :members

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
        # @title = t('members.index.title')  # or: Member.human_name.pluralize
        render :index
      end

      requested_format.xml do
        render :xml  => @all_filtered_members,
               :only => @attributes_for_download
      end

      requested_format.js do
        case @query_type
        # when 'filter', 'sort'
        # when 'repaginate'
        when 'show_email_addresses', 'hide_email_addresses'
          render :update_email_list
        # else
        end
      end

      requested_format.ms_excel_2003_xml do
        render_ms_excel_2003_xml_for_download\
            Member, @all_filtered_members,
            @attributes_for_download, @column_types  # defined in ApplicationController
      end

      requested_format.csv do
        render_csv_for_download\
            Member, @all_filtered_members,
            @attributes_for_download  # defined in ApplicationController
      end
    end
  end

  def show
    @member = Member.find(params[:id])

    @key_attributes = []
    @other_main_attributes = [ :person_id,
                               :full_name,
                               :email ]
    @other_attributes = []

    @title = t('members.show.title', :name => @member.full_name)
  end

  def new
    @member = Member.new
    @member.build_person

    render_new_properly
  end

  def edit
    @member = Member.find(params[:id])

    render_edit_properly
  end

  def create

    params[:member].delete(:email)\
        if params[:member][:email].blank?

    @acceptable_attributes = [ 'last_name', 'first_name', 'name_title',
                              'nickname_or_other', 'email', 'been_member_by' ]

    params[:member].slice!(*@acceptable_attributes)

    @member = Member.new
    @member.build_person
    @member.attributes = params[:member]

    if @member.save
      flash[:success] = t('flash.members.create.success',
                          :name => @member.full_name)
      redirect_to @member
    else
      flash.now[:error] = t('flash.members.create.failure')

      render_new_properly  # is it OK?
    end
  end

  def update
    @member = Member.find(params[:id])

    params[:member][:safe_ip_ids] ||= []

    params[:member].delete(:email)\
        if params[:member][:email].blank?

    params[:member].delete(:comments)\
        if params[:member][:comments].blank?

    unless params[:change_password]
      params.delete(:current_password)
      params[:member].except!(:new_password, :new_password_confirmation)
    end

    @acceptable_attributes = [ 'last_name', 'first_name', 'nickname_or_other',
                              'email' ]

    params[:member].slice!(*@acceptable_attributes)

    if @member.update_attributes(params[:member])
      flash[:notice] = t('flash.members.update.success',
                         :name => @member.full_name)
      redirect_to @member
    else
      flash.now[:error] = t('flash.members.update.failure')

      render_edit_properly  # is it OK?
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
      when :members then :full_name  # FIXME
      # How to order by virtual attributes?
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

      @column_types.merge!( :full_name      => :virtual_string,
                            :email          => :delegated_string,
                            :account_active => :virtual_boolean,
                            :tickets_count  => :virtual_integer )
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

        case @column_types[attr]
        when :boolean, :delegated_boolean, :virtual_boolean
          @column_headers_for_download[attr] = I18n.t('formats.attribute_name?',
              :attribute => @column_headers_for_download[attr])
        else
          @column_headers_for_download[attr] = I18n.t('formats.attribute_name:',
              :attribute => @column_headers_for_download[attr])
        end
      end
    end

end
