//
//  StBleSensorDelegate.swift
//  flutter_st_ble_sensor
//
//  Created by barry on 2023/5/31.
//

import Foundation
import Flutter
import BlueSTSDK_Gui
import BlueSTSDK

public class StBleSensorDelegate {
  
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "startScan":
      startScan()
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
  
  private func startScan(){
    let storyboard = UIStoryboard(name: "BlueSTSDKMainView", bundle: BlueSTSDK_Gui.bundle())
    let nodeListViewController = storyboard.instantiateViewController(withIdentifier: "NodeListViewController") as? BlueSTSDKNodeListViewController
    nodeListViewController?.delegate = self
    if let vc = nodeListViewController {
      if let topVC = UIApplication.shared.keyWindow?.rootViewController {
        if let navVC = topVC.navigationController {
          navVC.pushViewController(vc, animated: true)
        } else {
          
          //          let navigationController = UINavigationController(rootViewController: vc)
          //          UIApplication.shared.keyWindow?.rootViewController = navigationController
          //          UIApplication.shared.keyWindow?.makeKeyAndVisible()
          
          topVC.present(vc, animated: true, completion: nil)
        }
      }
    }
  }
  
  /**
   *  when the user select a node show the main view form the DemoView storyboard
   *
   *  @param node node selected
   *
   *  @return controller with the demo to show
   */
  public func demoViewController(with node: BlueSTSDKNode, menuManager: BlueSTSDKViewControllerMenuDelegate) -> UIViewController? {
    return BlueSTSDKFwUpgradeManagerViewController.instaziate(forNode: node,
                                                              requireAddress: false,
                                                              defaultAddress:nil)
    
  }
}


extension StBleSensorDelegate : BlueSTSDKNodeListViewControllerDelegate {
  public func display(node: BlueSTSDKNode) -> Bool {
    return true;
  }
  
  public func prepareToConnect(node:BlueSTSDKNode){
    node.addExternalCharacteristics(BlueSTSDKStdCharToFeatureMap.getManageStdCharacteristics())
    node.addExternalCharacteristics(BlueSTSDKSTM32WBOTAUtils.getOtaCharacteristics())
    node.addExternalCharacteristics(BlueNRGOtaUtils.getOtaCharacteristics())
    if(STM32WBPeer2PeerDemoConfiguration.isValidDeviceNode(node)){
      node.addExternalCharacteristics(STM32WBPeer2PeerDemoConfiguration.getCharacteristicMapping())
    }
    if(node.type == .sensor_Tile_Box ){
      //          showStBoxPinAllert()
    }
  }
  
  public var advertiseFilters: [BlueSTSDKAdvertiseFilter]{
    get{
      //if a board is compatible with multiple advertise, give the precedence to the sdk format
      return  BlueSTSDKManager.DEFAULT_ADVERTISE_FILTER + [ BlueNRGOtaAdvertiseParser() ]
    }
  }
}


