Gem::Specification.new do |s|
  s.name        = "openproject-gitea_integration"
  s.version     = '1.0.0'
  s.authors     = "OpenProject GmbH"
  s.email       = "info@openproject.com"
  # TODO: Update documentation
  s.homepage    = "https://www.openproject.org/docs/system-admin-guide/integrations/gitea-integration/"
  s.summary     = 'OpenProject gitea Integration'
  s.description = 'Integrates OpenProject and gitea for a better workflow'
  s.license     = 'GPLv3'

  s.files = Dir["{app,config,db,frontend,lib}/**/*"] + %w(README.md)

  s.add_dependency "openproject-webhooks"
  s.metadata['rubygems_mfa_required'] = 'true'
end
