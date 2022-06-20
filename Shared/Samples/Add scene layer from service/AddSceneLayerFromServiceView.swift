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

import SwiftUI
import ArcGIS

struct AddSceneLayerFromServiceView: View {
    /// The scene for this sample.
    @StateObject private var scene: ArcGIS.Scene = {
        // Creates a scene and sets an initial viewpoint.
        let scene = Scene(basemapStyle: .arcGISTopographic)
        let point = Point(x: -4.49779155626782, y: 48.38282454039932, z: 62.013264927081764, spatialReference: .wgs84)
        let camera = Camera(locationPoint: point, heading: 41.64729875588979, pitch: 71.2017391571523, roll: 0)
        scene.initialViewpoint = Viewpoint(targetExtent: point, camera: camera)
        
        // Creates a surface and adds an elevation source.
        let surface = Surface()
        let elevationSource = ArcGISTiledElevationSource(url: .worldElevationServiceURL)
        surface.addElevationSource(ArcGISTiledElevationSource(url: .worldElevationServiceURL))
        
        // Sets the surface to the scene's base surface.
        scene.baseSurface = surface
        
        // Adds a scene layer from a URL to the scene's operational layers.
        scene.addOperationalLayer(ArcGISSceneLayer(url: .brestBuildingServiceURL))
        return scene
    }()
    
    var body: some View {
        SceneView(scene: scene)
    }
}

private extension URL {
    /// The URL of the scene's service. Displays buildings  in Brest, France.
    static var brestBuildingServiceURL: URL {
        URL(string: "https://tiles.arcgis.com/tiles/P3ePLMYs2RVChkJx/arcgis/rest/services/Buildings_Brest/SceneServer/layers/0")!
    }
    /// The URL of the Terrain 3D ArcGIS REST Service.
    static var worldElevationServiceURL: URL {
        URL(string: "https://elevation3d.arcgis.com/arcgis/rest/services/WorldElevation3D/Terrain3D/ImageServer")!
    }
}
