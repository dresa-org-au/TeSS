require 'ingestors/ingestor'

class IngestorMaterial < Ingestor

  @materials = Array.new

  def initialize
    super
    @materials = []
  end

  def add_material (material)
    @materials << material if !material.nil?
  end

  def write (user, provider)
    processed = 0
    updated = 0
    added = 0
    messages = []

    @materials.each do |material|
      processed += 1

      # check for matched materials
      matched_materials = Material.where(title: material.title,
                                         url: material.url,
                                         content_provider: provider)

      if matched_materials.nil? or matched_materials.first.nil?
        # set ingestion parameters and save new event
        material.user = user
        material.content_provider = provider
        material = set_field_defaults material
        material.last_scraped = DateTime.now
        material.scraper_record = true

        # check validity
        if material.valid?
          material.save!
          added += 1
        else
          messages << "Material failed validation: #{material.title}"
          material.errors.full_messages.each do |m|
            messages << "Error: " + m
          end
        end

      else
        # update and save matched material
        matched = overwrite_fields matched_materials.first, material
        matched = set_field_defaults matched
        matched.last_scraped = DateTime.now
        matched.scraper_record = true

        # check validity
        if matched.valid?
          matched.save!
          updated += 1
        else
          messages << "Material failed validation: #{matched.title}"
          matched.errors.full_messages.each do |m|
            messages << "Error: " + m
          end
        end
      end
    end

    # finished
    messages << "materials added[#{added}] updated[#{updated}] rejected[#{processed - (added + updated)}]"
    return processed, added, updated, messages
  end

  def set_field_defaults (material)
    # contact
    if material.contact.nil? or material.contact.blank?
      material.contact = material.content_provider.contact
    end
    return material
  end

  def overwrite_fields (old_material, new_material)
    # overwrite unlocked attributes
    # [title, url, provider] not changed as they are used for matching
    old_material.description = new_material.description unless old_material.field_locked? :description
    old_material.keywords = new_material.keywords unless old_material.field_locked? :keywords
    old_material.contact = new_material.contact unless old_material.field_locked? :contact
    old_material.licence = new_material.licence unless old_material.field_locked? :licence
    old_material.status = new_material.status unless old_material.field_locked? :status
    old_material.authors = new_material.authors unless old_material.field_locked? :authors
    old_material.contributors = new_material.contributors unless old_material.field_locked? :contributors
    old_material.doi = new_material.doi unless old_material.field_locked? :doi

    # return
    return old_material
  end

end