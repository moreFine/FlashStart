//
//  ViewController.swift
//  FlashStart
//
//  Created by wangwei on 2019/2/12.
//  Copyright © 2019 wangwei. All rights reserved.
//

import Cocoa

class ViewController: NSViewController,NSCollectionViewDelegate,NSCollectionViewDataSource{
    let reuse = NSUserInterfaceItemIdentifier("CollectionViewItem")
    @IBOutlet weak var tipLabel: NSTextField!
    @IBOutlet weak var dragDropView: DragDropView!
    @IBOutlet weak var collectionView: NSCollectionView!
    @IBOutlet weak var tipsHub: NSTextField!
    
    var filePaths:[String]? = []{
        didSet {
            tipLabel.isHidden = (filePaths?.count)! > 0 ? true : false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.frame = CGRect.init(x: 0, y: 0, width: 800, height: 600)
        self.filePaths = UserDefaults.standard.object(forKey: "filePaths") as? [String] ?? []
        self.dragDropView.dragDropFileURLs = {urls in
            for url:URL in urls{
                if !self.filePaths!.contains(url.path)  && !url.path.contains("替身"){
                    self.filePaths?.append(url.path)
                    do {
                        let boolMarkData:NSData = try url.bookmarkData(options: URL.BookmarkCreationOptions.withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil) as NSData
                        UserDefaults.standard.set(boolMarkData, forKey: url.path.components(separatedBy: "/").last!)
                    } catch{
                        print("保存bookmarkdata失败")
                    }
                }
            }
            UserDefaults.standard.set(self.filePaths, forKey: "filePaths")
            self.collectionView.reloadData()
        }
        self.creatUI()
    }
    
    final private func creatUI(){
        let flowLayout = NSCollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.itemSize = NSSize(width: 110.0, height: 90.0)
        flowLayout.sectionInset = NSEdgeInsets(top: 10.0, left: 20.0, bottom: 10.0, right: 20.0)
        flowLayout.minimumInteritemSpacing = 5.0
        flowLayout.minimumLineSpacing = 5.0
        self.collectionView.collectionViewLayout = flowLayout
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.isSelectable = true
        collectionView.register(NSNib.init(nibNamed: "CollectionItem", bundle:nil), forItemWithIdentifier: reuse)
        
        self.tipsHub.isEditable = false
        self.tipsHub.isHidden = true
        self.tipsHub.alignment = .center
        self.tipsHub.backgroundColor = NSColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        self.tipsHub.textColor = NSColor.white
        self.tipsHub.wantsLayer = true;
    }

    func showTipsHub(content:String)  {
        self.tipsHub.stringValue = content
        self.tipsHub.isHidden = false
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self](timer) in
            self?.tipsHub.isHidden = true;
        }
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return filePaths?.count ?? 0
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item:CollectionItem = collectionView.makeItem(withIdentifier: reuse, for: indexPath) as! CollectionItem
        
        let filePath = filePaths?[indexPath.item] ?? ""
        item.fileName.stringValue = filePath.components(separatedBy: "/").last ?? ""
        item.deleteFileURLAction = {
            self.filePaths?.remove(at: indexPath.item)
            self.collectionView.reloadData()
            UserDefaults.standard.set(self.filePaths, forKey: "filePaths")
        }
        item.openFileURLAction = {[weak self] in
            let filePath = self?.filePaths?[indexPath.item] ?? ""
            NSWorkspace.shared.openFile(filePath)
        }
        item.copyFileURLAction = {[unowned self] in
            let paste:NSPasteboard = NSPasteboard.general
            paste.clearContents()
            paste.writeObjects([filePath as NSPasteboardWriting])
        }
        item.mouseDoubleClicked = {[unowned self] in
            item.view.layer?.backgroundColor = NSColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0).cgColor
            let bookMarkData:NSData = UserDefaults.standard.object(forKey: filePath.components(separatedBy: "/").last!) as! NSData
            var bookmarkDataIsStale:Bool = false
            do {
                let allowURL:URL = try URL(resolvingBookmarkData: bookMarkData as Data, options: URL.BookmarkResolutionOptions(rawValue: URL.BookmarkResolutionOptions.withSecurityScope.rawValue | URL.BookmarkResolutionOptions.withoutUI.rawValue), relativeTo:nil, bookmarkDataIsStale: &bookmarkDataIsStale)
                let _ = allowURL.startAccessingSecurityScopedResource()
                let result:Bool  = NSWorkspace.shared.openFile(filePath)
                if (!result){
                    //打开文件失败
                    self.showTipsHub(content: "快捷路径已失效，自动将其删除")
                    self.filePaths?.remove(at: indexPath.item)
                    UserDefaults.standard.set(self.filePaths, forKey: "filePaths")
                    self.collectionView.reloadData()
                }
                allowURL.stopAccessingSecurityScopedResource()
            } catch  {
                print("获取权限错误")
            }
        }
        //        item.view.wantsLayer = true
        //        item.view.layer?.backgroundColor = NSColor.orange.cgColor
        return item
    }
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        let item:NSCollectionViewItem = collectionView.item(at: indexPaths.first!)!
        item.view.layer?.backgroundColor = NSColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.2).cgColor
    }
   
    func collectionView(_ collectionView: NSCollectionView, didDeselectItemsAt indexPaths: Set<IndexPath>) {
        let item:NSCollectionViewItem = collectionView.item(at: indexPaths.first!)!
        item.view.layer?.backgroundColor = NSColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0).cgColor
    }

}

