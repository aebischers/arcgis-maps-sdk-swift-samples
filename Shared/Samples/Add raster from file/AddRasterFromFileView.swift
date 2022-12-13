// Copyright 2022 Esri
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

import ArcGIS
import SwiftUI

struct AddRasterFromFileView: View {
    /// Makes a map with a raster layer.
    private static func makeMap() -> Map {
        /// A map with a standard imagery basemap style.
        let map = Map(basemapStyle: .arcGISImageryStandard)
        // Gets the Shasta.tif file URL.
        let shastaURL = Bundle.main.url(forResource: "Shasta", withExtension: "tif", subdirectory: "raster-file/raster-file")!
        // Creates a raster with the file URL.
        let raster = Raster(fileURL: shastaURL)
        // Creates a raster layer using the raster object.
        let rasterLayer = RasterLayer(raster: raster)
        // Adds the raster layer to the map's operational layer.
        map.addOperationalLayer(rasterLayer)
        return map
    }
    
    /// A map with a standard imagery basemap style.
    @StateObject private var map = makeMap()
    
    /// A Boolean value indicating whether to show an alert.
    @State private var isShowingAlert = false
    
    /// The error shown in the alert.
    @State private var error: Error? {
        didSet { isShowingAlert = error != nil }
    }
    
    /// The current viewpoint of the map view.
    @State private var viewpoint: Viewpoint?
    
    var body: some View {
        // Creates a map view with a viewpoint to display the map.
        MapView(map: map, viewpoint: viewpoint)
            .onViewpointChanged(kind: .centerAndScale) { viewpoint = $0 }
            .alert(isPresented: $isShowingAlert, presentingError: error)
            .task {
                do {
                    let rasterLayer = map.operationalLayers.first!
                    try await rasterLayer.load()
                    viewpoint = Viewpoint(center: rasterLayer.fullExtent!.center, scale: 8e4)
                } catch {
                    // Presents an error message if the raster fails to load.
                    self.error = error
                }
            }
    }
}