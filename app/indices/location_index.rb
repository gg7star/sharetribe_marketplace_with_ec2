if APP_CONFIG.use_thinking_sphinx_indexing.to_s.casecmp("true") == 0
  ThinkingSphinx::Index.define :location, :with => :active_record, :delta => ThinkingSphinx::Deltas::DelayedDelta do

    #Thinking Sphinx will automatically add the SQL command SET NAMES utf8 as
    # part of the indexing process if the database connection settings have
    # encoding set to utf8. This is default in Rails but with Heroku, we need to
    # be explicit.
    set_property :utf8? => true

    # limit to open listings
    # where "listings.open = '1' AND listings.deleted = '0' AND (listings.valid_until IS NULL OR listings.valid_until > now())"

    # fields
    indexes google_address, :sortable => true
    # indexes latitude
    # indexes longitude
    # has geocoding.geocode(:id), :as => :geocode_id

    has 'RADIANS(latitude)', :as => :latitude, :type => :float
    has 'RADIANS(longitude)', :as => :longitude, :type => :float

    indexes address

    # attributes
    has id, :as => :location_id # id didn't work without :as aliasing
    has listing_id # id didn't work without :as aliasing
    has created_at, updated_at
    has community_id

    set_property :enable_star => true
    set_property :delta => true

    set_property :field_weights => {
      :google_address   => 8,
    }

  end
end
