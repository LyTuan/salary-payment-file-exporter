# frozen_string_literal: true

class AuthenticationMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)

    # Only apply this middleware to paths that require authentication
    return @app.call(env) unless request.path.start_with?('/payments')

    client_key = request.get_header('HTTP_X_CLIENT_KEY')
    auth_header = request.get_header('HTTP_AUTHORIZATION')
    puts 'client_key '
    puts client_key
    puts  'auth_header '
    puts auth_header
    unless client_key && auth_header&.start_with?('Bearer ')
      return [401, { 'Content-Type' => 'application/json' }, [{ error: 'X-Client-Key and Authorization headers are required' }.to_json]]
    end

    secret_key = auth_header.split.last
    company = Company.find_by(client_key: client_key)

    # Use secure_compare to prevent timing attacks
    if company && ActiveSupport::SecurityUtils.secure_compare(company.secret_key, secret_key)
      env['current_company'] = company
      @app.call(env)
    else
      [401, { 'Content-Type' => 'application/json' }, [{ error: 'Invalid Client-Key or Secret-Key' }.to_json]]
    end
  end
end
