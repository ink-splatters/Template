//
//  ContentView.swift
//  Template
//
//  Created by Reza Ali on 8/18/22.
//  Copyright © 2022 Reza Ali. All rights reserved.
//

import SwiftUI
import Forge

struct ContentView: View {
    var renderer: Forge.Renderer
    
    init(renderer: Forge.Renderer) {
        self.renderer = renderer
        copyResourcesAssetsToDocumentsAssets()
    }
    
    var body: some View {
        ForgeView(renderer: renderer)
            .ignoresSafeArea()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(renderer: Renderer())
    }
}
