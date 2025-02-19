import SwiftUI
import Foundation


struct TrackingDataView: View {
    @State private var itemName: String = ""
    @State private var disposalMethod: String = "Recycle"
    @State private var quantityType: String = "Number of Items"
    @State private var quantity: String = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""

    @EnvironmentObject var disposalDataModel: DisposalDataModel
    @EnvironmentObject var chatController: ChatController
    
    
    let disposalMethods = ["Recycle", "Compost", "Trash", "Hazardous Waste", "E-Waste", "Incineration", "Donation"]
    let firstRowMethods = ["Recycle", "Compost", "Trash", "Hazardous Waste"]
    let secondRowMethods = ["E-Waste", "Incineration", "Donation"]
    let quantityTypes = ["Number of Items", "Weight (in lbs)"]

    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 10) {
                Text("Disposal Log")
                    .font(.system(size: 40))
                    .fontWeight(.bold)
                    .padding(.top, 30)
            }
            Form {
                Section(header: Text("Add Disposal Item")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color(hex1: "#154F39"))) {
                    TextField("Item Name", text: $itemName)
                        .padding(10)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(8)
                    
                    
                    VStack {
                        Picker("Disposal Method", selection: $disposalMethod) {
                            ForEach(firstRowMethods, id: \.self) { method in
                                Text(method)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.vertical)

                        
                        Picker("Disposal Method", selection: $disposalMethod) {
                            ForEach(secondRowMethods, id: \.self) { method in
                                Text(method)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding(.horizontal, 30)
                        .padding(.vertical)
                    }

                    Picker("Quantity Type", selection: $quantityType) {
                        ForEach(quantityTypes, id: \.self) { type in
                            Text(type)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.vertical)

                    TextField(quantityType == "Number of Items" ? "Quantity" : "Weight (in lbs)", text: $quantity)
                        .keyboardType(.decimalPad)
                        .padding(10)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(8)
                    
                    Button(action: {
                        addEntry()
                    }) {
                        Text("Add to Log")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .shadow(radius: 3)
                    }
                }
                
                Section(header: Text("Previous Entries")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color(hex1: "#154F39"))) {
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
                                
                                HStack {
                                    Button(action: {
                                        editEntry(entry: entry)
                                    }) {
                                        Text("Edit")
                                            .font(.caption)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 5)
                                            .background(Color(hex1: "#154F39"))
                                            .foregroundColor(.white)
                                            .cornerRadius(5)
                                    }
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        deleteEntry(entry: entry)
                                    }) {
                                        Text("Delete")
                                            .font(.caption)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 5)
                                            .background(Color(hex: "#154F39"))
                                            .foregroundColor(.white)
                                            .cornerRadius(5)
                                    }
                                }
                            }
                            .padding(.vertical, 5)
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(8)
                            .shadow(radius: 1)
                        }
                    }
                }
            }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Disposal Information"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
        .navigationBarTitle(Text("Track Disposal"), displayMode: .inline)
        .padding(.bottom, 10)
    }
    
    private func addEntry() {
        if quantityType == "Number of Items" {
            chatController.getItemWeight(for: itemName) { estimatedWeightString in
                if let estimatedWeight = Double(estimatedWeightString), let itemCount = Double(quantity) {
                    let totalWeight = estimatedWeight * itemCount
                    disposalDataModel.addEntry(
                        itemName: itemName,
                        disposalMethod: disposalMethod,
                        quantity: String(totalWeight),
                        quantityType: "Weight (in lbs)",
                        date: Date()
                    )
                    clearFields()
                } else {
                    showingAlert = true
                    alertMessage = "Failed to calculate the total weight. Please check the inputs."
                }
            }
        } else {
            disposalDataModel.addEntry(
                itemName: itemName,
                disposalMethod: disposalMethod,
                quantity: quantity,
                quantityType: quantityType,
                date: Date()
            )
            clearFields()
        }
    }
    
    private func editEntry(entry: (itemName: String, disposalMethod: String, quantity: String, quantityType: String, date: Date)) {
        itemName = entry.itemName
        disposalMethod = entry.disposalMethod
        quantity = entry.quantity
        quantityType = entry.quantityType
        disposalDataModel.oldEntries.removeAll { $0.date == entry.date }
    }

    private func deleteEntry(entry: (itemName: String, disposalMethod: String, quantity: String, quantityType: String, date: Date)) {
        disposalDataModel.deleteEntry(entry: entry)
    }

    private func clearFields() {
        itemName = ""
        quantity = ""
        disposalMethod = "Recycle"
        quantityType = "Number of Items"
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct TrackingDataView_Previews: PreviewProvider {
    static var previews: some View {
        TrackingDataView()
            .environmentObject(DisposalDataModel())
            .environmentObject(ChatController())
    }
}

extension Color {
    init(hex1: String) {
        let scanner = Scanner(string: hex1)
        scanner.currentIndex = scanner.string.startIndex
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = Double(rgbValue & 0x0000FF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}
