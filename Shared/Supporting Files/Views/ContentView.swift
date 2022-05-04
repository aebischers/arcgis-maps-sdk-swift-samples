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

struct ContentView: View {
    /// All samples retrieved from the Samples directory.
    let samples: [Sample]
    /// The search query in the search bar.
    @State var query = ""
    
    var body: some View {
        NavigationView {
            SampleList(samples: samples, query: $query)
                .navigationTitle("Samples")
            Text("Select a sample from the list.")
        }
        .searchable(text: $query, prompt: "Search By Sample Name")
    }
}
