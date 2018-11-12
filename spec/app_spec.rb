RSpec.describe App do
  describe 'Safe Restart' do
    it 'responds with 200 to a GET' do
      get '/safe-restart'
      expect(last_response).to be_ok
    end
  end
end
