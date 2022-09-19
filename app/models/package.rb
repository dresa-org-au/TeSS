class Package < ApplicationRecord
  include PublicActivity::Model
  include LogParameterChanges
  include Searchable
  include HasFriendlyId

  has_many :package_materials
  has_many :package_events
  has_many :materials, through: :package_materials
  has_many :events, through: :package_events

  #has_one :owner, foreign_key: "id", class_name: "User"
  belongs_to :user

  # Remove trailing and squeezes (:squish option) white spaces inside the string (before_validation):
  # e.g. "James     Bond  " => "James Bond"
  auto_strip_attributes :title, :description, :image_url, :squish => false

  validates :title, presence: true

  clean_array_fields(:keywords)
  update_suggestions(:keywords)

  has_image(placeholder: TeSS::Config.placeholder['package'])

  if TeSS::Config.solr_enabled
    # :nocov:
    searchable do
      # full text fields
      text :title
      text :description
      text :keywords
      # sort fields
      string :sort_title do
        title.downcase.gsub(/^(an?|the) /, '')
      end
      # other fields
      string :title
      string :keywords, :multiple => true

      integer :user_id
      boolean :public
      time :created_at
      time :updated_at
    end
    # :nocov:
  end

  #Overwrites a packages materials and events.
  #[] or nil will delete
  def update_resources_by_id(materials=[], events=[])
    self.update_attribute('materials', materials.uniq.collect{|materials| Material.find_by_id(materials)}.compact) if materials
    self.update_attribute('events', events.uniq.collect{|events| Event.find_by_id(events)}.compact) if events
  end

  def self.facet_fields
    %w( keywords )
  end

  def self.visible_by(user)
    if user && user.is_admin?
      all
    elsif user
      where("#{self.table_name}.public = ? OR #{self.table_name}.user_id = ?", true, user)
    else
      where(public: true)
    end
  end

  # implement methods to allow processing as resource
  def last_scraped
    return nil
  end

  def content_provider
    return nil
  end

  def scientific_topics
    return nil
  end


end
