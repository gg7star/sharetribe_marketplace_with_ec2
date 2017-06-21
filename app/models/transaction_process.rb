# == Schema Information
#
# Table name: transaction_processes
#
#  id               :integer          not null, primary key
#  community_id     :integer
#  process          :string(32)       not null
#  author_is_seller :boolean
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_transaction_process_on_community_id  (community_id)
#

class TransactionProcess < ApplicationRecord

  def process
    read_attribute(:process).to_sym
  end
end
