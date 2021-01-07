require 'rails_helper'

RSpec.describe 'Admin V1 Categories as :admin', type: :request do
  let(:user) { create(:user) }

  context 'GET /coupons' do
    let(:url) { '/admin/v1/coupons' }
    let!(:coupons) { create_list(:coupon, 5) }

    before { get url, headers: auth_header(user) }

    it 'should return all coupons' do
      expect(json_body['coupons']).to contain_exactly(*coupons.as_json(except: %i[created_at
                                                                                  updated_at]))
    end

    it 'should return success status' do
      expect(response).to have_http_status(:ok)
    end
  end

  context 'POST /coupons' do
    let(:url) { '/admin/v1/coupons' }

    context 'valid params' do
      let(:coupon_params) { { coupon: attributes_for(:coupon) }.to_json }

      it 'should add a new coupon' do
        expect do
          post url, headers: auth_header(user), params: coupon_params
        end.to change(Coupon, :count).by(1)
      end

      it 'should return the last added coupon' do
        post url, headers: auth_header(user), params: coupon_params
        expected_coupon = Coupon.last.as_json(except: %i[created_at updated_at])
        expect(json_body['coupon']).to eq expected_coupon
      end

      it 'should return success status' do
        post url, headers: auth_header(user), params: coupon_params
        expect(response).to have_http_status(:ok)
      end
    end

    context 'invalid params' do
      let(:coupon_invalid_params) do
        { coupon: attributes_for(:coupon, name: nil) }.to_json
      end

      it "shouldn't add a new coupon" do
        expect do
          post url, headers: auth_header(user), params: coupon_invalid_params
        end.to_not change(Coupon, :count)
      end

      it 'should return error messages' do
        post url, headers: auth_header(user), params: coupon_invalid_params
        expect(json_body['errors']['fields']).to have_key('name')
      end

      it 'should return unprocessable_entity - status code 422' do
        post url, headers: auth_header(user), params: coupon_invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'invalid due dates' do
      context ':due_date = today' do
        let(:coupon_invalid_due_date_params) do
          { coupon: attributes_for(:coupon, due_date: Date.today) }.to_json
        end

        it "shouldn't add a new coupon" do
          expect do
            post url, headers: auth_header(user), params: coupon_invalid_due_date_params
          end.to_not change(Coupon, :count)
        end

        it 'should return error messages' do
          post url, headers: auth_header(user), params: coupon_invalid_due_date_params
          expect(json_body['errors']['fields']).to have_key('due_date')
        end

        it 'should return unprocessable_entity - status code 422' do
          post url, headers: auth_header(user), params: coupon_invalid_due_date_params
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context ':due_date = yesterday' do
        let(:coupon_invalid_due_date_params) do
          { coupon: attributes_for(:coupon, due_date: Date.yesterday) }.to_json
        end

        it "shouldn't add a new coupon" do
          expect do
            post url, headers: auth_header(user), params: coupon_invalid_due_date_params
          end.to_not change(Coupon, :count)
        end

        it 'should return error messages' do
          post url, headers: auth_header(user), params: coupon_invalid_due_date_params
          expect(json_body['errors']['fields']).to have_key('due_date')
        end

        it 'should return unprocessable_entity - status code 422' do
          post url, headers: auth_header(user), params: coupon_invalid_due_date_params
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end

  context 'PATCH /coupons' do
    let(:coupon) { create(:coupon) }
    let(:url) { "/admin/v1/coupons/#{coupon.id}" }

    context 'valid params' do
      due_date = Date.tomorrow
      let(:coupon_valid_params) do
        { coupon: attributes_for(:coupon, due_date: due_date) }.to_json
      end

      it 'should update a coupon' do
        patch url, headers: auth_header(user), params: coupon_valid_params
        coupon.reload
        expect(coupon.due_date).to eq due_date
      end

      it 'should return the updated coupon' do
        patch url, headers: auth_header(user), params: coupon_valid_params
        coupon.reload
        expected_coupon = coupon.as_json(except: %i[created_at updated_at])
        expect(json_body['coupon']).to eq expected_coupon
      end

      it 'should return success status' do
        patch url, headers: auth_header(user), params: coupon_valid_params
        expect(response).to have_http_status(:ok)
      end
    end

    context 'invalid params' do
      let(:coupon_invalid_params) do
        { coupon: attributes_for(:coupon, due_date: 1.day.ago) }.to_json
      end

      it "shouldn't update a coupon" do
        old_due_date = coupon.due_date.to_s
        patch url, headers: auth_header(user), params: coupon_invalid_params
        coupon.reload
        expect(coupon.due_date.to_s).to eq old_due_date
      end

      it 'should return errors messages' do
        patch url, headers: auth_header(user), params: coupon_invalid_params
        expect(json_body['errors']['fields']).to have_key('due_date')
      end

      it 'should return unprocessable_entity - status code 422' do
        patch url, headers: auth_header(user), params: coupon_invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  context 'DELETE /coupons' do
    let!(:coupon) { create(:coupon) }
    let(:url) { "/admin/v1/coupons/#{coupon.id}" }

    it 'should remove a coupon' do
      expect do
        delete url, headers: auth_header(user)
      end.to change(Coupon, :count).by(-1)
    end

    it 'should return success - status code 204' do
      delete url, headers: auth_header(user)
      expect(response).to have_http_status(:no_content)
    end

    it "shouldn't return any body content" do
      delete url, headers: auth_header(user)
      expect(json_body).to_not be_present
    end
  end
end
