RSpec.describe 'POST /api/admin/articles', type: :request do
  let(:publisher)  { create(:publisher)}
  let(:publisher_credentials) { publisher.create_new_auth_token }
  let!(:publisher_headers) { { HTTP_ACCEPT: 'application/json' }.merge!(publisher_credentials) }
  let!(:article) { create(:article)}
  let!(:published_article) {create(:article, published: true, publisher: publisher)}

  describe 'Successfully publishes article' do
    before do
      patch "/api/v1/admin/articles/#{article.id}",
      params: {
          "article[published]": true
      },
      headers: publisher_headers
    end
    
    it 'returns a 200 response status' do
      expect(response).to have_http_status 200
    end
  end

  describe 'unsuccessfully with' do
    describe 'non logged in user' do
      let!(:non_authorized_headers) { { HTTP_ACCEPT: 'application/json' } }
      before do
        patch "/api/v1/admin/articles/#{article.id}",
        params: {
            "article[published]": true
        },
        headers: non_authorized_headers
      end
      
      it 'returns a 401 response status' do
        expect(response).to have_http_status 401
      end

      it 'returns error message' do
        expect(response_json["errors"][0]).to eq "You need to sign in or sign up before continuing."
      end
    end

    describe 'user that is not a publisher' do
      let(:journalist) { create(:user, role: 'journalist')}
      let(:journalist_credentials) { journalist.create_new_auth_token }
      let!(:journalist_headers) { { HTTP_ACCEPT: 'application/json' }.merge!(journalist_credentials) }
    
      before do
        patch "/api/v1/admin/articles/#{article.id}",
        params: {
            "article[published]": true
        },
        headers: journalist_headers
      end
  
      it 'returns a 404 response status' do
        expect(response).to have_http_status 404
      end

      it 'returns error message' do
        expect(response_json["error"]).to eq "Not authorized!"
      end
    end
  end

  describe 'can unpublish previously published article' do
    before do
      patch "/api/v1/admin/articles/#{published_article.id}",
      params: {
          "article[published]": false
      },
      headers: publisher_headers
    end

    it 'returns 200' do
      expect(response).to have_http_status 200
    end
    
    it 'has no publisher' do
      expect(published_article.reload.publisher).to eq nil
    end
  end
end