require 'rails_helper'

RSpec.describe Admin::ProductSavingService, type: :model do
  context 'when #call' do
    context 'sending loaded product' do
      let!(:new_categories) { create_list(:category, 2) }
      let!(:old_categories) { create_list(:category, 2) }
      let!(:product) { create(:product, categories: old_categories) }

      context 'with valid params' do
        let!(:game) { product.productable }
        let(:params) do
          { name: 'New product', category_ids: new_categories.map(&:id),
            productable_attributes: { developer: 'New company' } }
        end

        it 'should update the product' do
          service = described_class.new(params, product)
          service.call
          product.reload
          expect(product.name).to eq 'New product'
        end

        it 'should update :productable' do
          service = described_class.new(params, product)
          service.call
          game.reload
          expect(game.developer).to eq 'New company'
        end

        it 'should update to new categories' do
          service = described_class.new(params, product)
          service.call
          product.reload
          expect(product.categories.ids).to contain_exactly(*new_categories.map(&:id))
        end
      end

      context 'with invalid :product params' do
        let(:product_params) { attributes_for(:product, name: '') }

        it 'should raise NotSavedProductError' do
          expect do
            service = described_class.new(product_params, product)
            service.call
          end.to raise_error(Admin::ProductSavingService::NotSavedProductError)
        end

        it 'should set validation :errors' do
          service = error_proof_call(product_params, product)
          expect(service.errors).to have_key(:name)
        end

        it "shouldn't update :product" do
          expect do
            error_proof_call(product_params, product)
            product.reload
          end.to_not change(product, :name)
        end

        it 'should keep the old categories' do
          service = error_proof_call(product_params, product)
          product.reload
          expect(product.categories.ids).to contain_exactly(*old_categories.map(&:id))
        end
      end

      context 'with invalid :productable params' do
        let(:game_params) { { productable_attributes: attributes_for(:game, developer: '') } }

        it 'should raise NotSavedProductError' do
          expect do
            service = described_class.new(game_params, product)
            service.call
          end.to raise_error(Admin::ProductSavingService::NotSavedProductError)
        end

        it 'should set validation :errors' do
          service = error_proof_call(game_params, product)
          expect(service.errors).to have_key(:developer)
        end

        it "shouldn't update :productable" do
          expect do
            error_proof_call(game_params, product)
            product.productable.reload
          end.to_not change(product.productable, :developer)
        end

        it 'should keep the old categories' do
          service = error_proof_call(game_params, product)
          product.reload
          expect(product.categories.ids).to contain_exactly(*old_categories.map(&:id))
        end
      end
    end

    context 'without loaded product' do
      let!(:system_requirement) { create(:system_requirement) }

      context 'with valid params' do
        let!(:categories) { create_list(:category, 2) }
        let(:game_params) { attributes_for(:game, system_requirement_id: system_requirement.id) }
        let(:product_params) { attributes_for(:product, productable: 'game') }
        let(:params) do
          product_params.merge(category_ids: categories.map(&:id),
                               productable_attributes: game_params)
        end

        it 'should create a new product' do
          expect do
            service = described_class.new(params)
            service.call
          end.to change(Product, :count).by(1)
        end

        it 'should create :productable' do
          expect do
            service = described_class.new(params)
            service.call
          end.to change(Game, :count).by(1)
        end

        it 'should set the created product' do
          service = described_class.new(params)
          service.call
          expect(service.product).to be_kind_of(Product)
        end

        it 'should set the categories' do
          service = described_class.new(params)
          service.call
          expect(service.product.categories.ids).to contain_exactly(*categories.map(&:id))
        end
      end

      context 'with invalid :product params' do
        let(:product_params) { attributes_for(:product, name: '', productable: 'game') }
        let(:game_params) { attributes_for(:game, system_requirement_id: system_requirement.id) }
        let(:params) { product_params.merge(productable_attributes: game_params) }

        it 'should raise NotSavedProductError' do
          expect do
            service = described_class.new(params)
            service.call
          end.to raise_error(Admin::ProductSavingService::NotSavedProductError)
        end

        it 'should set validation :errors' do
          service = error_proof_call(params)
          expect(service.errors).to have_key(:name)
        end

        it "shouldn't create a new product" do
          expect do
            error_proof_call(params)
          end.to_not change(Product, :count)
        end

        it "shouldn't create a :productable" do
          expect do
            error_proof_call(params)
          end.to_not change(Game, :count)
        end

        it "shouldn't create a category association" do
          expect do
            error_proof_call(params)
          end.to_not change(ProductCategory, :count)
        end
      end

      context 'with invalid :productable params' do
        let(:product_params) { attributes_for(:product, productable: 'Game') }
        let(:game_params) { attributes_for(:game, developer: '', system_requirement_id: system_requirement.id) }
        let(:params) { product_params.merge(productable_attributes: game_params) }

        it 'should raise NotSavedProductError' do
          expect do
            service = described_class.new(params)
            service.call
          end.to raise_error(Admin::ProductSavingService::NotSavedProductError)
        end

        it 'should set validation :errors' do
          service = error_proof_call(params)
          expect(service.errors).to have_key(:developer)
        end

        it "shouldn't create a new product" do
          expect do
            error_proof_call(params)
          end.to_not change(Product, :count)
        end

        it "shouldn't create a :productable" do
          expect do
            error_proof_call(params)
          end.to_not change(Game, :count)
        end

        it "shouldn't create a category association" do
          expect do
            error_proof_call(params)
          end.to_not change(ProductCategory, :count)
        end
      end

      context 'without :productable params' do
        let(:product_params) { attributes_for(:product) }

        it 'should raises NotSavedProductError' do
          expect do
            service = described_class.new(product_params)
            service.call
          end.to raise_error(Admin::ProductSavingService::NotSavedProductError)
        end

        it "shouldn't create a new product" do
          expect do
            error_proof_call(product_params)
          end.to_not change(Product, :count)
        end

        it 'should set validation :errors' do
          service = error_proof_call(product_params)
          expect(service.errors).to have_key(:productable)
        end

        it "shouldn't create a :productable" do
          expect do
            error_proof_call(product_params)
          end.to_not change(Game, :count)
        end

        it "shouldn't create a category association" do
          expect do
            error_proof_call(product_params)
          end.to_not change(ProductCategory, :count)
        end
      end
    end
  end
end

def error_proof_call(*params)
  service = described_class.new(*params)
  begin
    service.call
  # rubocop:disable Lint/SuppressedException, Lint/UselessAssignment
  rescue StandardError => e
  end
  service
end
