class Post < ApplicationRecord
    has_many :details, dependent: :destroy
    validates :title, presence: true
end
