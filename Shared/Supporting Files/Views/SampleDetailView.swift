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

struct SampleDetailView: View {
    /// The sample to display in the view.
    private let sample: Sample
    
    /// An object to manage on-demand resources for a sample with dependencies.
    @StateObject private var onDemandResource: OnDemandResource
    
    init(sample: Sample) {
        self.sample = sample
        self._onDemandResource = StateObject(
            wrappedValue: OnDemandResource(tags: [sample.nameInUpperCamelCase])
        )
    }
    
    var body: some View {
        Group {
            switch onDemandResource.requestState {
            case .notStarted, .inProgress:
                VStack {
                    ProgressView(onDemandResource.progress)
                    Button("Cancel") {
                        onDemandResource.cancel()
                    }
                }
                .padding()
            case .cancelled:
                VStack {
                    Image(systemName: "nosign")
                    Text("On-demand resources download canceled.")
                }
                .padding()
            case .error:
                VStack {
                    Image(systemName: "x.circle")
                    Text(onDemandResource.error!.localizedDescription)
                }
                .padding()
            case .downloaded:
                sample.makeBody()
            }
        }
        .task {
            guard case .notStarted = onDemandResource.requestState else { return }
            await onDemandResource.download()
        }
        .navigationTitle(sample.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    print("Info button was tapped")
                } label: {
                    Image(systemName: "info.circle")
                }
            }
        }
    }
}

extension SampleDetailView: Identifiable {
    var id: String { sample.name }
}
