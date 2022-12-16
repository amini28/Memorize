//
//  ContentView.swift
//  Memorize
//
//  Created by Amini on 09/05/22.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import ActivityIndicatorView

struct MemoryGameView: View {
    @ObservedObject var data: DataManager = DataManager()
    @State var loading = true
    @State var timer = 5
    @State private var searchText = ""
    @State var splashscreen = true
    
    init() {
        UITableView.appearance().separatorStyle = .none
        UITableView.appearance().separatorColor = .clear
        UITableViewCell.appearance().backgroundColor = .white
        UITableView.appearance().backgroundColor = .white
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                if splashscreen {
                    SplashScreen()
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                                withAnimation(.easeOut(duration: 1.0)) {
                                    splashscreen = false
                                }
                            }
                        }
                } else {
                    VStack{
                        ActivityIndicatorView(isVisible: $data.isLoading, type: .scalingDots(count: 3, inset: 2))
                            .foregroundColor(.cyan)
                            .frame(width: 100, height: 100)

                        if !data.isLoading {
                            MemoryGameHomeTopbar()
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.black)
                                    .padding()
                                TextField("Search...", text:  $searchText)
                            }
                            .background(Color.white)
                            .cornerRadius(30)
                            .padding(.horizontal, 25)
                            
                            List {
                                ForEach(searchResults, id: \.self){ item in
                                    ZStack(alignment: .leading) {
                                        NavigationLink(destination: GameView(Array(item.itemImage),
                                                                             Array(item.itemMatch),
                                                                             Array(item.itemPair),
                                                                             backItemImage: UserDefaults.standard.string(forKey: "backdesign") ?? "")) {
                                            EmptyView()
                                        }
                                        .opacity(0)
                                        ListItemView(title: item.title,
                                                     description: item.descriptions,
                                                     icon: item.icon)
                                    }
                                }
                            }
                            .listRowSeparator(.hidden)
                            .listRowSeparatorTint(.white, edges: .all)
                            .listStyle(.inset)
                            .searchable(text: $searchText)
                        }
                    }
                    .background(.white)
                    .navigationBarTitle("Memorize and Match")
                    .navigationBarHidden(true)
                }
                
            }
            
        }
        .onAppear {
            data.startCheckingNetworkCall()
        }
        
    }
    
    var searchResults: [GameItem] {
       if searchText.isEmpty {
           return data.item
       } else {
           return data.item.filter { $0.title.contains(searchText) || $0.descriptions.contains(searchText) }
       }
   }
    
}

struct SplashScreen: View {
    
    @State var hiddenText = true
    @State var animate = false

    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            VStack {
                LottieView(filename: "brain1")
                    .frame(width: UIScreen.main.bounds.width, height: 200)

                if !hiddenText {
                    ScaleableText("Memorize n' Match", isAnimating: $animate)
                        .offset(x: 0, y: -50)
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.1) {
                withAnimation {
                    hiddenText = false
                    animate = true
                }
            }
        }
    }
}

struct ScaleableText: View {
    @Binding var isAnimating: Bool
    let text: String
    let cycle: Bool

    private var words: [String] {
        text.map { String($0) }
    }
    private var fraction: CGFloat {
        return 1.0 / CGFloat(words.count)
    }

    init(_ text: String, cycle: Bool = false, isAnimating: Binding<Bool>) {
        self.text = text
        self.cycle = cycle
        self._isAnimating = isAnimating
    }

    var body: some View {
        HStack(spacing: 0.0) {
            ForEach(words.indices, id: \.self) { index in
                Text(words[index])
                    .modifier(FontScaleModifier(isAnimating: isAnimating,
                                              fraction: fraction, order: index))
                    .animation(cycle ? .easeOut(duration: 1.0).repeatForever(autoreverses: false) :
                                  .linear(duration: 0), value: isAnimating
                )
            }
        }
    }
}

struct FontScaleModifier: AnimatableModifier {
    private var percentage: CGFloat
    private let fraction: CGFloat
    private let order: CGFloat

    var animatableData: CGFloat {
        get { percentage }
        set { percentage = newValue }
    }

    var size: CGFloat {
        guard percentage != 0 && percentage != 1 else { return 1.0 }
        let isInRange = percentage >= order * fraction && percentage <= order * fraction + fraction
        return isInRange ? 2.0 : 1.0
    }

    init(isAnimating: Bool, fraction: CGFloat, order: Int) {
        self.percentage = isAnimating ? 1.0 : 0.0
        self.fraction = fraction
        self.order = CGFloat(order)
    }

    func body(content: Content) -> some View {
        content
          .scaleEffect(x: size, y: size)
    }
}

struct MemoryGameHomeTopbar: View {
    var body: some View {
        HStack {
            Text("Memorize and Match")
                .fontWeight(.bold)
                .frame(alignment: .center)
        }
    }
}

struct ListItemView: View {
    var title: String
    var description: String
    var icon: String
    
    private func imageData(base64String: String) -> Data? {
//        let dataDecoded : Data = Data(base64Encoded: base64String, options: .ignoreUnknownCharacters)!
        if let dateDecoded = Data(base64Encoded: base64String, options: .ignoreUnknownCharacters){
            return dateDecoded
        } else {
            return nil
        }
    }
    
    var body: some View {
            
        HStack(alignment : .center) {
            if let iconData = UIImage(data: imageData(base64String: icon) ?? Data())  {
                Image(uiImage: iconData)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
            } else {
                Image("eng.png")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text(title)
                    .font(.title3)
                    .foregroundColor(.primary)
                    .padding(.trailing, 20)
                Text(description)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            .padding()
        }
    }
}

struct LoadingView: View {
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .orange))
                .scaleEffect(3)
        }
    }
}
