//
//  BlueMSMainViewController.swift
//  flutter_st_ble_sensor
//
//  Created by barry on 2023/6/1.
//

import Foundation
import BlueSTSDK_Gui
import BlueSTSDK

public class BlueMSMainViewController : BlueSTSDKMainViewController {
  
}


extension BlueMSMainViewController : BlueSTSDKNodeListViewControllerDelegate {
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
