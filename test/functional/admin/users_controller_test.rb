require 'test_helper'

class Admin::UsersControllerTest < ActionController::TestCase

  setup do
    @user_admin = admin_users(:one)
    @another_user = admin_users(:user_secretary)
    test_log_in(@user_admin, :admin, "127.0.0.1")
  end

  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get CSV from index" do
    get :index, :format => 'csv'
    assert_response :success
  end

  test "should get MS_EXCEL_2003_XML from index" do
    get :index, :format => 'ms_excel_2003_xml'
    assert_response :success
  end

  test "should download CSV_ZIP from index" do
    get :index, :format => 'csv_zip'
    assert_response :success
  end

  test "should download MS_EXCEL_2003_XML_ZIP from index" do
    get :index, :format => 'ms_excel_2003_xml_zip'
    assert_response :success
  end

  test "should get show" do
    get :show, 'id' => @another_user.to_param
    assert_response :success
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should get edit" do
    get :edit, 'id' => @another_user.to_param
    assert_response :success
  end

  test "should update user" do
    known_ip = Admin::KnownIP.first
    2.times do
      new_secretary_status = !@another_user.secretary?
      new_safe_ip_ids = @another_user.safe_ip_ids
      if new_safe_ip_ids.include? known_ip.id
        new_safe_ip_ids.delete known_ip.id
        expected_difference = -1
      else
        new_safe_ip_ids << known_ip.id
        expected_difference = 1
      end
      params_hash = { 'id'   => @another_user.to_param,
                      'user' =>  {
                        'secretary'   => new_secretary_status,
                        'safe_ip_ids' => new_safe_ip_ids } }

      assert_difference('@another_user.safe_ips.count', expected_difference) do
        put :update, params_hash
        @another_user.reload
      end

      assert_same @another_user.secretary?, new_secretary_status

      assert_redirected_to :action => :show,
                           'id'    => @another_user
    end
  end
end
