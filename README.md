# GraffiTab-iOS
This is the iOS project for the system.

## About

The GraffiTab-iOS is a sample project that makes use of the GraffiTab-iOS-SDK.

## Installation

Download the SDK zip file and extract at a comfortable location. Follow the steps below to initialize and build the project:
* open Terminal and navigate to the project's directory;
* the framework uses Cocoapods so run `pod install` first;
* open the generated `.workspace` file;
* open the project's `Build Settings` tab and search for `Framework Search Paths`;
* delete any references to `GraffiTab-iOS-SDK` both from the `Release` and `Debug` configurations;
* delete the `GraffiTab-iOS-SDK` framework reference from the Frameworks folder;
* link the `GraffiTab-iOS-SDK` framework from the `Output` folder of the framework project;
* you will need to link the Aviary and Facebook SDKs as well in order to run the project;

## License

Copyright 2015 GraffiTab

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
