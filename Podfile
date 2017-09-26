# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'iOS' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  pod 'Google/SignIn'
  pod 'ProximityKit', '~> 1.2'
  pod 'SCLAlertView'
  pod 'Crashlytics'
  pod 'DALI'
  pod 'OneSignal', '>= 2.5.2', '< 3.0'

  # Pods for DALI Lab

  target 'iOSTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'iOSUITests' do
    inherit! :search_paths
    # Pods for testing
  end
end

post_install do |installer|
	installer.aggregate_targets.each do |target|
		copy_pods_resources_path = "Pods/Target Support Files/#{target.name}/#{target.name}-resources.sh"
		string_to_replace = '--compile "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"'
		assets_compile_with_app_icon_arguments = '--compile "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}" --app-icon "${ASSETCATALOG_COMPILER_APPICON_NAME}" --output-partial-info-plist "${BUILD_DIR}/assetcatalog_generated_info.plist"'
		text = File.read(copy_pods_resources_path)
		new_contents = text.gsub(string_to_replace, assets_compile_with_app_icon_arguments)
		File.open(copy_pods_resources_path, "w") {|file| file.puts new_contents }
	end
end

target 'tvOS' do
	# Comment the next line if you're not using Swift and don't want to use dynamic frameworks
	use_frameworks!
	pod 'DALI'
	
	# Pods for DALI Lab
	
	target 'tvOSTests' do
		inherit! :search_paths
		# Pods for testing
	end
	
	target 'tvOSUITests' do
		inherit! :search_paths
		# Pods for testing
	end
end
