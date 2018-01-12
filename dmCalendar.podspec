Pod::Spec.new do |s|
  s.name             = 'dmCalendar'
  s.version          = '0.1.2'
  s.summary          = 'Customizable Infinite Calendar'

  s.description      = <<-DESC
Customize this calendar just like you would with a UICollectionView. Easy and simple.
                       DESC

  s.homepage         = 'https://github.com/dm1014/dmCalendar'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'David Martin' => 'd.1014@yahoo.com' }
  s.source           = { :git => 'https://github.com/dm1014/dmCalendar.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'
  s.source_files = 'dmCalendar/*.swift'

end
