//
//  ViewController.swift
//  SerialCommunication
//
//  Created by Sandeep on 21/04/21.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController {
    
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var activityLabel: UILabel!
    @IBOutlet weak var scanButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var centralManager: CBCentralManager!
    var connectedPeripheral: CBPeripheral!
    var discoveredPeripherals  = [CBPeripheral]()
    var isScanning : Bool = false
    var deviceCount : Int = 0
    var isConnected : Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.stateLabel.text = ""
        self.activityLabel.text = ""
        centralManager = CBCentralManager(delegate: self, queue: nil)
        centralManager.stopScan()
        self.scanButton.setTitle("Start Scan", for: .normal)
    }
    func connect(peripheral : CBPeripheral) {
        centralManager.connect(peripheral, options: nil)
        self.activityLabel.text = "Connecting to..." + (peripheral.name ?? "Error")
        centralManager.stopScan()
    }
    
    func disconnect(peripheral : CBPeripheral){
        self.activityLabel.text = "Disconnecting..." + (peripheral.name ?? "Error")
        centralManager.cancelPeripheralConnection(peripheral)
    }
    
    @IBAction func didTapScanButton(_ sender: Any) {
        isScanning.toggle()
        if !isScanning {
            scanButton.setTitle("Start Scan", for: .normal)
            centralManager.stopScan()
            self.tableView.reloadData()
        }else{
            discoveredPeripherals.removeAll()
            self.deviceCount = 0
            self.tableView.reloadData()
            scanButton.setTitle("Stop Scan", for: .normal)
            if centralManager.state == .poweredOn {
//                centralManager.scanForPeripherals(withServices : nil)
                centralManager.scanForPeripherals(withServices: nil,options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])

            }else{
                self.stateLabel.text = "Please switch on the bluetooth to scan devices!"
            }
            
        }
    }
    
}

extension ViewController: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
          case .unknown:
            stateLabel.text = "central.state is .unknown"
          case .resetting:
            stateLabel.text = "central.state is .resetting"
          case .unsupported:
            stateLabel.text = "central.state is .unsupported"
          case .unauthorized:
            stateLabel.text = "central.state is .unauthorized"
          case .poweredOff:
            stateLabel.text = "central.state is .poweredOff"
          case .poweredOn:
            stateLabel.text = "central.state is .poweredOn"
          @unknown default :
            stateLabel.text = "Unknown"
        }
    }
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        self.discoveredPeripherals.append(peripheral)
        self.tableView.beginUpdates()
        self.tableView.insertRows(at: [IndexPath(row: deviceCount, section: 0)], with: .automatic)
        self.tableView.endUpdates()
        self.deviceCount = self.deviceCount + 1
    }
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("connected!")
        self.isConnected = true
        self.activityLabel.text = "Connected to..." + (peripheral.name ?? "Unknown")
        self.connectedPeripheral = peripheral
        self.connectedPeripheral.delegate = self
        print(self.connectedPeripheral.discoverServices(nil))
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Failed to connect")
        self.activityLabel.text = "Failed to Connect!"
    }
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if let error = error {
            self.activityLabel.text = error.localizedDescription
            return
        }
        self.activityLabel.text = "Peripheral disconnected successfully!"
    }
    
}

extension ViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.discoveredPeripherals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: "TableCell") as? TableCell else {
            return UITableViewCell()
        }
        cell.setData(name: self.discoveredPeripherals[indexPath.row].name ?? "Unknown")
        return cell as UITableViewCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let peri = discoveredPeripherals[indexPath.row]
        self.isConnected.toggle()
        if !isConnected {
            self.disconnect(peripheral: peri)
            return
        }
        self.connect(peripheral: peri)
    }
    
}

extension ViewController : CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print(peripheral.services)
    }
}


