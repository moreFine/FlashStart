//
//  CollectionItem.swift
//  FlashStart
//
//  Created by wangwei on 2019/2/19.
//  Copyright © 2019 wangwei. All rights reserved.
//

import Cocoa

class CollectionItem:  NSCollectionViewItem {
   
    var deleteFileURLAction:(() -> ())?
    var openFileURLAction:(() -> ())?
    var copyFileURLAction:(() -> ())?
    var mouseDoubleClicked:(() -> ())?
    var fileMenu:NSMenu? = nil
    @IBOutlet weak var fileName: NSTextField!
    @IBOutlet weak var fileTyple: NSTextField!
    @IBOutlet weak var iconImageView: NSImageView!
    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        if event.clickCount > 1 {
            //双击
            if mouseDoubleClicked != nil {
                self.mouseDoubleClicked!()
            }
        } else {
            
        }
    }
    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        print("鼠标进入区域")
    }
    override func mouseExited(with event: NSEvent) {
        super.mouseEntered(with: event)
        print("鼠标离开区域")
    }
    override func rightMouseDown(with event: NSEvent) {
        super.rightMouseDown(with: event)
        let rightMenu:NSMenu = NSMenu(title: "菜单")
        self.fileMenu = rightMenu
        rightMenu.autoenablesItems = true
        
        let menuItem1:NSMenuItem = NSMenuItem(title: "打开", action: #selector(self.menuItemOpenAction), keyEquivalent:  "")
        let menuItem2:NSMenuItem = NSMenuItem(title: "删除此快捷关联", action: #selector(self.menuItemDeleteAction), keyEquivalent:  "")
        let menuItem3:NSMenuItem = NSMenuItem(title: "取消", action: #selector(self.menuItemCancelAction), keyEquivalent:  "")
        let menuItem4:NSMenuItem = NSMenuItem(title: "复制全路径", action: #selector(self.menuItemCopyPathAction), keyEquivalent:  "")
        let detailAddressItem:NSMenuItem = NSMenuItem(title: self.fileName.stringValue, action: nil, keyEquivalent: "")
        
        menuItem1.isEnabled = true
        menuItem1.target = self
        menuItem2.isEnabled = true
        menuItem2.target = self
        menuItem3.isEnabled = true
        menuItem3.target = self
        menuItem4.isEnabled = true
        menuItem4.target = self
        detailAddressItem.isEnabled = false;
        
        rightMenu.addItem(menuItem1)
        rightMenu.addItem(menuItem2)
        rightMenu.addItem(menuItem3)
        rightMenu.addItem(menuItem4)
        rightMenu.addItem(detailAddressItem)
        
        rightMenu.popUp(positioning: rightMenu.item(at: 0), at: NSEvent.mouseLocation, in: nil)
    }
   
    @objc final func menuItemDeleteAction(){
        if deleteFileURLAction != nil {
            self.deleteFileURLAction!()
        }
    }
   
    @objc final func menuItemOpenAction(){
        if self.openFileURLAction != nil {
           self.openFileURLAction!()
        }
    }
    
    @objc final func menuItemCopyPathAction(){
        if self.copyFileURLAction != nil {
           self.copyFileURLAction!()
        }
    }
   
    @objc final func menuItemCancelAction(){
        self.fileMenu?.removeAllItems()
    }
}
