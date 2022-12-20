import SwiftUI

public struct FlipAnimationView<Front:View,Rear:View>: View {
    @State private var isImageFlipped = false
    var numberOFSpin: Int = 8
    var front:() -> Front
    var rear: () -> Rear
    let completion: () -> Void
   public init(
               numberOFSpin: Int,
               @ViewBuilder front: @escaping () -> Front,
               @ViewBuilder rear: @escaping () -> Rear,
               completion: @escaping () -> Void) {
        self.numberOFSpin = numberOFSpin
        self.front = front
        self.rear = rear
        self.completion = completion
    }
    public var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
                .zIndex(1)
            
            if isImageFlipped {
                rear()
                    .transition(.asymmetric(insertion: .flipIn.animation(animation), removal: .flipOut))
                    .animation(animation)
                    .zIndex(3)
                
            }
            else {
                front()
                    .transition(.asymmetric(insertion: .flipIn.animation(animation), removal: .flipOut))
                    .animation(animation)
                    .zIndex(2)
            }
        }
        .onAppear {
            delay(0.5) {
                performRepeatAnimation()
            }
        }
    }
    
    func performRepeatAnimation(count: Int = 0) {
        withAnimation(animation) {
            isImageFlipped.toggle()
            if count < numberOFSpin {
                delay(0.2) {
                    performRepeatAnimation(count: count + 1)
                }
            } else {
                delay(0.5) {
                    completion()
                }
            }
        }
    }
    
    var animation: Animation {
        .linear(duration: 0.1)
    }
    func delay(_ seconds: TimeInterval, block: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: block)
    }
}




extension AnyTransition {
    static var flipOut: AnyTransition {
        AnyTransition.modifier(active: FlipTransition(degree: 90), identity: FlipTransition(degree: 0))
    }
    static var flipIn: AnyTransition {
        AnyTransition.modifier(active: FlipTransition(degree: -90), identity: FlipTransition(degree: 0))
    }
}

struct FlipTransition: AnimatableModifier {
    var degree: Double
    var animatableData: Double {
        get {
            degree
        } set {
            degree = newValue
        }
    }
    func body(content: Content) -> some View {
        content
            .rotation3DEffect(.degrees(degree), axis: (0,1,0), perspective: 0.1)
    }
}
