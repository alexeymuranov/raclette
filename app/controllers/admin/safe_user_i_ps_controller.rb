## encoding: UTF-8

class Admin::SafeUserIPsController < Admin::AdminController

  def index
    @users = User.default_order
    @known_ips = KnownIP.default_order
  end

  def edit_all
    @users = User.default_order
    @known_ips = KnownIP.default_order
  end

  def update_all
    safe_user_ids_for_known_ips =
      process_raw_safe_user_ids_for_known_ips_for_create

    KnownIP.all.each do |known_ip|
      known_ip.safe_user_ids = safe_user_ids_for_known_ips[known_ip.id]
    end

    redirect_to :action => :index
  end

  module AttributesFromParamsForUpdateAll
    private

      def process_raw_safe_user_ids_for_known_ips_for_create(
            submitted_attributes = params['safe_user_ids_for_known_ips'])
        result_in_array = submitted_attributes.map { |key, value|
          [key.to_i, value.map(&:to_i)]
        }
        Hash[result_in_array]
      end

  end
  include AttributesFromParamsForUpdateAll
end
