//
//  LoadingView.swift
//  TH49
//
//  Created by IGOR on 08/09/2025.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {

        ZStack {
            
            Color.white
                .ignoresSafeArea()
            
            VStack {
                
                Image("Appicon12")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 130)
            }
            
            
            VStack {
                
                Spacer()
                
                ProgressView()
                    .padding(.bottom,90)
            }
        }
    }
}

#Preview {
    LoadingView()
}
