require 'rails_helper'

RSpec.describe Coupon, type: :model do
  it { is_expected.to validate_presence_of :name }
  it { is_expected.to validate_presence_of :code }
  it { is_expected.to validate_uniqueness_of(:code).case_insensitive }

  it { is_expected.to validate_presence_of :status }
  it { is_expected.to define_enum_for(:status).with_values({ active: 1, inactive: 2 }) }

  it { is_expected.to validate_presence_of :discount_value }
  it { is_expected.to validate_numericality_of(:discount_value).is_greater_than(0) }

  it { is_expected.to validate_presence_of :max_use }
  it { is_expected.to validate_numericality_of(:max_use).only_integer.is_greater_than_or_equal_to(0) }

  it { is_expected.to validate_presence_of :due_date }

  context "due_date:" do
    it "can't be a past date" do
      subject.due_date = 1.day.ago
      subject.valid?
      expect(subject.errors.keys).to include :due_date
    end

    it "can't be the current date" do
      subject.due_date = Time.zone.now
      subject.valid?
      expect(subject.errors.keys).to include :due_date
    end

    it "should be valid when the date is in the future" do
      subject.due_date = Time.zone.now + 1.hour
      subject.valid?
      expect(subject.errors.keys).to_not include :due_date
    end
  end

  it_behaves_like "paginatable concern", :coupon
end
