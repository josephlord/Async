Pod::Spec.new do |spec|
  spec.name         = 'AsyncLegacy'
  spec.version      = '0.1.0'
  spec.license      = { :type => 'MIT' }
  spec.homepage     = 'https://github.com/josephlord/Async.legacy'
  spec.authors      = { 'Joseph Lord' => 'joseph@human-friendly.com' }
  spec.social_media_url = 'https://twitter.com/jl_hfl'
  spec.summary      = 'Swift Syntactic Sugar for Grand Central Dispatch'
  spec.source       = { :git => 'https://github.com/josephlord/Async.legacy.git', :tag => 'v0.1.0' }
  spec.source_files = 'AsyncLegacy.swift'
  spec.ios.deployment_target = "7.0"
	spec.osx.deployment_target = "10.9"
end