## encoding: UTF-8

class Admin::KnownIPsController < AdminController

  def index
    @attributes = [ :ip, :description ]

    set_column_types
    set_users_column_headers

    # Sort:
    @known_ips = sort(Admin::KnownIP.scoped, :known_ips)  # html_table_id = :known_ips

    # @title = t('admin.known_i_ps.index.title')
  end

  def show
    @known_ip = Admin::KnownIP.find(params[:id])
    @safe_users = @known_ip.safe_users.order(sort_sql(:safe_users))

    @key_attributes = [ :ip ]
    @other_main_attributes = [ :description ]

    @safe_users_attributes = [ :username,
                               :full_name,
                               :account_deactivated,
                               :admin,
                               :manager,
                               :secretary,
                               :a_person ]

    set_users_column_types
    set_users_column_headers

    @title = t('admin.known_i_ps.show.title', :ip => @known_ip.ip)
  end

  def new
    @known_ip = Admin::KnownIP.new

    render_new_properly
  end

  def edit
    @known_ip = Admin::KnownIP.find(params[:id])

    render_edit_properly
  end

  def create
    @acceptable_attributes = [ 'ip', 'description' ]

    params[:admin_known_ip].keep_if do |key, value|
      @acceptable_attributes.include? key
    end

    @known_ip = Admin::KnownIP.new(params[:admin_known_ip])

    if @known_ip.save
      flash[:success] = t('flash.admin.known_i_ps.create.success',
                          :ip => @known_ip.ip)
      redirect_to @known_ip
    else
      flash.now[:error] = t('flash.admin.known_i_ps.create.failure')

      render_new_properly
    end
  end

  def update
    @acceptable_attributes = [ 'ip', 'description' ]

    params[:admin_known_ip].keep_if do |key, value|
      @acceptable_attributes.include? key
    end

    @known_ip = Admin::KnownIP.find(params[:id])

    if @known_ip.update_attributes(params[:admin_known_ip])
      flash[:notice] =  t('flash.admin.known_i_ps.update.success',
                          :ip => @known_ip.ip)
      redirect_to @known_ip
    else
      flash.now[:error] = t('flash.admin.known_i_ps.update.failure')

      render_edit_properly
    end
  end

  def destroy
    @known_ip = Admin::KnownIP.find(params[:id])
    @known_ip.destroy
    flash[:notice] = t('flash.admin.known_i_ps.destroy.success',
                       :ip => @known_ip.ip)

    redirect_to admin_known_ips_url
  end

  private

    def html_table_id_to_class(html_table_id)
      case html_table_id
      when :known_ips then Admin::KnownIP
      when :safe_users then Admin::User
      else nil
      end
    end

    def default_sort_column(html_table_id)
      case html_table_id
      when :known_ips then :ip
      when :safe_users then :username
      else nil
      end
    end

    def render_new_properly
      set_column_types

      @title = t('admin.known_i_ps.new.title')

      render :new
    end

    def render_edit_properly
      set_column_types

      @title = t('admin.known_i_ps.edit.title', :ip => @known_ip.ip)

      render :edit
    end

    def set_column_types
      @column_types = {}
      Admin::KnownIP.columns_hash.each do |key, value|
        @column_types[key.intern] = value.type
      end
    end

    def set_column_headers
      @column_headers = {}
      @column_types.each do |attr, type|
        human_name = Admin::KnownIP.human_attribute_name(attr)

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

    def set_users_column_types
      @users_column_types = {}
      Admin::User.columns_hash.each do |key, value|
        @users_column_types[key.intern] = value.type
      end
    end

    def set_users_column_headers
      @users_column_headers = {}
      @users_column_types.each do |attr, type|
        human_name = Admin::User.human_attribute_name(attr)

        case type
        when :boolean
          @users_column_headers[attr] = I18n.t('formats.attribute_name?',
                                               :attribute => human_name)
        else
          @users_column_headers[attr] = I18n.t('formats.attribute_name:',
                                               :attribute => human_name)
        end
      end
    end

end
