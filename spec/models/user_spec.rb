# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  snum            :string(255)      not null
#  name            :string(255)      not null
#  depart          :integer          default(0), not null
#  entrance        :integer          default(2012), not null
#  category        :integer          default(0), not null
#  is_active       :boolean          default(TRUE), not null
#  password_digest :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#

require 'rails_helper'

RSpec.describe User, type: :model do
end

