Pod::Spec.new do |s|
  s.name         = "OctoKit"
  s.version      = "0.5"
  s.summary      = "GitHub API client for Objective-C."
 
  s.homepage     = "https://github.com/octokit/octokit.objc"
  s.license      = 'MIT'
  s.author       = { "GitHub" => "support@github.com" }
 
  s.source       = { :git => "https://github.com/octokit/octokit.objc.git", :commit => "59dc8b6ad75859fe798e8721ad3d74ef5f34b65b" }
  s.source_files = 'OctoKit'
 
  s.ios.deployment_target = "5.0"
  s.osx.deployment_target = "10.7"
 
  s.dependency   "AFNetworking", "~> 1.3.3"
  s.dependency   "ISO8601DateFormatter", "~> 0.7.0"
  s.dependency   "Mantle", "~> 1.3.1"
  s.dependency   "ReactiveCocoa", "~> 2.2.2"
end
