import SwiftUI



struct CollectiveDataView: View {
    @EnvironmentObject var disposalDataModel: DisposalDataModel
    @State private var showingPopover: Bool = false
    @State private var popoverText: String = ""

    
    private func fakeAveragePoundsPerEntry() -> Double {
        return disposalDataModel.oldEntries.isEmpty ? 0 : 10.0  // Updated fake data
    }

    private func fakeRecyclingPercentage() -> Double {
        return disposalDataModel.oldEntries.isEmpty ? 0 : 33.33  // Updated fake data
    }

    private func fakeCompostingPercentage() -> Double {
        return disposalDataModel.oldEntries.isEmpty ? 0 : 50.0  // Updated fake data
    }

    private func fakeEWastePercentage() -> Double {
        return disposalDataModel.oldEntries.isEmpty ? 0 : 16.67  // Updated fake data
    }

    private func fakeHazardousWastePercentage() -> Double {
        return disposalDataModel.oldEntries.isEmpty ? 0 : 0  // Updated fake data
    }

    private func fakeIncinerationPercentage() -> Double {
        return disposalDataModel.oldEntries.isEmpty ? 0 : 0  // Updated fake data
    }

    private func fakeDonationPercentage() -> Double {
        return disposalDataModel.oldEntries.isEmpty ? 0 : 0  // Updated fake data
    }

    private func fakeGreenhouseGasEmissionsPrevented() -> Double {
        return disposalDataModel.oldEntries.isEmpty ? 0 : 90.0  // Updated fake data
    }

    private func fakeHazardousWasteNeutralized() -> Double {
        return disposalDataModel.oldEntries.isEmpty ? 0 : 0  // Updated fake data
    }

    private func fakeSoilNutrientsRestored() -> Double {
        return disposalDataModel.oldEntries.isEmpty ? 0 : 200.0  // Updated fake data
    }

    
    var body: some View {
        ScrollView {
            VStack {
                VStack(spacing: 10) {
                    Text("Disposal Data")
                        .font(.system(size: 40))
                        .fontWeight(.bold)
                        .padding(.top, 30)
                }
                .padding(.bottom, 30)

            
                Text("See your waste disposal history and sustainability progress.")
                    .font(.subheadline)
                    .padding(.bottom, 20)

              
                keyMetricsSection

               
                pieChartSection

                levelAndBadgesSection

                
                disposalHistorySection

                Spacer()
            }
            .padding()
        }
        .popover(isPresented: $showingPopover, content: {
            Text(popoverText)
                .padding()
                .fixedSize(horizontal: false, vertical: true)
                .frame(width: 250, height: 150, alignment: .center)
        })
        .navigationTitle("Waste Management")
    }

    
    var keyMetricsSection: some View {
        let totalEntries = disposalDataModel.oldEntries.count
        let totalWeight = calculateTotalWeight()

        return VStack(alignment: .leading, spacing: 15) {
      
            HStack {
                Text("Waste Diversion Rate")
                    .font(.headline)
                infoButton("""
        Waste Diversion Rate: The percentage of waste you kept out of landfills by recycling or composting.

        Formula: (Recycled + Composted) / Total Waste * 100
        """)
            }
            Text(totalEntries == 0 ? "0%" : "\(Int(calculateDiversionRate()))% of your waste has been diverted from landfills.")
                .font(.subheadline)
                .padding(.bottom, 10)

        
            HStack {
                Text("Average Pounds per Entry")
                    .font(.headline)
                infoButton("""
        Average Pounds per Entry: Total waste weight divided by the number of entries.
        """)
            }
            Text("\(String(format: "%.2f", fakeAveragePoundsPerEntry())) lbs")
                .font(.subheadline)
                .padding(.bottom, 10)

            HStack {
                Text("Recycling Efficiency")
                    .font(.headline)
                infoButton("""
        Recycling Efficiency: The portion of your total waste that was recycled.
        """)
            }
            Text("\(fakeRecyclingPercentage())%")
                .font(.subheadline)
                .padding(.bottom, 10)

            HStack {
                Text("Composting Efficiency")
                    .font(.headline)
                infoButton("""
        Composting Efficiency: The portion of your total waste that was composted.
        """)
            }
            Text("\(fakeCompostingPercentage())%")
                .font(.subheadline)
                .padding(.bottom, 10)

            HStack {
                Text("E-Waste Disposed")
                    .font(.headline)
                infoButton("""
        E-Waste Disposed: The portion of your total waste that was classified as electronic waste.
        """)
            }
            Text("\(fakeEWastePercentage())%")
                .font(.subheadline)
                .padding(.bottom, 10)

            HStack {
                Text("Total Waste Generated")
                    .font(.headline)
                infoButton("""
        Total Waste Generated: Total amount of waste you logged.
        """)
            }
            Text("\(Int(totalWeight)) lbs")
                .font(.subheadline)
                .padding(.bottom, 10)

           
            HStack {
                Text("Greenhouse Gas Emissions Prevented")
                    .font(.headline)
                infoButton("""
        Greenhouse Gas Emissions Prevented: The reduction in CO2-equivalent emissions from recycling and composting.
        """)
            }
            Text("\(fakeGreenhouseGasEmissionsPrevented()) kg CO2-eq")
                .font(.subheadline)
                .padding(.bottom, 10)

            HStack {
                Text("Hazardous Waste Neutralized")
                    .font(.headline)
                infoButton("""
        Hazardous Waste Neutralized: The amount of hazardous waste that was safely neutralized.
        """)
            }
            Text("\(fakeHazardousWasteNeutralized()) liters")
                .font(.subheadline)
                .padding(.bottom, 10)

            HStack {
                Text("Soil Nutrients Restored")
                    .font(.headline)
                infoButton("""
        Soil Nutrients Restored: The amount of nitrogen and other nutrients restored to the soil through composting.
        """)
            }
            Text("\(fakeSoilNutrientsRestored()) grams of nitrogen")
                .font(.subheadline)
                .padding(.bottom, 10)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
        .padding(.bottom, 20)
    }

    var pieChartSection: some View {
        let totalWeight = calculateTotalWeight()

        return WasteDistributionPieChart(
            recycledPercentage: calculateRecyclingPercentage() / 100,
            compostedPercentage: calculateCompostingPercentage() / 100,
            ewastePercentage: calculateEWastePercentage() / 100,
            hazardousPercentage: calculateHazardousWastePercentage() / 100,
            incinerationPercentage: calculateIncinerationPercentage() / 100,
            donationPercentage: calculateDonationPercentage() / 100,
            landfillPercentage: (100 - calculateDiversionRate()) / 100,
            totalWeight: totalWeight
        )
        .frame(height: 300)
        .padding(.top, 30)
        .padding(.bottom, 30)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
        .padding(.bottom, 20)
    }

    private func calculateRecyclingPercentage() -> Double {
        let recycled = disposalDataModel.oldEntries.filter { $0.disposalMethod == "Recycle" }
            .reduce(0) { $0 + (Double($1.quantity) ?? 0) }
        let totalWeight = calculateTotalWeight()
        
        return totalWeight > 0 ? (recycled / totalWeight) * 100 : 0
    }

    private func calculateCompostingPercentage() -> Double {
        let composted = disposalDataModel.oldEntries.filter { $0.disposalMethod == "Compost" }
            .reduce(0) { $0 + (Double($1.quantity) ?? 0) }
        let totalWeight = calculateTotalWeight()
        
        return totalWeight > 0 ? (composted / totalWeight) * 100 : 0
    }

    private func calculateEWastePercentage() -> Double {
        let ewaste = disposalDataModel.oldEntries.filter { $0.disposalMethod == "E-Waste" }
            .reduce(0) { $0 + (Double($1.quantity) ?? 0) }
        let totalWeight = calculateTotalWeight()
        
        return totalWeight > 0 ? (ewaste / totalWeight) * 100 : 0
    }

    private func calculateHazardousWastePercentage() -> Double {
        let hazardous = disposalDataModel.oldEntries.filter { $0.disposalMethod == "Hazardous" }
            .reduce(0) { $0 + (Double($1.quantity) ?? 0) }
        let totalWeight = calculateTotalWeight()
        
        return totalWeight > 0 ? (hazardous / totalWeight) * 100 : 0
    }

    private func calculateIncinerationPercentage() -> Double {
        let incineration = disposalDataModel.oldEntries.filter { $0.disposalMethod == "Incineration" }
            .reduce(0) { $0 + (Double($1.quantity) ?? 0) }
        let totalWeight = calculateTotalWeight()
        
        return totalWeight > 0 ? (incineration / totalWeight) * 100 : 0
    }

    private func calculateDonationPercentage() -> Double {
        let donation = disposalDataModel.oldEntries.filter { $0.disposalMethod == "Donation" }
            .reduce(0) { $0 + (Double($1.quantity) ?? 0) }
        let totalWeight = calculateTotalWeight()
        
        return totalWeight > 0 ? (donation / totalWeight) * 100 : 0
    }


    var levelAndBadgesSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Your Level & Badges")
                .font(.headline)

            HStack {
                Text("Level: \(currentLevel().name)")
                    .font(.title)
                infoButton("Your level reflects the amount of waste you have diverted. Higher levels mean greater contributions to sustainability.")
            }

            ProgressView(value: currentLevel().progress, total: currentLevel().threshold)
                .accentColor(Color(hex: "#154F39"))
                .padding()

            Text("Unlocked Badges")
                .font(.headline)
                .padding(.bottom, 5)

            HStack {
                ForEach(earnedBadges(), id: \.badge) { badgeInfo in
                    BadgeView(badge: badgeInfo.badge,
                              requiredAmount: badgeInfo.requiredAmount,
                              userAmount: badgeInfo.userAmount,
                              locked: badgeInfo.userAmount < badgeInfo.requiredAmount) {
                        popoverText = "\(badgeInfo.badge): Awarded for diverting \(Int(badgeInfo.requiredAmount)) lbs of waste. You have diverted \(Int(badgeInfo.userAmount)) lbs so far."
                        showingPopover = true
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
        .padding(.bottom, 20)
    }


    var disposalHistorySection: some View {
        Section(header: Text("Previous Disposal Items")
                    .font(.system(size: 23, weight: .semibold))
                    .foregroundColor(Color(hex: "#154F39"))) {
            List {
                ForEach(disposalDataModel.oldEntries, id: \.date) { entry in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(entry.itemName)
                            .font(.headline)
                            .foregroundColor(.primary)

                        Text("Method: \(entry.disposalMethod)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Text("Quantity: \(entry.quantity) \(entry.quantityType == "Number of Items" ? "items" : "lbs")")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Text("Date: \(formattedDate(entry.date))")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(12)
                    .shadow(radius: 1)
                }
                .listRowInsets(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
            }
            .listStyle(PlainListStyle())
            .frame(height: 400)
        }
    }


    private func calculateDiversionRate() -> Double {
        let recycled = disposalDataModel.oldEntries.filter { $0.disposalMethod == "Recycle" }.reduce(0) { $0 + (Double($1.quantity) ?? 0) }
        let composted = disposalDataModel.oldEntries.filter { $0.disposalMethod == "Compost" }.reduce(0) { $0 + (Double($1.quantity) ?? 0) }
        let totalWeight = calculateTotalWeight()

        if totalWeight == 0 {
            return 0
        }

        return ((recycled + composted) / totalWeight) * 100
    }

    private func calculateTotalWeight() -> Double {
        return disposalDataModel.oldEntries.reduce(0) { $0 + (Double($1.quantity) ?? 0) }
    }

    private func currentLevel() -> (name: String, progress: Double, threshold: Double) {
        let total = totalDiverted()
        switch total {
        case 0..<50:
            return ("Novice Recycler", total, 20)
        case 50..<100:
            return ("Eco Learner", total - 20, 100)
        case 100..<200:
            return ("Eco Warrior", total - 100, 200)
        case 200..<500:
            return ("Sustainability Star", total - 200, 500)
        default:
            return ("Eco Champion", total - 500, 1000)
        }
    }

    private func totalDiverted() -> Double {
        let recycledWeight = disposalDataModel.oldEntries
            .filter { $0.disposalMethod == "Recycle" }
            .reduce(0) { result, entry in
                (Double(entry.quantity) ?? 0) + result
            }

        let compostedWeight = disposalDataModel.oldEntries
            .filter { $0.disposalMethod == "Compost" }
            .reduce(0) { result, entry in
                (Double(entry.quantity) ?? 0) + result
            }

        return recycledWeight + compostedWeight
    }

    private func earnedBadges() -> [(badge: String, requiredAmount: Double, userAmount: Double)] {
        let total = totalDiverted()
        var badges: [(String, Double, Double)] = []

        if total >= 20 { badges.append(("Eco Learner Badge", 20, total)) }
        if total >= 100 { badges.append(("Eco Warrior Badge", 100, total)) }
        if total >= 200 { badges.append(("Sustainability Star Badge", 200, total)) }
        if total >= 500 { badges.append(("Eco Champion Badge", 500, total)) }

        return badges
    }

    private func infoButton(_ description: String) -> some View {
        Button(action: {
            popoverText = description
            showingPopover = true
        }) {
            Image(systemName: "questionmark.circle")
                .foregroundColor(Color(hex: "#154F39"))
        }
        .buttonStyle(BorderlessButtonStyle())
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}



struct WasteDistributionPieChart: View {
    let recycledPercentage: Double
    let compostedPercentage: Double
    let ewastePercentage: Double
    let hazardousPercentage: Double
    let incinerationPercentage: Double
    let donationPercentage: Double
    let landfillPercentage: Double
    let totalWeight: Double

    var body: some View {
        VStack {
            if totalWeight == 0 {
               
                Text("No data available")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .frame(height: 120)
            } else {
               
                GeometryReader { geometry in
                    ZStack {
                        PieSliceView(startAngle: .degrees(0), endAngle: .degrees(recycledPercentage * 360))
                            .fill(Color(hex: "#A7C3A8"))  // Darker green for Recycled
                        PieSliceView(startAngle: .degrees(recycledPercentage * 360), endAngle: .degrees((recycledPercentage + compostedPercentage) * 360))
                            .fill(Color(hex: "#C3E1C9"))  // Darker mint green for Composted
                        PieSliceView(startAngle: .degrees((recycledPercentage + compostedPercentage) * 360), endAngle: .degrees((recycledPercentage + compostedPercentage + ewastePercentage) * 360))
                            .fill(Color(hex: "#D6B3A0"))  // Slightly darker beige for E-Waste
                        PieSliceView(startAngle: .degrees((recycledPercentage + compostedPercentage + ewastePercentage) * 360), endAngle: .degrees((recycledPercentage + compostedPercentage + ewastePercentage + hazardousPercentage) * 360))
                            .fill(Color(hex: "#C7E4D6"))  // Darker greenish-blue for Hazardous Waste
                        PieSliceView(startAngle: .degrees((recycledPercentage + compostedPercentage + ewastePercentage + hazardousPercentage) * 360), endAngle: .degrees((recycledPercentage + compostedPercentage + ewastePercentage + hazardousPercentage + incinerationPercentage) * 360))
                            .fill(Color(hex: "#BFB1C2"))  // Purple-gray for Incineration
                        PieSliceView(startAngle: .degrees((recycledPercentage + compostedPercentage + ewastePercentage + hazardousPercentage + incinerationPercentage) * 360), endAngle: .degrees((recycledPercentage + compostedPercentage + ewastePercentage + hazardousPercentage + incinerationPercentage + donationPercentage) * 360))
                            .fill(Color(hex: "#C0C4AE"))  // Darker moss green for Donation
                        PieSliceView(startAngle: .degrees((recycledPercentage + compostedPercentage + ewastePercentage + hazardousPercentage + incinerationPercentage + donationPercentage) * 360), endAngle: .degrees(360))
                            .fill(Color(hex: "#E3CAB8"))  // Light beige for Landfill
                    }
                    .frame(width: geometry.size.width * 0.35, height: geometry.size.width * 0.35) // Reduced size
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)  // Centering the pie chart
                }
                .frame(height: 120)
            }

        
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Label {
                        Text("Recycled")
                            .foregroundColor(.black)
                    } icon: {
                        Image(systemName: "circle.fill")
                            .foregroundColor(Color(hex: "#A7C3A8"))
                    }

                    Label {
                        Text("Composted")
                            .foregroundColor(.black)
                    } icon: {
                        Image(systemName: "circle.fill")
                            .foregroundColor(Color(hex: "#C3E1C9"))
                    }

                    Label {
                        Text("E-Waste")
                            .foregroundColor(.black)
                    } icon: {
                        Image(systemName: "circle.fill")
                            .foregroundColor(Color(hex: "#D6B3A0"))
                    }
                }
                HStack {
                    Label {
                        Text("Hazardous")
                            .foregroundColor(.black)
                    } icon: {
                        Image(systemName: "circle.fill")
                            .foregroundColor(Color(hex: "#C7E4D6"))
                    }

                    Label {
                        Text("Incineration")
                            .foregroundColor(.black)
                    } icon: {
                        Image(systemName: "circle.fill")
                            .foregroundColor(Color(hex: "#BFB1C2"))
                    }

                    Label {
                        Text("Donation")
                            .foregroundColor(.black)
                    } icon: {
                        Image(systemName: "circle.fill")
                            .foregroundColor(Color(hex: "#C0C4AE"))
                    }

                    Label {
                        Text("Landfill")
                            .foregroundColor(.black)
                    } icon: {
                        Image(systemName: "circle.fill")
                            .foregroundColor(Color(hex: "#E3CAB8"))
                    }
                }
            }
            .padding(.top, 5)
        }
    }
}





struct PieSliceView: Shape {
    var startAngle: Angle
    var endAngle: Angle

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        let radius = min(rect.width, rect.height) / 2
        path.move(to: center)
        path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        return path
    }
}

// Badge View
struct BadgeView: View {
    let badge: String
    let requiredAmount: Double
    let userAmount: Double
    var locked: Bool
    var onClick: (() -> Void)?

    var body: some View {
        VStack {
            Image(systemName: locked ? "lock.fill" : "star.fill")
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(Color(hex: "#DACFBB"))
                .onTapGesture {
                    onClick?()
                }

            Text(badge)
                .font(.caption)
        }
    }
}
