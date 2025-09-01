# frozen_string_literal: true

# The base class for all service objects in the application.
# It provides a consistent public interface (`.call`) for executing services.
class ApplicationService
  def self.call(*args, **kwargs, &block)
    new(*args, **kwargs, &block).call
  end
end