//
//  MediaListViewController.swift
//  iTunesReader
//
//  Created by Ignacio on 20/7/18.
//  Copyright © 2018 Ignacio. All rights reserved.
//

import UIKit
import AVKit

class MediaListViewController: UIViewController {

    @IBOutlet var artistTextField: UITextField!
    @IBOutlet var mediaPickerTextField: UITextField!
    @IBOutlet var tableView: UITableView!
    
    var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    let connectionManager : MediaConnectionManager = MediaConnectionManager.sharedInstance
    let pickerView = UIPickerView()
    var toolBar = UIToolbar()
    let pickerData = ["Music", "Tv Show", "Movie"]
    var resultArray : NSArray = []
    
    let kMusicMediaString = "Music"
    let kTvShowMediaString = "Tv Show"
    let kMovieMediaString = "Movie"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.hidesWhenStopped = true;
        activityIndicator.activityIndicatorViewStyle  = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        activityIndicator.frame = view.bounds
        
        tableView.delegate = self
        tableView.dataSource = self
        
        NotificationCenter.default.addObserver(forName: .searchResult, object: nil, queue: OperationQueue.main) { (notification) in
            self.handleRequestResult(notification: notification)
        }
        
        setUpPickerView()
        setUpToolBar()
    }
    
    func setUpPickerView() {
        
        pickerView.delegate = self
        
        mediaPickerTextField.inputView = pickerView
    }
    
    func setUpToolBar() {
        toolBar = UIToolbar(frame: CGRect(x:0, y:0, width:320, height:44))
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(MediaListViewController.hidePickerView))
        toolBar.items = [doneButton]
        mediaPickerTextField.inputAccessoryView = toolBar
    }
    
    @objc func hidePickerView() {
        pickerView.removeFromSuperview()
        toolBar.removeFromSuperview()
        mediaPickerTextField.resignFirstResponder()
        
        if artistTextField.text == "" {
            print("You must write an artist")
            let alert = UIAlertController(title: "Error", message: "You must write an artist", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            activityIndicator.startAnimating()
            
            connectionManager.requestMediaForArtist(artist: artistTextField.text!, media: mediaPickerTextField.text!)
        }
        
    }
    
    func handleRequestResult(notification: Notification) {
        self.resultArray = notification.object as! NSArray
        activityIndicator.stopAnimating()
        if self.resultArray.count == 0 {
            let alert = UIAlertController(title: "Warning", message: "No results", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        tableView.reloadData()
    }

}

extension MediaListViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        mediaPickerTextField.text = pickerData[row]
        return pickerData[row]
    }
}

extension MediaListViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as!MediaTableViewCell
        let searchResultDic: Dictionary <String, Any> = resultArray[indexPath.row] as! Dictionary
        print(resultArray)
        
        clearCell(cell: cell)
        
        let imageURL = URL(string: (searchResultDic["artworkUrl100"] as? String)!)
        let data = try? Data(contentsOf: imageURL!)
        cell.mediaArtwork.image = UIImage(data: data!)
        
        if mediaPickerTextField.text == kMusicMediaString {
            cell.titleLabel?.text = searchResultDic["trackName"] as? String
            cell.subtitleLabel?.text = searchResultDic["artistName"] as? String
        } else if mediaPickerTextField.text == kMovieMediaString {
            cell.titleLabel?.text = searchResultDic["trackName"] as? String
            cell.descriptionLabel?.text = searchResultDic["longDescription"] as? String
        } else if mediaPickerTextField.text == kTvShowMediaString {
            cell.titleLabel?.text = searchResultDic["artistName"] as? String
            cell.subtitleLabel?.text = searchResultDic["trackName"] as? String
            cell.descriptionLabel?.text = searchResultDic["longDescription"] as? String
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let searchResultDic: Dictionary <String, Any> = resultArray[indexPath.row] as! Dictionary
        let mediaURL = URL(string: (searchResultDic["previewUrl"] as? String)!)
        let player = AVPlayer(url: mediaURL!)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func clearCell(cell: MediaTableViewCell) {
        cell.titleLabel?.text = ""
        cell.subtitleLabel?.text = ""
        cell.descriptionLabel?.text = ""
    }
    
}
