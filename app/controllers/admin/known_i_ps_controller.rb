## encoding: UTF-8

class Admin::KnownIPsController < AdminController

  def index
    @attribute_names = [:ip, :description]

    @known_ips = KnownIP.all

    # Sort:
    sort_params = (params[:sort] && params[:sort][:known_ips]) || {}
    @known_ips = sort(@known_ips, sort_params, :ip)
  end

  def show
    @known_ip = KnownIP.find(params['id'])
    @safe_users = @known_ip.safe_users

    @attribute_names = [:ip, :description]

    @safe_user_attribute_names = [ :username,
                                   :full_name,
                                   :account_deactivated,
                                   :admin,
                                   :manager,
                                   :secretary,
                                   :a_person ]

    # Sort safe users:
    sort_params = (params[:sort] && params[:sort][:safe_users]) || {}
    @safe_users = sort(@safe_users, sort_params, :username)

    @title = t('admin.known_i_ps.show.title', :ip => @known_ip.ip)
  end

  def new
    @known_ip = KnownIP.new

    render_new_properly
  end

  def edit
    @known_ip = KnownIP.find(params['id'])

    render_edit_properly
  end

  def create
    attributes = process_raw_known_ip_attributes_for_create
    @known_ip = KnownIP.new(attributes)

    if @known_ip.save
      flash[:success] = t('flash.admin.known_i_ps.create.success',
                          :ip => @known_ip.ip)
      redirect_to :action => :show, :id => @known_ip
    else
      flash.now[:error] = t('flash.admin.known_i_ps.create.failure')

      render_new_properly
    end
  end

  def update
    @known_ip = KnownIP.find(params['id'])

    attributes = process_raw_known_ip_attributes_for_update

    if @known_ip.update_attributes(attributes)
      flash[:notice] =  t('flash.admin.known_i_ps.update.success',
                          :ip => @known_ip.ip)
      redirect_to :action => :show, :id => @known_ip
    else
      flash.now[:error] = t('flash.admin.known_i_ps.update.failure')

      render_edit_properly
    end
  end

  def destroy
    @known_ip = KnownIP.find(params['id'])

    @known_ip.destroy

    flash[:notice] = t('flash.admin.known_i_ps.destroy.success',
                       :ip => @known_ip.ip)

    redirect_to :action => :index
  end

  private

    def render_new_properly
      @title = t('admin.known_i_ps.new.title')

      render :new
    end

    def render_edit_properly
      @title = t('admin.known_i_ps.edit.title', :ip => @known_ip.ip)

      render :edit
    end

  module AttributesFromParamsForCreate
    KNOWN_IP_ATTRIBUTE_NAMES = Set[:ip, :description]
    KNOWN_IP_ATTRIBUTE_NAMES_FROM_STRINGS =
      KNOWN_IP_ATTRIBUTE_NAMES.reduce({}) { |h, attr_name|
        h[attr_name.to_s] = attr_name
        h
      }

    private

      def known_ip_attribute_name_from_params_key_for_create(params_key)
        KNOWN_IP_ATTRIBUTE_NAMES_FROM_STRINGS[params_key]
      end

      def process_raw_known_ip_attributes_for_create(submitted_attributes = params['known_ip'])
        result_as_array = submitted_attributes.map { |key, value|
          [known_ip_attribute_name_from_params_key_for_create(key), value]
        }.select { |attr_name, _|
          attr_name
        }.map { |attr_name, value|
          if value == '' then value = nil end
          [attr_name, value]
        }
        Hash[result_as_array]
      end

  end
  include AttributesFromParamsForCreate

  module AttributesFromParamsForUpdate
    KNOWN_IP_ATTRIBUTE_NAMES = Set[:description]
    KNOWN_IP_ATTRIBUTE_NAMES_FROM_STRINGS =
      KNOWN_IP_ATTRIBUTE_NAMES.reduce({}) { |h, attr_name|
        h[attr_name.to_s] = attr_name
        h
      }

    private

      def known_ip_attribute_name_from_params_key_for_update(params_key)
        KNOWN_IP_ATTRIBUTE_NAMES_FROM_STRINGS[params_key]
      end

      def process_raw_known_ip_attributes_for_update(submitted_attributes = params['known_ip'])
        result_as_array = submitted_attributes.map { |key, value|
          [known_ip_attribute_name_from_params_key_for_update(key), value]
        }.select { |attr_name, _|
          attr_name
        }.map { |attr_name, value|
          if value == '' then value = nil end
          [attr_name, value]
        }
        Hash[result_as_array]
      end

  end
  include AttributesFromParamsForUpdate
end
