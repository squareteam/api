require File.expand_path '../../spec_helper.rb', __FILE__

describe 'Squareteam api' do
  it 'should say hello' do
    get '/'
    last_response.should be_ok
    last_response.should match(/^hello/i)
  end
end
