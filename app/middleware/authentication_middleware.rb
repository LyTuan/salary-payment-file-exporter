class AuthenticationMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)

    # Only apply this middleware to paths that require authentication
    return @app.call(env) unless request.path.start_with?('/payments')

    auth_header = request.get_header('HTTP_AUTHORIZATION')
    unless auth_header&.start_with?('Bearer ')
      return [401, { 'Content-Type' => 'application/json' }, [{ error: 'Authorization token is missing or invalid' }.to_json]]
    end

    token = auth_header.split(' ').last
    company = Company.find_by(api_key: token)
    if company
      env['current_company'] = company
      @app.call(env)
    else
      [401, { 'Content-Type' => 'application/json' }, [{ error: 'Invalid API Key' }.to_json]]
    end
  end
end