require 'test_helper'

class InstructorsControllerTest < ActionController::TestCase

  def setup
    @user_admin = admin_users(:one)
    @instructor = instructors(:one)
    test_log_in(@user_admin, :manager, "127.0.0.1")
  end

  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get show" do
    get :show, 'id' => @instructor.to_param
    assert_response :success
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should get edit" do
    get :edit, 'id' => @instructor.to_param
    assert_response :success
  end

  test "should create instructor" do
    assert_difference('Instructor.count') do
      post :create, 'instructor' =>
                      { 'person_attributes' =>
                          { 'last_name'  => @instructor.last_name,
                            'first_name' => @instructor.first_name },
                        'employed_from'    => '2012-09-01' }
    end

    assert_equal @instructor.last_name, assigns(:instructor).last_name
    assert_equal                  2012, assigns(:instructor).employed_from.year
    assert_redirected_to instructor_path(assigns(:instructor))
  end

  test "should update instructor" do
    put :update, 'id'         => @instructor.to_param,
                 'instructor' =>
                   { 'person_attributes'  =>
                       { 'id'     => @instructor.person.to_param,
                         'email'  => 'foo@bar.brr' },
                     'employed_from'      => '2013-09-01' }
    assert_equal    @instructor.id, assigns(:instructor).id
    assert_equal 'foo@bar.brr', assigns(:instructor).email
    assert_equal          2013, assigns(:instructor).employed_from.year
    assert_redirected_to instructor_path(@instructor)
  end

  test "should not update instructor if attributes are invalid" do
    put :update, 'id'         => @instructor.to_param,
                 'instructor' =>
                   { 'person_attributes'  =>
                       { 'id'     => @instructor.person.id,
                         'email'  => 'foo' },
                     'employed_from'      => '2013-09-01' }
    assert_response :success
    assert_equal 1, assigns(:instructor).errors.count
  end

  test "should destroy instructor" do
    assert_difference('Instructor.count', -1) do
      delete :destroy, 'id' => @instructor.to_param
    end

    assert_redirected_to instructors_path
  end
end
