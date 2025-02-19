import SwiftUI




struct ContentView: View {
    @EnvironmentObject var chatController: ChatController
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var disposalDataModel: DisposalDataModel

    @State var selectedTab = 2

    var body: some View {
        NavigationView {
            TabView(selection: $selectedTab) {

         
                b1Page()
                    .environmentObject(chatController)
                    .environmentObject(locationManager)
                    .tabItem {
                        Image(systemName: "leaf.fill")
                        Text("Disposal Guide")
                    }
                    .tag(0)

          
                Cart()
                    .tabItem {
                        Image(systemName: "cart.fill")
                        Text("Cart")
                    }
                    .tag(1)

                
                ScrollView {
                    VStack(spacing: 20) {

                        
                        ZStack {
                            Image("contentbackground")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 250)
                                .clipped()
                                .edgesIgnoringSafeArea([.top, .horizontal])
                            
                            VStack(spacing: 10) {
                                Text("EcoSort")
                                    .font(.system(size: 40))
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)

                                Text("Your journey towards sustainable waste management")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                            }
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Today’s Eco Tip:")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(Color(hex: "#154F39"))

                            Text("Reduce food waste by planning meals and using leftovers creatively.")
                                .font(.body)
                                .foregroundColor(.black.opacity(0.8))
                                .multilineTextAlignment(.leading)
                                .padding(.horizontal)
                        }
                        .padding(.bottom, 30)

                        VStack(alignment: .leading, spacing: 20) {
                            Text("Resources")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(Color(hex: "#154F39"))

                            
                            createBanner(title: "Why Proper Waste Management Matters",
                                         shortDescription: "Reduce pollution and conserve resources.",
                                         imageName: "waste_management",
                                         detailedView: WhyWasteManagementMattersView())
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(radius: 5)
                                .padding()

                            
                            createBanner(title: "Reduce, Reuse, Recycle",
                                         shortDescription: "Learn about the Three R's.",
                                         imageName: "reduce_reuse_recycle",
                                         detailedView: ReduceReuseRecycleView())
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(radius: 5)
                                .padding()

                           
                            createBanner(title: "Waste Reduction Tips",
                                         shortDescription: "Cut waste with simple tips.",
                                         imageName: "waste_reduction",
                                         detailedView: WasteReductionTipsView())
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(radius: 5)
                                .padding()
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(15)
                        .shadow(radius: 5)
                        .padding(.horizontal)

                        
                        Button(action: {
                            
                            disposalDataModel.oldEntries.removeAll()

                            UserDefaults.standard.removeObject(forKey: "disposalEntries")

                   
                            authViewModel.signOut()
                        }) {
                            Text("Sign Out")
                                .foregroundColor(.black)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(hex: "#DACFBB")) // Soft Sand Color
                                .cornerRadius(10)
                                .shadow(radius: 5)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 40)

                    }
                    .padding(.horizontal)
                    .background(Color.white)
                }
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(2)

               
                TrackingDataView()
                    .environmentObject(disposalDataModel)
                    .tabItem {
                        Image(systemName: "chart.bar.fill")
                        Text("Disposal Log")
                    }
                    .tag(3)

                
                CollectiveDataView()
                    .environmentObject(disposalDataModel)
                    .tabItem {
                        Image(systemName: "leaf.arrow.circlepath")
                        Text("Progress")
                    }
                    .tag(4)

            }

            .accentColor(Color(hex: "#154F39"))
            .navigationTitle("")
            .navigationBarHidden(true)
        }
    }
    
    func createBanner<T: View>(title: String, shortDescription: String, imageName: String, detailedView: T) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.black)

            Text(shortDescription)
                .font(.body)
                .foregroundColor(.black.opacity(0.8))
                .lineSpacing(5)

            HStack {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)

                Spacer()

                NavigationLink(destination: detailedView) {
                    Text("Learn More")
                        .foregroundColor(Color(hex: "#154F39")) // Dark Green
                        .font(.footnote)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.9))
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}

struct WhyWasteManagementMattersView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Why Proper Waste Management Matters")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("""
                Reducing pollution and conserving natural resources are essential to sustaining our environment. Proper waste management helps combat climate change by lowering emissions and protecting wildlife and ecosystems from harm. It also ensures that hazardous materials are handled properly, preventing harm to people and the planet.
                """)
                    .font(.body)
                    .lineSpacing(5)
            }
            .padding()
        }
        .navigationTitle("Why It Matters")
    }
}

struct ReduceReuseRecycleView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Reduce, Reuse, Recycle")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("""
                The Three R's are a fundamental way to minimize waste. Reducing waste means thinking carefully about what you buy and use. Reusing means finding ways to give items a second life. Recycling ensures that materials can be processed and used again, conserving resources and energy.
                """)
                    .font(.body)
                    .lineSpacing(5)

                
                HStack(spacing: 10) {
                    ForEach(["Reduce", "Reuse", "Recycle"], id: \.self) { text in
                        VStack(spacing: 8) {
                            Text(text)
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.black)

                            Image("\(text.lowercased())")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 40, height: 40)

                            Text("Learn More")
                                .font(.footnote)
                                .foregroundColor(Color(hex: "#154F39"))
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(15)
                        .shadow(radius: 5)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("The Three R's")
    }
}

struct WasteReductionTipsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Waste Reduction Tips")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("""
                1. Plan your meals ahead of time to avoid buying more than you need.
                2. Use reusable bags, bottles, and containers instead of single-use plastics.
                3. Repurpose old items or donate them rather than throwing them away.
                4. Buy products with minimal packaging, and choose biodegradable or recyclable packaging when possible.
                """)
                    .font(.body)
                    .lineSpacing(5)
            }
            .padding()
        }
        .navigationTitle("Tips to Reduce Waste")
    }
}



extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 1 
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ChatController())
            .environmentObject(LocationManager())
            .environmentObject(AuthViewModel())
            .environmentObject(DisposalDataModel())
    }
}
