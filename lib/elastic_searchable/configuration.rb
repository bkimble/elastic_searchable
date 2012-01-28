require "rails"
require "active_model/railtie"

module ElasticSearchable  
  class << self
    attr_accessor :config
    
    def setup(config, environment, options={})
      self.config = config
      include_orm_extensions
    end
    
    def include_orm_extensions
      case config['orm']
        when 'mongo_mapper' then require 'elastic_searchable/mongo_mapper_extensions'
        else require 'elastic_searchable/active_record_extensions'
      end
    end
  end
  

  class Railtie < Rails::Railtie
    config.elastic_search = ActiveSupport::OrderedOptions.new

    initializer "elastic_search.set_configs" do |app|
      ActiveSupport.on_load(:elastic_search) do
        app.config.elastic_search.each do |k,v|
          send "#{k}=", v
        end
      end
    end

    initializer "elastic_search.initialize" do |app|
      config_file = Rails.root.join('config/elastic_search.yml')
      if config_file.file?
        config = YAML.load(ERB.new(config_file.read).result)
        ElasticSearchable.setup(config, Rails.env, :logger => Rails.logger)
      end
    end
  end
end