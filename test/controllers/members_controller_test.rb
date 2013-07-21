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

  test "should create member" do
    assert_difference('Member.count') do
      post :create, 'member' => { 'person_attributes' =>
                                    { 'last_name'  => @member.last_name,
                                      'first_name' => @member.first_name },
                                  'been_member_by'    => '2012-09-01' }
    end

    assert_equal @member.last_name, assigns(:member).last_name
    assert_equal              2012, assigns(:member).been_member_by.year
    assert_redirected_to member_path(assigns(:member))
  end

  test "should update member" do
    put :update, 'id'     => @member.to_param,
                 'member' => { 'person_attributes'  =>
                                 { 'id'     => @member.person.to_param,
                                   'email'  => 'foo@bar.brr' },
                               'free_tickets_count' => '17' }
    assert_equal    @member.id, assigns(:member).id
    assert_equal 'foo@bar.brr', assigns(:member).email
    assert_equal            17, assigns(:member).free_tickets_count
    assert_redirected_to member_path(@member)
  end

  test "should not update member if attributes are invalid" do
    put :update, 'id'     => @member.to_param,
                 'member' =>
                   { 'person_attributes'  =>
                       { 'id'     => @member.person.id,
                         'email'  => 'foo' },
                     'free_tickets_count' => '17' }
    assert_response :success
    assert_equal 1, assigns(:member).errors.count
  end

  test "should destroy member" do
    assert_difference('Member.count', -1) do
      delete :destroy, 'id' => @member.to_param
    end

    assert_redirected_to members_path
  end
end
