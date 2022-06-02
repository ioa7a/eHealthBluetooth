//
//  ViewController.swift
//  eHealthBluetooth
//
//  Created by Ioana Bojinca on 01.06.2022.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    @IBOutlet weak var activityindicatorView: UIActivityIndicatorView!
    @IBOutlet weak var dataTitleLabel: UILabel!
    @IBOutlet weak var distanceTitleLabel: UILabel!
    @IBOutlet weak var dataLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var startScanButton: UIButton!
    
    var centralManager: CBCentralManager!
    var myPeripheral: CBPeripheral!
    let heartRateServiceCBUUID = CBUUID(string: "0x180D")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataLabel.text = "_ _ _"
        self.distanceLabel.text = "_ _ _"
        self.activityindicatorView.isHidden = true
        self.startScanButton.layer.cornerRadius = 10
    }
    
    @IBAction func didPressStartScan(_ sender: Any) {
        self.activityindicatorView.startAnimating()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("central.state is .unknown")
        case .resetting:
            print("central.state is .resetting")
        case .unsupported:
            print("central.state is .unsupported")
        case .unauthorized:
            print("central.state is .unauthorized")
        case .poweredOff:
            print("central.state is .poweredOff")
        case .poweredOn:
            print("central.state is .poweredOn")
            centralManager.scanForPeripherals(withServices: nil)
        @unknown default:
            print("central.state is unknown")
            
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any], rssi RSSI: NSNumber) {
        print(peripheral)
        
        // get the first peripheral with a name
        if let name = peripheral.name {
            myPeripheral = peripheral
            centralManager.connect(myPeripheral)
            myPeripheral.delegate = self
            centralManager.stopScan()
            dataLabel.text = name
            let distance = calculateDistance(from: RSSI)
            let distanceString = String(format: "%.2f", distance)
            distanceLabel.text = "approx. \(distanceString) m\nProximity: "
            switch distance {
            case _ where distance < -80:
                distanceLabel.text?.append("Far")
            case _ where distance > -50:
                distanceLabel.text?.append("Immediate")
            case _ where distance >= -80 || distance <= -50:
                distanceLabel.text?.append("Near")
            default:
                distanceLabel.text?.append("Unknown")
            }
            self.activityindicatorView.stopAnimating()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected!")
        myPeripheral.discoverServices([heartRateServiceCBUUID])
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        
        for service in services {
            print(service)
        }
    }
    
    func calculateDistance(from RSSI: NSNumber) -> Double {
        return pow(10, ((-56-Double(truncating: RSSI))/(10*2)))*3.2808
    }
}

