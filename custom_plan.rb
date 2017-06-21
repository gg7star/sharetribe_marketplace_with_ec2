require 'zeus/rails'

require File.expand_path('../test/helper_modules', __FILE__)

class CustomPlan < Zeus::Rails

  # def my_custom_command
  #  # see https://github.com/burke/zeus/blob/master/docs/ruby/modifying.md
  # end

  def test_environment
    super

    # Clean database
    require 'database_cleaner'
    DatabaseCleaner.clean_with(:truncation)
  end

  def cucumber_environment
    require 'cucumber/rspec/disable_option_parser'
    require 'cucumber/cli/main'
    @cucumber_runtime = Cucumber::Runtime.new

    # Populate db with default data
    TestHelpers.load_default_test_data_to_db_before_suite
    TestHelpers.load_default_test_data_to_db_before_test

    # Ensure sphinx directories exist for the test environment
    ThinkingSphinx::Test.init

    # Stop Sphinx if it was already running
    ThinkingSphinx::Test.stop

    # Start Sphinx
    # With Zeus we don't care if it stays running afterwards. It's anyway restarted next time Zeus starts
    # And keeping it running makes running new tests much faster
    ThinkingSphinx::Test.start
  end

  def cucumber(argv=ARGV)
    cucumber_main = Cucumber::Cli::Main.new(argv.dup)
    had_failures = cucumber_main.execute!(@cucumber_runtime)
    exit_code = had_failures ? 1 : 0
    exit exit_code
  end
end

Zeus.plan = CustomPlan.new
