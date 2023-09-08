// Copyright 2023 Esri
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import SwiftUI
import ArcGIS
import ExternalAccessory

struct ShowDeviceLocationWithNMEADataSourcesView: View {
    /// The view model for the sample.
    @StateObject private var model = Model()
    
    /// A Boolean value indicating whether to show an alert.
    @State private var isShowingAlert = false
    
    /// An error from the `EAAccessoryManager`.
    @State private var accessoryError: AccessoryError? {
        didSet { isShowingAlert = accessoryError != nil }
    }
    
    /// An error from starting the location data source.
    @State private var locationDataSourceError: Error? {
        didSet { isShowingAlert = locationDataSourceError != nil }
    }
    
    var body: some View {
        MapView(map: model.map)
            .locationDisplay(model.locationDisplay)
            .overlay(alignment: .top) {
                VStack(alignment: .leading) {
                    Text(model.accuracyStatus)
                    Text(model.satelliteStatus)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .background(.thinMaterial, ignoresSafeAreaEdges: .horizontal)
            }
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    Menu("Source") {
                        Button("Mock Data") {
                            Task {
                                do {
                                    try await model.start(usingMockedData: true)
                                } catch {
                                    self.locationDataSourceError = error
                                }
                            }
                        }
                        Button("Device") {
                            Task {
                                do {
                                    try selectDevice()
                                    try await model.start()
                                } catch let error as AccessoryError {
                                    self.accessoryError = error
                                } catch {
                                    self.locationDataSourceError = error
                                }
                            }
                        }
                    }
                    .disabled(model.isSourceMenuDisabled)
                    Spacer()
                    Button("Recenter") {
                        model.locationDisplay.autoPanMode = .recenter
                    }
                    .disabled(model.isRecenterButtonDisabled)
                    Spacer()
                    Button("Reset") {
                        Task {
                            await model.reset()
                        }
                    }
                    .disabled(model.isResetButtonDisabled)
                }
            }
            .alert("Error", isPresented: $isShowingAlert, presenting: accessoryError) { _ in
                EmptyView()
            } message: { error in
                Text(error.detail)
            }
            .alert(isPresented: $isShowingAlert, presentingError: locationDataSourceError)
            .onDisappear {
                // Reset the model to stop the data source and observations.
                Task {
                    await model.reset()
                }
            }
    }
    
    func selectDevice() throws {
        if let (accessory, protocolString) = model.firstSupportedAccessoryWithProtocol() {
            // Use the supported accessory directly if it's already connected.
            model.accessoryDidConnect(connectedAccessory: accessory, protocolString: protocolString)
        } else {
            throw AccessoryError(
                detail: "There are no supported Bluetooth devices connected. Open up \"Bluetooth Settings\", connect to your supported device, and try again."
            )
        
            // NOTE: The code below shows how to use the built-in Bluetooth picker
            // to pair a device. However there are a couple of issues that
            // prevent the built-in picker from functioning as desired.
            // The work-around is to have the supported device connected prior
            // to running the sample. The above message will be displayed
            // if no devices with a supported protocol are connected.
            //
            // The Bluetooth accessory picker is currently not supported
            // for Apple Silicon devices - https://developer.apple.com/documentation/externalaccessory/eaaccessorymanager/1613913-showbluetoothaccessorypicker/
            // "On Apple silicon, this method displays an alert to let the user
            // know that the Bluetooth accessory picker is unavailable."
            //
            // Also, it appears that there is currently a bug with
            // `showBluetoothAccessoryPicker` - https://developer.apple.com/forums/thread/690320
            // The work-around is to ensure your device is already connected and it's
            // protocol is in the app's list of protocol strings in the plist.info table.
//            EAAccessoryManager.shared().showBluetoothAccessoryPicker(withNameFilter: nil) { error in
//                if let error = error as? EABluetoothAccessoryPickerError,
//                   error.code != .alreadyConnected {
//                    switch error.code {
//                    case .resultNotFound:
//                        self.error = AccessoryError(detail: "The specified accessory could not be found, perhaps because it was turned off prior to connection.")
//                    case .resultCancelled:
//                        // Don't show error message when the picker is cancelled.
//                        self.error = nil
//                        return
//                    default:
//                        self.error = AccessoryError(detail: "Selecting an accessory failed for an unknown reason.")
//                    }
//                } else if let (accessory, protocolString) = model.firstSupportedAccessoryWithProtocol() {
//                    // Proceed with supported and connected accessory, and
//                    // ignore other accessories that aren't supported.
//                    model.accessoryDidConnect(connectedAccessory: accessory, protocolString: protocolString)
//                }
//            }
        }
    }
}

/// An error relating to NMEA accessories.
private struct AccessoryError: Error {
    let detail: String
}
