require 'rails_helper'

RSpec.describe AdminActivityWorker, type: :worker do
  subject { AdminActivityWorker.perform_async(event, properties) }

  let(:event) { 'whatever' }
  let(:properties) do
    {
      'oki' => 'lol',
    }
  end

  it "creates AdminActivity model with valid attributes" do
    expect {
      subject
    }.to change{AdminActivity.count}.by(1)
  end
end
