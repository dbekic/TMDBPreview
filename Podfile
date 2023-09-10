platform :ios, '14.0'

inhibit_all_warnings! # for the needs of the project, we will not deal with potential pods warnings

# Pods
def reactive
  pod 'RxSwift'
  pod 'RxCocoa'
end

def ui
  pod 'Kingfisher'
  pod 'SnapKit'
end

def other
  pod 'SwiftLint'
end

def shared_pods
  reactive
  ui
  other
end

def testing_pods
  pod 'RxTest'
  pod 'RxBlocking'
end

target 'TMDBPreview' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for TMDBPreview
  shared_pods

  target 'TMDBPreviewTests' do
    inherit! :search_paths
    # Pods for testing
    testing_pods
  end

  target 'TMDBPreviewUITests' do
    # Pods for testing
  end

end

post_install do |installer|
  installer.generated_projects.each do |project|
    project.targets.each do |target|
      target.build_configurations.each do |config|
        # Silence the warning that minimum deployment target supported is 14.0
        deployment_target = config.build_settings['IPHONEOS_DEPLOYMENT_TARGET']
        target_components = deployment_target.split
        if target_components.length > 0
          target_initial = target_components[0].to_i
          if target_initial < 14
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = "14.0"
          end
        end
      end
    end
  end
end
