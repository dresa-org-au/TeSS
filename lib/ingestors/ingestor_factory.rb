require 'ingestors/ingestor_event_csv'
require 'ingestors/ingestor_material_csv'
require 'ingestors/ingestor_material_rest'

class IngestorFactory
  @@methods = ['csv', 'rest',]
  @@resources = ['event', 'material',]

  def self.get_ingestor (method, resource)
    if is_method_valid?(method) and is_resource_valid?(resource)
      case [method, resource]
      when ['csv', 'event']
        IngestorEventCsv.new
      when ['csv', 'material']
        IngestorMaterialCsv.new
      when ['rest', 'material']
        IngestorMaterialRest.new
      else
        raise "Ingestor not yet implemented for method[#{method}] and resource[#{resource}]"
      end
    else
      raise "Invalid method[#{method}] or resource[#{resource}]"
    end
  end

  def self.is_method_valid? (method)
    @@methods.include? method
  end

  def self.is_resource_valid? (resource)
    @@resources.include? resource
  end

end
