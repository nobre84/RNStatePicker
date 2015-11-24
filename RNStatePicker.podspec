Pod::Spec.new do |s|

  s.name         = "RNStatePicker"
  s.version      = "0.0.4"
  s.summary      = "State picker table view controller for iOS 7+"
  s.description  = <<-DESC
Table view controller with searchable list of states with completion block and dynamic fonts support.
                   DESC

  s.license      = 'MIT'
  s.author       = { "Rafael Nobre" => "nobre84@gmail.com" }
  s.homepage       = "https://github.com/nobre84/RNStatePicker"
  s.platform     = :ios, '7.0'
  s.source       = { :git => "https://github.com/nobre84/RNStatePicker.git", :tag => s.version.to_s }
  s.source_files  = 'StatePicker', 'StatePicker/**/*.{h,m}'
  s.resource  = "StatePicker/*.{xcassets,plist}"
  s.preserve_paths = "StatePicker/StateFlags.xcassets/*"
  s.requires_arc = true

end
