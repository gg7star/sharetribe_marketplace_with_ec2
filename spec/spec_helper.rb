require 'spec_utils'
require 'rubygems'

#uncomment the following line to use spork with the debugger
#require 'spork/ext/ruby-debug'

prefork = lambda {
# Loading more in this block will cause your tests to run faster. However,
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.

  # A script to test if spec_helper is loaded multiple times (which would slow down the tests)
  if $LOADED_FEATURES.grep(/spec\/spec_helper\.rb/).any?
    begin
      raise "foo"
    rescue => e
      puts <<-MSG
    ===================================================
    It looks like spec_helper.rb has been loaded
    multiple times. Normalize the require to:

      require "spec/spec_helper"

    Things like File.join and File.expand_path will
    cause it to be loaded multiple times.

    Loaded this time from:

      #{e.backtrace.join("\n    ")}
    ===================================================
      MSG
    end
  end

  # This file is copied to ~/spec when you run 'ruby script/generate rspec'
  # from the project root directory.
  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  require "email_spec"

  # Requires supporting files with custom matchers and macros, etc,
  # in ./support/ and its subdirectories.
  Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

  # Checks for pending migrations before tests are run.
  # If you are not using ActiveRecord, you can remove this line.
  ActiveRecord::Migration.maintain_test_schema!

  RSpec.configure do |config|
    # == Mock Framework
    #
    # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
    #
    # config.mock_with :mocha
    # config.mock_with :flexmock
    # config.mock_with :rr
    config.mock_with :rspec
    config.include Devise::Test::ControllerHelpers, type: :controller
    config.include SpecUtils

    Timecop.safe_mode = true

    config.filter_run focus: true
    config.run_all_when_everything_filtered = true
  end

  def uploaded_file(filename, content_type)
    t = Tempfile.new(filename)
    t.binmode
    path = "#{File.dirname(__FILE__)}/fixtures/#{filename}"
    FileUtils.copy_file(path, t.path)
    (class << t; self; end).class_eval do
      alias local_path path
      define_method(:original_filename) {filename}
      define_method(:content_type) {content_type}
    end
    return t
  end

}

each_run = lambda {
  # This code will be run each time you run your specs.
  # Require step definitions
  Dir["#{File.dirname(__FILE__)}/step_definitions/**/*.rb"].each {|f| require f}
  Rails.cache.clear
}

prefork.call

if defined?(Zeus)
  $each_run = each_run
  module ZeusWoTest
    def after_fork
      super
      $each_run.call
    end
  end
  class << Zeus.plan
    include ZeusWoTest  
  end
else
  each_run.call
end

def create_admin_for(community)
  person = FactoryGirl.create(:person, community_id: community.id)
  members_count = community.community_memberships.count
  admins_length = community.admins.length
  membership = CommunityMembership.create(community: community, person: person) do |membership|
    membership.admin = true
  end
  community.reload
  expect(community.members.count).to eql(members_count + 1)
  expect(community.admins.length).to eql(admins_length + 1)
  return person
end
