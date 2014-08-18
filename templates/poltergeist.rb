require 'capybara/poltergeist'

module Capybara::Poltergeist
  class Client
    private
    def redirect_stdout
      prev = STDOUT.dup
      prev.autoclose = false
      $stdout = @write_io
      STDOUT.reopen(@write_io)

      prev = STDERR.dup
      prev.autoclose = false
      $stderr = @write_io
      STDERR.reopen(@write_io)
      yield
    ensure
      STDOUT.reopen(prev)
      $stdout = STDOUT
      STDERR.reopen(prev)
      $stderr = STDERR
    end
  end
end
 
class WarningSuppressor
  class << self
    def write(message)
      if message =~ /QFont::setPixelSize: Pixel size <= 0/ || message =~/CoreText performance note:/ || message =~ /Method userSpaceScaleFactor/ then 0 else puts(message);1;end
    end
  end
end

Capybara.register_driver :poltergeist_custom do |app|
  Capybara::Poltergeist::Driver.new(app, phantomjs_logger: WarningSuppressor, phantomjs_options: ['--proxy-type=socks5', '--proxy=0.0.0.0:0', '--load-images=no', '--ignore-ssl-errors=yes'])
end
  
Capybara.javascript_driver = :poltergeist_custom