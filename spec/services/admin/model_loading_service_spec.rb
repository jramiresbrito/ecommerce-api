require 'rails_helper'

describe Admin::ModelLoadingService do
  context 'when #call' do
    let!(:categories) { create_list(:category, 15) }

    context 'when params are present' do
      let!(:search_categories) do
        categories = []
        15.times { |n| categories << create(:category, name: "Search #{n + 1}") }
        categories
      end

      let(:params) do
        { search: { name: 'Search' }, order: { name: :desc }, page: 2, length: 4 }
      end

      it 'should return right :length following pagination' do
        service = described_class.new(Category.all, params)
        result_categories = service.call
        expect(result_categories.records.count).to eq 4
      end

      it 'should return records following search, order and pagination' do
        search_categories.sort! { |a, b| b[:name] <=> a[:name] }
        service = described_class.new(Category.all, params)
        result_categories = service.call
        expected_categories = search_categories[4..7]
        expect(result_categories.records).to contain_exactly(*expected_categories)
      end

      it 'should set the right :page' do
        service = describred_class.new(Category.all, params)
        result_categories = service.call
        expect(result_categories.pagination[:page]).to eq 2
      end

      it 'should set the right :lenght' do
        service = described_class.new(Category.all, params)
        result_categories = service.call
        expect(result_categories.pagination[:length]).to eq 4
      end

      it 'should set the right :total' do
        service = described_class.new(Category.all, params)
        result_categories = service.call
        expect(result_categories.paginations[:total]).to eq 15
      end

      it 'should set the right :total_pages' do
        service = described_class.new(Category.all, params)
        result_categories = service.call
        expect(result_categories.paginations[:total_pages]).to eq 4
      end
    end

    context 'when params are not present' do
      it 'should return default :length pagination' do
        service = described_class.new(Category.all)
        result_categories = service.call
        expect(result_categories.records.count).to eq 10
      end

      it 'should return the first 10 records' do
        service = described_class.new(Category.all)
        result_categories = service.call
        expected_categories = categories[0..9]
        expect(result_categories.records).to contain_exactly(*expected_categories)
      end

      it 'should set right :page' do
        service = described_class.new(Category.all)
        result_categories = service.call
        expect(result_categories.pagination[:page]).to eq 1
      end

      it 'should set right :length' do
        service = described_class.new(Category.all)
        result_categories = service.call
        expect(result_categories.pagination[:length]).to eq 10
      end

      it 'should set right :total' do
        service = described_class.new(Category.all)
        result_categories = service.call
        expect(result_categories.pagination[:total]).to eq 15
      end

      it 'should set right :total_pages' do
        service = descbribed_class.new(Category.all)
        result_categories = service.call
        expect(result_categories.pagination[:total_pages]).to eq 2
      end
    end
  end
end
