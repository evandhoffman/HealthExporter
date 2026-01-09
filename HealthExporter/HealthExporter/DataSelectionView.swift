import SwiftUI

struct DataSelectionView: View {
    @State private var exportWeight = true
    @State private var showingExporter = false
    @State private var csvContent = ""
    
    let healthManager = HealthKitManager()

    var body: some View {
        VStack {
            Text("Select Data to Export")
                .font(.largeTitle)
                .padding()
            
            Toggle(isOn: $exportWeight) {
                Text("Weight")
            }
            .padding()
            
            Spacer()
            
            Button(action: {
                exportData()
            }) {
                Text("Export...")
                    .font(.title)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .padding()
        .sheet(isPresented: $showingExporter) {
            DocumentExporter(csvContent: csvContent, fileName: "weight_data.csv")
        }
    }
    
    private func exportData() {
        healthManager.requestAuthorization { success, error in
            if success {
                healthManager.fetchWeightData { samples, error in
                    if let samples = samples {
                        csvContent = CSVGenerator.generateWeightCSV(from: samples)
                        showingExporter = true
                    } else {
                        print("Error fetching data: \(error?.localizedDescription ?? "Unknown error")")
                    }
                }
            } else {
                print("Authorization failed: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
}

struct DataSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        DataSelectionView()
    }
}