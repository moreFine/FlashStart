//
//  DragDropView.swift
//  FlashStart
//
//  Created by wangwei on 2019/2/12.
//  Copyright © 2019 wangwei. All rights reserved.
//

import Cocoa

class DragDropView: NSView {
    var dragDropFileURLs:(([URL]) -> ())?
    private var allowDrag = false {
        didSet {
            needsDisplay = true
        }
    }
    private let acceptableTypes: [NSPasteboard.PasteboardType] = [NSPasteboard.PasteboardType.fileURL]
    private let filteringOptions = [NSPasteboard.ReadingOptionKey.urlReadingFileURLsOnly:true]
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect);
        configure()
    }
   
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        configure()
        
    }
   
    private func configure(){
        registerForDraggedTypes(acceptableTypes)
        self.wantsLayer = true
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        if allowDrag {
            NSColor.selectedControlColor.set()
            let path = NSBezierPath(rect: bounds)
            path.lineWidth = 10;
            path.stroke()
        }
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        print("拖拽到范围内")
        let pasteboard = sender.draggingPasteboard
        if pasteboard.canReadObject(forClasses: [NSURL.self], options: filteringOptions) {
            allowDrag = true
            return .copy
        }
        return NSDragOperation()
    }
   
    override func draggingExited(_ sender: NSDraggingInfo?) {
        allowDrag = false;
        print("拖拽出去")
    }
   
    override func draggingEnded(_ sender: NSDraggingInfo) {
        allowDrag = false;
        print("拖拽结束")
    }
    
    //鼠标在拖拽视图内部释放时调用
    override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let pasteboard = sender.draggingPasteboard
        if pasteboard.canReadObject(forClasses: [NSURL.self], options: filteringOptions) {
            return true
        }
        return false
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        allowDrag = false;
        let pasteBoard = sender.draggingPasteboard
        if let urls = pasteBoard.readObjects(forClasses: [NSURL.self], options:filteringOptions) as? [URL], urls.count > 0  {
            print(urls.first?.path ?? "解包失败")
            self.dragDropFileURLs?(urls)
            return true
        }
        return false
    }
}
