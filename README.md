# NearbyInteraction_SwiftUI

Multipeer Connectivity & Nearby Interaction App

This is a Swift-based project that demonstrates the use of Multipeer Connectivity and Nearby Interaction on iOS devices. The app allows devices to communicate over a peer-to-peer network, sharing discovery tokens and calculating distance and direction using Ultra-Wideband (UWB) technology.

Features
	Multipeer Connectivity: Connects multiple iOS devices using a peer-to-peer network, enabling device discovery and data sharing.
	Nearby Interaction: Uses UWB technology to calculate the distance and direction between nearby devices.
	Real-time Updates: Displays the connected devices and updates the distance and direction between peers in real-time.

Installation

　　　　　Clone the repository:
     
     	git clone https://github.com/kei224022/NearbyInteraction_SwiftUI

 　　　　Open the project in Xcode:
	Make sure you are using Xcode 12.0 or later.
	Build and Run:
	Select your target device or simulator and run the app. It is recommended to use physical devices for testing Nearby Interaction features.

Usage

　　　　　Launch the app on two or more iOS devices.
	Navigate between the following tabs:
	Device: Displays the list of connected peers.
	UWB: Shows real-time distance and direction information using UWB.
	Devices will automatically connect to each other if they are within range, and distance/direction data will be displayed.

Requirements

　　　　　iOS 14.0 or later (for Multipeer Connectivity).
	iOS 16.0 or later (for Nearby Interaction without isSupported).
	Devices with UWB support (e.g., iPhone 11 or newer).

Contributions

Contributions are welcome! Please fork the repository and submit a pull request for any improvements or bug fixes.

License

This project is licensed under the MIT License - see the LICENSE file for details.
