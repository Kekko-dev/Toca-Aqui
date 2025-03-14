struct RootView: View {
    @State private var showWelcome = true

    var body: some View {
        ZStack {
            // Your main content (e.g., Content_Camera_View)
            Content_Camera_View()
            
            // Overlay the welcome view when needed.
            if showWelcome {
                WelcomeView()
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .onAppear {
            // Dismiss the welcome screen after a delay (e.g., 3 seconds)
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation {
                    showWelcome = false
                }
            }
        }
    }
}