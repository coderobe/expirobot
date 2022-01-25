# frozen_string_literal: true

require File.join File.expand_path('lib', __dir__), 'expirobot/version'

Gem::Specification.new do |spec|
  spec.name          = 'expirobot'
  spec.version       = Expirobot::VERSION
  spec.authors       = ['Mara Robin Broda']
  spec.email         = ['software@coderobe.net']

  spec.summary       = 'A Matrix notifier for GPG key expiry'
  spec.description   = 'Sends GPG key expiration alerts as Matrix notifications'
  spec.homepage      = 'https://github.com/coderobe/expirobot'
  spec.license       = 'GPLv3'

  spec.extra_rdoc_files = %w[LICENSE README.md]
  spec.files         = Dir['lib/**/*'] + spec.extra_rdoc_files
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.6', '< 4'

  spec.add_dependency 'matrix_sdk', '~> 2.3'
  spec.add_dependency 'sinatra'
  spec.add_dependency 'webrick', '~> 1.7'
  spec.add_dependency 'rufus-scheduler'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'mocha'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'simplecov'
end
