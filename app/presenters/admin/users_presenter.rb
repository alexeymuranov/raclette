# class Admin::UsersPresenter < ActivePresenter::Base  # NOTE:experimental, not used yet
#   presents :user => Admin::User
# end

class Admin::UsersPresenter < Admin::User
end
