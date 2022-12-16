//
//  PopupBackDesignPickerView.swift
//  Memorize
//
//  Created by Amini on 26/05/22.
//

import SwiftUI

struct PopupBackDesignPickerView: View {
    
    @Environment(\.self) var environment
    
    var body: some View {
        let deviceSize = UIScreen.main.bounds.size
        VStack(spacing: 0) {
            HStack {
                Text("Select Images")
                    .font(.callout.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Button {
                    
                } label : {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.primary)
                }
            }
            .padding([.horizontal, .top])
            .padding(.bottom, 10)
            
            ScrollView(.vertical, showsIndicators: false) {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 4), spacing: 12) {
//                    ForEach() { $image in
//                        GridContent(imageAsset: image)
//                    }
                }
                .padding()
            }
        }
        .frame(width: deviceSize.height / 1.8)
        .frame(maxWidth: (deviceSize.width - 40) > 350 ? 350 : (deviceSize.width - 40))
        .background {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(environment.colorScheme == .dark ? .black : .white)
        }
        
        // MARK: Since its
        .frame(width: deviceSize.width, height: deviceSize.height, alignment: .center)
    }
    
    // MARK: Grid Image Content
    @ViewBuilder
    func GridContent(imageAsset: String)-> some View {
        GeometryReader { proxy in
            let size = proxy.size
            ZStack {
                if let thumbnail = imageAsset {
                    Image(thumbnail)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: size.width, height: size.height)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                } else {
                    ProgressView()
                        .frame(width: size.width, height: size.height, alignment: .center)
                }
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(.black.opacity(0.1))
                    
                    Circle()
                        .fill(.white.opacity(0.25))
                    
                    Circle()
                        .stroke(.white, lineWidth: 1)
                    
    //                if let index = imagepickermode.selectedImage { where: {
    //                    in
    //                    asset.id == imageAsset.id
    //                }} {
    //                    Circle().fill(.blue)
    //                }
                }
                .frame(width: 20, height: 20)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .padding()
            }
            .clipped()
            .onTapGesture {
                withAnimation(.easeInOut) {
                    // MARK: Select / Unselect image
    //                if let index
                }
            }
        }
        .frame(height: 70)
    }
}
