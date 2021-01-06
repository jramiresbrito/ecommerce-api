require 'rails_helper'

RSpec.describe 'Admin V1 System Requirements as :admin', type: :request do
  let(:user) { create(:user) }

  context 'GET /system_requirements' do
    let(:url) { '/admin/v1/system_requirements' }
    let!(:system_requirements) { create_list(:system_requirement, 10) }
    before { get url, headers: auth_header(user) }

    it 'should return all systems requirements' do
      expect(json_body['system_requirements']).to contain_exactly(
        *system_requirements.as_json(except: %i[created_at updated_at])
      )
    end

    it 'should return success status' do
      expect(response).to have_http_status(:ok)
    end
  end

  context 'POST /system_requirements' do
    let(:url) { '/admin/v1/system_requirements' }

    context 'valid params' do
      let(:system_requirements_params) { { system_requirement: attributes_for(:system_requirement) }.to_json }
      it 'should add a new system requirement' do
        expect do
          post url, headers: auth_header(user), params: system_requirements_params
        end.to change(SystemRequirement, :count).by(1)
      end

      it 'should return the last added system requirement' do
        post url, headers: auth_header(user), params: system_requirements_params
        expected_system_requirement = SystemRequirement.last.as_json(except: %i[created_at updated_at])
        expect(json_body['system_requirement']).to eq expected_system_requirement
      end

      it 'should return success status' do
        post url, headers: auth_header(user), params: system_requirements_params
        expect(response).to have_http_status(:ok)
      end
    end

    context 'invalid params' do
      let(:system_requirements_invalid_params) do
        { system_requirement: attributes_for(:system_requirement, name: nil) }.to_json
      end

      it "shouldn't add a new system requirement" do
        expect do
          post url, headers: auth_header(user), params: system_requirements_invalid_params
        end.to_not change(SystemRequirement, :count)
      end

      it 'should return error messages' do
        post url, headers: auth_header(user), params: system_requirements_invalid_params
        expect(json_body['errors']['fields']).to have_key('name')
      end

      it 'should return unprocessable_entity - status code 422' do
        post url, headers: auth_header(user), params: system_requirements_invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  context 'PATCH /categories/:id' do
    let(:system_requirements) { create(:system_requirement) }
    let(:url) { "/admin/v1/system_requirements/#{system_requirements.id}" }

    context 'valid params' do
      let(:new_name) { 'My new System Requirements' }
      let(:system_requirements_params) { { system_requirement: { name: new_name } }.to_json }

      it 'should update a system requirements' do
        patch url, headers: auth_header(user), params: system_requirements_params
        system_requirements.reload
        expect(system_requirements.name).to eq new_name
      end

      it 'should return the updated system requirements' do
        patch url, headers: auth_header(user), params: system_requirements_params
        system_requirements.reload
        expected_system_requirements = system_requirements.as_json(except: %i[created_at updated_at])
        expect(json_body['system_requirement']).to eq expected_system_requirements
      end

      it 'should return success status' do
        patch url, headers: auth_header(user), params: system_requirements_params
        expect(response).to have_http_status(:ok)
      end
    end

    context 'invalid params' do
      let(:system_requirements_invalid_params) do
        { system_requirement: attributes_for(:system_requirement, name: nil) }.to_json
      end

      it "shouldn't update a system requirement" do
        old_name = system_requirements.name
        patch url, headers: auth_header(user), params: system_requirements_invalid_params
        system_requirements.reload
        expect(system_requirements.name).to eq old_name
      end

      it 'should return error messages' do
        patch url, headers: auth_header(user), params: system_requirements_invalid_params
        expect(json_body['errors']['fields']).to have_key('name')
      end

      it 'should return unprocessable_entity - status code 422' do
        patch url, headers: auth_header(user), params: system_requirements_invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  context 'DELETE /categories/:id' do
    let!(:system_requirements) { create(:system_requirement) }
    let(:url) { "/admin/v1/system_requirements/#{system_requirements.id}" }

    context 'without an associated game' do
      it 'should remove a system requirements' do
        expect do
          delete url, headers: auth_header(user)
        end.to change(SystemRequirement, :count).by(-1)
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

    context 'with an associated game' do
      before(:each) do
        create(:game, system_requirement: system_requirements)
      end

      it "shouldn't remove the system requirements" do
        expect do
          delete url, headers: auth_header(user)
        end.to_not change(SystemRequirement, :count)
      end

      it 'should return error on :base key' do
        delete url, headers: auth_header(user)
        expect(json_body['errors']['fields']).to have_key('base')
      end

      it 'should return unprocessable_entity status' do
        delete url, headers: auth_header(user)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
