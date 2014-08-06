# API controller to search
class SearchController < Sinatra::Base
  before do
    content_type 'application/json'
  end

  # Search users by terms
  # Terms are delimited by '+'. And acceptable terms can be of type:
  #  - simple strings which will be matched against :name or :email
  #  - scoped string (containing a ':') to nest the search on a parent object
  #
  # E.g.1: GET /search/users/john+doe will search for all users which name or email matches either 'john' or 'doe'
  # E.g.2: GET /search/users/john+organization:swcc will search for an organization which :name matches 'swcc' and then search for users within this organization which :name or :email matches 'john'
  #
  # _Warning_ query parameter is limited to 100 chars
  get '/search/users/:terms' do
    return if params[:terms].blank? || params[:terms].size > 100

    terms = params[:terms].split(/\+/)
    nested = []
    search_terms = []
    results = []

    # Seperate terms to match
    # from
    # Scopes (words that include a ':')
    terms.each do |term|
      unless term.include? ':'
        search_terms << User.arel_table[:name].matches("%#{term}%")
        search_terms << User.arel_table[:email].matches("%#{term}%")
        next
      end

      sep = term.split(/:/)
      begin
        nested << sep.first.singularize.classify.constantize.send(:search, sep.second, true)
      rescue NameError
        # scope doesn't exist
      end
    end

    if nested.empty?
      results << User
    else
      nested.each do |parent|
        results += parent.send(:users)
      end
    end

    results.map do |result|
      result.where(search_terms.reduce(:or)).limit(100)
    end.flatten.as_json(UsersController.read_scope).to_json
  end
end
