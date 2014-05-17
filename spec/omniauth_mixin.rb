module OmniauthMixin
  def mock_auth_hash
    OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(
      provider: 'github',
      uid: 1111,
      info: { email: 'john@external.com', name: 'John' },
      credentials: { token: 'mock_token' }
    )
  end
end