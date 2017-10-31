Pod::Spec.new do |s|
  s.name             = 'ARKitRecorder'
  s.version          = '0.1.0'
  s.summary          = 'Simple video recorder for ARKit.'

  s.description      = <<-DESC
Simple video recorder for ARKit.
Real Time record, Aspect ratio and timestamp are perfect.
                       DESC

  s.homepage         = 'https://github.com/noppefoxwolf/ARKitRecorder'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '🦊Tomoya Hirano' => 'noppelabs@gmail.com' }
  s.source           = { :git => 'https://github.com/noppefoxwolf/ARKitRecorder.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/noppefoxwolf'
  s.ios.deployment_target = '11.0'
  s.source_files = 'ARKitRecorder/Classes/**/*'
end
