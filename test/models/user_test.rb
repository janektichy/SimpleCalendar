require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "email is required" do
    user = User.new(password: "password123", password_confirmation: "password123")

    assert_not user.valid?, "expected user without email to be invalid"
    assert_includes user.errors.attribute_names, :email
  end

  test "password must be at least eight characters" do
    user = User.new(email: "tester@example.com", password: "short", password_confirmation: "short")

    assert_not user.valid?, "expected short password to be rejected"
    assert_includes user.errors.attribute_names, :password
  end
end
