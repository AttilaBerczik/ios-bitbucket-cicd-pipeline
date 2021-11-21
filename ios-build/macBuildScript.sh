# Create build folder
cd /Users/user111111
rm -rf build
mkdir build
cd build

# Download repository from Bitbucket
git clone {your git repo}
cd dst2-mobile/

# Install dependencies
#   These exports are necessary for yarn and pod to work
export PATH="/Users/user111111/.nvm/versions/node/v14.17.6/bin/:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/share/dotnet:~/.dotnet/tools:/Library/Frameworks/Mono.framework/Versions/Current/Commands:/usr/local/munki:/Applications/Xamarin Workbooks.app/Contents/SharedSupport/path-bin"
export LANG=en_US.UTF-8
yarn install
cd ios/
pod repo update
pod install

# Build with Xcode's command line interface
# Unlock keychain
security unlock-keychain -p $macPassword /Users/user111111/Library/Keychains/login.keychain-db
# Update build number to Bitbucket build number
agvtool new-version -all $BUILD_NUMBER
#   Archive project
xcodebuild -workspace dst.xcworkspace -scheme dst -configuration Release clean archive -archivePath ../builds/dst.xcarchive -allowProvisioningUpdates DEVELOPMENT_TEAM=yourdevteamid
#   Export project .ipa file
xcodebuild -exportArchive -archivePath ../builds/dst.xcarchive PROVISIONING_PROFILE_SPECIFIER="your-profile" -exportOptionsPlist ../ios-build/exportOptions.plist -exportPath ../builds/ -UseModernBuildSystem=NO CODE_SIGN_STYLE="Manual" CODE_SIGN_IDENTITY="Apple Distribution: your code sign identity"
# Finally, publish the app!
xcrun altool --upload-app --file /Users/user111111/build/dst2-mobile/builds/dst.ipa --username $appStoreUsername --password $appStoreAccountPassword

# Delete the build folder
cd ..
rm -rf build
