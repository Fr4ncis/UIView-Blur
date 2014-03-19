Pod::Spec.new do |s|
  s.name         = 'UIViewBlur'
  s.version      = '0.0.1'
  s.license      =  {:type => 'MIT', :file => 'LICENSE'}
  s.homepage     = 'www.fr4ncis.net'
  s.authors      = {'Francesco Mattia' => 'francesco.mattia@gmail.com'}
  s.summary      = 'Category on UIView to blur the view through a property (animatable).'

# Source Info
  s.platform     =  :ios, '7.0'
  s.source  = { :git => "https://github.com/Fr4ncis/UIViewBlurDemo.git", :tag => "0.0.1" }
  s.source_files = ['UIViewBlur/','UIViewBlur/*.{h,m}']
  s.requires_arc = true
end