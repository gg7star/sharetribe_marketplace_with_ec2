Given /^feature flag "([^"]*)" is enabled$/ do |arg1|
  Community.all.each { |c|
    FeatureFlagService::API::Api.features.enable(community_id: c.id, features: [arg1.to_sym])
  }
end

When 'the system processes jobs' do
  process_jobs
end

When 'the system moves all future jobs to immediate' do
  Delayed::Job.update_all(run_at: Time.now)
end

When /^I print "(.+)"$/ do |text|
  puts text
end

When /^(?:|I )click "([^"]*)"(?: within "([^"]*)")?$/ do |css_selector, scope_selector|
  with_scope(scope_selector) do
    find(css_selector).click
  end
end

Then /^I should see selector "([^"]*)"(?: within "([^"]*)")?$/ do |css_selector, scope_selector|
  with_scope(scope_selector) do
    expect(page).to have_selector(css_selector)
  end
end

Then /^(?:|I )should not see selector "([^"]*)"?$/ do |selector|
  expect(page.has_css?(selector)).to eq(false)
end

When /^(?:|I )attach a valid image file to "([^"]*)"(?: within "([^"]*)")?$/ do |field, selector|
  @latest_uploaded_image = 'Australian_painted_lady.jpg'
  attach_image(@latest_uploaded_image, field, selector)
end

def attach_image(filename, field, selector)
  path = File.join(Rails.root, 'spec', 'fixtures', filename)
  with_scope(selector) do
    attach_file(field, path, visible: false)
  end
end
