class Conversation < ApplicationRecord

  has_many :messages, -> { order("id") }

  def display_name
    "#{self.created_at.to_s} (#{self.messages.count})"
  end

  def to_param
    self.uuid
  end

end
