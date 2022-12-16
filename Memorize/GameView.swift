//
//  GameView.swift
//  Memorize
//
//  Created by Amini on 20/05/22.
//

import SwiftUI
import PhotosUI

struct GameView: View {
    @ObservedObject var game: MemoryGameModel
    @State var timer = 5
    @State var backImage = ""
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    
    init(_ itemImage: [ItemImage], _ ItemMatch: [ItemMatch], _ ItemPair: [ItemPair], backItemImage: String){
        self.game = MemoryGameModel(itemImage: itemImage,
                                    itemMatches: ItemMatch,
                                    itemPair: ItemPair,
                                    backImage: backItemImage
        )
    }
    
    var body: some View {
        VStack {
            gameHUD
                .padding()
                .background(.white, in : RoundedRectangle(cornerRadius: 15))
            Spacer()
            gameBody
            Spacer()
            Button {

            } label: {
                Text("Next")
                    .font(.title3.bold())
                    .foregroundColor(.white)
                    .padding(.vertical)
                    .frame(maxWidth: .infinity)
                    .background(.cyan, in: RoundedRectangle(cornerRadius: 15))
            }
        }
        .navigationBarTitle("Hidden Title")
        .navigationBarHidden(true)
    }
    
    var gameHUD: some View {
        HStack {
            Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                Image(systemName: "arrowtriangle.backward.square.fill")
                    .font(.title)
                    .foregroundColor(.black)
            }

            Spacer()
            Button {
                
            } label: {
                Image(systemName: "speaker.wave.2.fill")
                    .font(.title)
                    .foregroundColor(.black)
            }
        }
        .overlay {
            VStack {
                Text("Level 1")
                Text("Timer")
                    .fontWeight(.bold)
            }
        }
    }
    
    var gameBody: some View {
        AspectVGrid(items: game.cards, aspectRatio: 1/1, content: { card in
            
            if card.isMatched {
                Color.clear
            } else {
                CardView(card: card)
                    .padding()
                    .transition(AnyTransition.scale.animation(Animation.easeInOut(duration: 1)))
                    .onTapGesture {
                        withAnimation {
                            game.choose(card)
                        }
                    }
            }
            
        })
        .foregroundColor(.cyan)
        .onAppear {
            withAnimation {
                game.createNewGame(with: 4)
            }
        }
    }
}

struct CardView: View {
    let card: Card
    
    var body: some View {
        GeometryReader { geometry in
            
            ZStack {
                
                if card.isFaceUp {
                    Pie(startAngle: Angle(degrees: 0-90), endAngle: Angle(degrees: 110-90))
                        .padding(5)
                        .opacity(0.5)
                    
                    VStack {
                        Image(uiImage: UIImage(data: imageData(base64String: card.image))!)
                            .resizable()
                            .scaledToFit()
                            .rotationEffect(Angle.degrees(card.isMatched ? 360 : 0))
                            .onAppear {
                                withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {}
                            }
                        
                        Text(card.content)
                            .multilineTextAlignment(.center)
                            .font(.title3)
                            .foregroundColor(.black)
                            .controlSize(.mini)
                            .lineLimit(nil)
                    }
                    
                } else {
                    
                    if let image = UIImage(data: imageData(base64String: card.backDesign)) {
                        Image(uiImage: image)
                            .resizable()
                            .padding()
                    } else {
                        Image("card")
                            .resizable()
                            .padding()
                    }
                    
                    
                }
                
            }
        }
    }
    
    private func imageData(base64String: String) -> Data {
        let dataDecoded : Data = Data(base64Encoded: base64String, options: .ignoreUnknownCharacters)!
        return dataDecoded
    }
    
    private func scale(thatFits size: CGSize) -> CGFloat {
        min(size.width, size.height) / (DrawingConstants.fontSize / DrawingConstants.fontScale)
    }
    
    private func font(in size: CGSize) -> Font {
        Font.system(size: min(size.width, size.height) * DrawingConstants.fontScale)
    }
    
    private struct DrawingConstants {
        static let fontScale: CGFloat = 0.7
        static let fontSize: CGFloat = 32
        static let imageScale: CGFloat = 0.5
        static let imageSize: CGSize = CGSize(width: 50, height: 50)
    }
}

struct Card_Previews: PreviewProvider {
    static var previews: some View {
        MemoryGameView()
    }
}

