# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'git_deploy_timer/version'

Gem::Specification.new do |spec|
  spec.name          = 'git_deploy_timer'
  spec.version       = GitDeployTimer::VERSION
  spec.authors       = ['Lee Coomber']
  spec.email         = ['github.com@coomber.org']

  spec.summary       = 'Produce times from commit to deploy based on tags'
  spec.description   = 'Produce times from commit to various deployment environments by examining tags.'
  spec.homepage      = 'https://github.com/ljcoomber/git_deploy_timer'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.8'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec'

  spec.add_runtime_dependency 'git_deploy_timer'
end
