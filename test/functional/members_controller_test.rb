require 'test_helper'

class MembersControllerTest < ActionController::TestCase

  setup do
    @user_admin = admin_users(:one)
    @member = members(:one)
    test_log_in(@user_admin, :secretary, "127.0.0.1")
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
    get :show, 'id' => @member.to_param
    assert_response :success
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should get edit" do
    get :edit, 'id' => @member.to_param
    assert_response :success
  end
end
