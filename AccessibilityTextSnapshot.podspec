Pod::Spec.new do |s|
  s.name             = "AccessibilityTextSnapshot"
  s.version          = "0.1" 
  s.summary          = "Textual snapshot tests for your app's VoiceOver support"
  s.homepage         = "https://github.com/minddistrict/ios-accessibility-text-snapshot"
  s.license          = 'MIT'
  s.author           = { "Minddistrict" => "info@minddistrict.com" }
  s.source           = { :git => "git@github.com:minddistrict/ios-accessibility-text-snapshot.git", :tag => s.version.to_s }

  s.platform         = :ios, '12.0'
  s.swift_version    = '5'
  s.requires_arc     = true

  s.source_files = ['Sources/Accessibility.testing.swift']
  s.dependency 'SnapshotTesting'
end
