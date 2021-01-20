//
//  ViewControllers.swift
//  Final_NHS_App
//
//  Created by Travis Zhang on 7/27/19.
//  Copyright © 2019 Travis Zhang. All rights reserved.
//

import UIKit
import FirebaseDatabase
import WebKit
import SafariServices

var id = "?"
class LoginVC: UIViewController, UITextFieldDelegate{
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var ID: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var ref: DatabaseReference?
    var studentID = String()
    var first = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        returnNumpad();
        self.loginButton.layer.cornerRadius = 6;
        if first
        {
            id = ID.text!
            first = false
        }
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            scrollView.contentInset = .zero
        } else {
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        
        scrollView.scrollIndicatorInsets = scrollView.contentInset
    }

    @IBAction func login()
    {
        ref = Database.database().reference()
        let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating();
        
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
        
        //self.studentID = ID.text!
        id = ID.text!
        var letIn = true;
        
        //Fix check strikes method and ban people with more than 3 strikes
        //Maybe put warning in home VC?
        
        ref?.child("Students").child(id).child("Strikes").observeSingleEvent(of: .value, with: { snapshot in
            if let unwrapped = snapshot.value as? Int {
            print(unwrapped)
            if unwrapped >= 3 {
                print("Check")
                letIn = false;
                let defaultAlert = UIAlertController(title: "Error", message: "You have been banned from NHS", preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                
                defaultAlert.addAction(defaultAction)
                alert.dismiss(animated: true){
                    self.present(defaultAlert, animated: true, completion: nil)
                }
            }
            else
            {
                self.ref?.child("Students").observeSingleEvent(of: .value, with:
                    { snapshot in if(snapshot.hasChild(id)) {
                            print("Present")
                            self.performSegue(withIdentifier: "Login", sender: self)
                        }
                        else {
                            print("Else")
                            let alertController = UIAlertController(title: "Error", message: "Student ID does not exist", preferredStyle: .alert)
                            
                            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                            
                            alertController.addAction(defaultAction)
                            alert.dismiss(animated: true){
                                self.present(alertController, animated: true, completion: nil)
                            }
                        }
                })
            }
        }
        })
        
        dismiss(animated: false, completion: nil)
    }
    
    func returnNumpad()
    {
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.addTarget(self, action: #selector(LoginVC.didTapView))
        self.view.addGestureRecognizer(tapRecognizer)
    }
    
    @objc func didTapView(){
        self.view.endEditing(true)
    }
    
    
    /*override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     let DestUINav = segue.destination as! UINavigationController
     let DestVC = DestUINav.topViewController as! HomeVC
     
     DestVC.id = ID.text!
     }*/
}

class HomeVC: BaseViewController {
    
    @IBOutlet weak var welcome: UITextView!
    @IBOutlet weak var hours: UITextView!
    @IBOutlet weak var strikes: UITextView!
    
    var ref: DatabaseReference?
    @IBOutlet weak var barcode: UIImageView!
    var contentText = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //addLogoutButton()
        addSlideMenuButton()
        greeting()
        //barcode.image = generateBarcode(from: id)
        setupHours()
        setupStrikes()
    }

    func generateBarcode(from string: String) -> UIImage? {
        
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CICode128BarcodeGenerator") {
            filter.setDefaults()
            //Margin
            filter.setValue(7.00, forKey: "inputQuietSpace")
            filter.setValue(data, forKey: "inputMessage")
            //Scaling
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                let context:CIContext = CIContext.init(options: nil)
                let cgImage:CGImage = context.createCGImage(output, from: output.extent)!
                let rawImage:UIImage = UIImage.init(cgImage: cgImage)
                
                let cgimage: CGImage = (rawImage.cgImage)!
                let cropZone = CGRect(x: 0, y: 0, width: Int(rawImage.size.width), height: Int(rawImage.size.height))
                let cWidth: size_t  = size_t(cropZone.size.width)
                let cHeight: size_t  = size_t(cropZone.size.height)
                let bitsPerComponent: size_t = cgimage.bitsPerComponent
                //THE OPERATIONS ORDER COULD BE FLIPPED, ALTHOUGH, IT DOESN'T AFFECT THE RESULT
                let bytesPerRow = (cgimage.bytesPerRow) / (cgimage.width  * cWidth)
                
                let context2: CGContext = CGContext(data: nil, width: cWidth, height: cHeight, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: cgimage.bitmapInfo.rawValue)!
                
                context2.draw(cgimage, in: cropZone)
                
                let result: CGImage  = context2.makeImage()!
                let finalImage = UIImage(cgImage: result)
                
                return finalImage
                
            }
        }
        
        return nil
    }
    
    func greeting()
    {
        ref = Database.database().reference()
        ref?.child("Students").child(id).child("First Name").observeSingleEvent(of: .value, with: {snapshot in
            if let unwrapped = snapshot.value as? String
            {
                self.welcome.text = "Hello " + unwrapped + "!";
            }
        })
    }
    
    func setupHours()
    {
        ref = Database.database().reference()
        ref?.child("Students").child(id).child("Hours").observe(.value, with: {snapshot in
            if let unwrapped = snapshot.value as? Double
            {
                self.hours.text = "Hours: " + String(unwrapped)
            }
        })
    }
    
    func setupStrikes()
    {
        ref = Database.database().reference()
        ref?.child("Students").child(id).child("Strikes").observe(.value, with: {snapshot in
            if let unwrapped = snapshot.value as? Int
            {
                self.strikes.text = "Strikes: " + String(unwrapped)
            }
        })
    }
}

/*extension UIImage {
    
    convenience init?(barcode: String) {
        let data = barcode.data(using: .ascii)
        guard let filter = CIFilter(name: "CICode128BarcodeGenerator") else {
            return nil
        }
        filter.setValue(data, forKey: "inputMessage")
        guard let ciImage = filter.outputImage else {
            return nil
        }
        self.init(ciImage: ciImage)
    }
    
}*/

class ExcusedAbsenceVC: BaseViewController, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var Date: UIDatePicker!
    @IBOutlet weak var reason: UITextView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var ref: DatabaseReference?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.submitButton.layer.cornerRadius = 6;
        self.reason.layer.borderColor = UIColor.black.cgColor
        self.reason.layer.borderWidth = 1;
        self.reason.layer.cornerRadius = 6;
        
        self.name.delegate = self
        self.reason.delegate = self
        addSlideMenuButton()
        //returnTextView()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func submitData()
    {
        
        if(name.text == "" || reason.text == "")
        {
            let defaultAlert = UIAlertController(title: "Error", message: "One or more box is empty", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            defaultAlert.addAction(defaultAction)
            present(defaultAlert, animated: true, completion: nil)
        }
        else
        {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yy"
            let dateString = dateFormatter.string(from: Date.date)
            let postInfo = ["Name": name.text!, "Date": dateString, "Reason": reason.text!, "ID": id]
            
            ref = Database.database().reference().child("Excused Absences").childByAutoId()
            ref?.setValue(postInfo)
            
            let success = UIAlertController(title: "Success!", message: "Your submission has been sent", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            
            success.addAction(defaultAction)
            present(success, animated: true, completion: nil)
            
            name.text = ""
            reason.text = ""
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func returnTextView()
    {
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.addTarget(self, action: #selector(self.didTapView))
        self.view.addGestureRecognizer(tapRecognizer)
    }
    
    @objc func didTapView(){
        self.view.endEditing(true)
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            scrollView.contentInset = .zero
        } else {
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        
        scrollView.scrollIndicatorInsets = scrollView.contentInset
    }
    
}

var currentIndexPath = 0
var path = ""
class VolunteerOppVC: BaseViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var tableView: UITableView!
    
    var ref: DatabaseReference?
    var databaseHandle: DatabaseHandle?
    
    var postData = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        addSlideMenuButton()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        ref = Database.database().reference()
        databaseHandle = ref?.child("Volunteer Opps").observe(.childAdded, with: {(snapshot) in
            self.postData.append(snapshot.key)
            
            self.tableView.reloadData()
        })
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell")
        cell?.textLabel?.text = postData[indexPath.row]
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        currentIndexPath = indexPath.row
        path = postData[currentIndexPath]
        performSegue(withIdentifier: "Info", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? InformationVC{
            destination.navigationBar.title = postData[currentIndexPath]
        }
    }
}

var websiteLink = String()
class InformationVC: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var activity: UITextView!
    @IBOutlet weak var dateTime: UITextView!
    @IBOutlet weak var location: UITextView!
    @IBOutlet weak var website: UITextView!
    @IBOutlet weak var contact: UITextView!
    var ref: DatabaseReference?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.activity.layer.borderWidth = 1;
        self.activity.layer.cornerRadius = 6;
        self.dateTime.layer.borderWidth = 1;
        self.dateTime.layer.cornerRadius = 6;
        self.website.layer.borderWidth = 1;
        self.website.layer.cornerRadius = 6;
        self.location.layer.borderWidth = 1;
        self.location.layer.cornerRadius = 6;
        self.contact.layer.borderWidth = 1;
        self.contact.layer.cornerRadius = 6;
        
        self.website.delegate = self
        
        retrieveInfo()
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func retrieveInfo()
    {
        ref = Database.database().reference()
        ref?.child("Volunteer Opps").child(path).child("Activity").observe(.value, with: {(snapshot) in
            if let unwrapped = snapshot.value as? String
            {
                self.activity.text = String(unwrapped)
            }
        })
        ref?.child("Volunteer Opps").child(path).child("Contact").observe(.value, with: {(snapshot) in
            if let unwrapped = snapshot.value as? String
            {
                self.contact.text = String(unwrapped)
            }
        })
        ref?.child("Volunteer Opps").child(path).child("DateTime").observe(.value, with: {(snapshot) in
            if let unwrapped = snapshot.value as? String
            {
                self.dateTime.text = String(unwrapped)
            }
        })
        ref?.child("Volunteer Opps").child(path).child("Place").observe(.value, with: {(snapshot) in
            if let unwrapped = snapshot.value as? String
            {
                self.location.text = String(unwrapped)
            }
        })
        ref?.child("Volunteer Opps").child(path).child("Website").observe(.value, with: {(snapshot) in
            if let unwrapped = snapshot.value as? String
            {
                self.website.text = String(unwrapped)
                websiteLink = String(unwrapped)
            }
        })
    }
    
    func showSafariVC(for url: String)
    {
        guard let url = URL(string: url)
            else
        {
            //Show an invalid URL error alert
            return
        }
        
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true)
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        showSafariVC(for: websiteLink)
        
        return false // return true if you still want UIAlertController to pop up
    }
}

class ContactVC: BaseViewController, UITextViewDelegate, UITextFieldDelegate
{
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var subject: UITextField!
    @IBOutlet weak var message: UITextView!
    @IBOutlet weak var submit: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    var ref: DatabaseReference?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSlideMenuButton()
        //returnTextView()
        self.message.layer.borderWidth = 1;
        self.message.layer.cornerRadius = 6;
        self.submit.layer.cornerRadius = 6;
        
        self.name.delegate = self
        self.email.delegate = self
        self.subject.delegate = self
        self.message.delegate = self
        
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == name {
            textField.resignFirstResponder()
            email.becomeFirstResponder()
        } else if textField == email {
            textField.resignFirstResponder()
            subject.becomeFirstResponder()
        } else if textField == subject {
            textField.resignFirstResponder()
            message.becomeFirstResponder()
        } else if textField == message {
            textField.resignFirstResponder()
        }
        return true
    }
    
    @IBAction func submitData()
    {
        if(name.text == "" || email.text == "" || subject.text == "" || message.text == "")
        {
            let defaultAlert = UIAlertController(title: "Error", message: "One or more box is empty", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            defaultAlert.addAction(defaultAction)
            present(defaultAlert, animated: true, completion: nil)
        }
        else
        {
            let postInfo = ["Name": name.text!, "Email": email.text!, "Subject": subject.text!, "Message": message.text!]
            
            ref = Database.database().reference().child("Contact").childByAutoId()
            ref?.setValue(postInfo)
            
            let success = UIAlertController(title: "Success!", message: "Your submission has been sent", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            
            success.addAction(defaultAction)
            present(success, animated: true, completion: nil)
            
            name.text = ""
            subject.text = ""
            email.text = ""
            message.text = ""
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func returnTextView()
    {
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.addTarget(self, action: #selector(self.didTapView))
        self.view.addGestureRecognizer(tapRecognizer)
    }
    
    @objc func didTapView(){
        self.view.endEditing(true)
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            scrollView.contentInset = .zero
        } else {
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        
        scrollView.scrollIndicatorInsets = scrollView.contentInset
    }
    
}

class CommitteeVC: BaseViewController, WKNavigationDelegate
{
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var Activity: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSlideMenuButton()
        
        guard let url = URL(string: "https://hamiltonnhs.wixsite.com/hnhs/committees") else { return }
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.isUserInteractionEnabled = true
        webView.navigationDelegate = self
        self.view.addSubview(self.webView)
        let request = URLRequest(url: url)
        webView.load(request)
        
        // add activity
        self.webView.addSubview(self.Activity)
        self.Activity.startAnimating()
        self.webView.navigationDelegate = self
        self.Activity.hidesWhenStopped = true
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        Activity.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        Activity.stopAnimating()
    }
}

class SegueFromRight: UIStoryboardSegue {
    override func perform() {
        let src = self.source
        let dst = self.destination
        
        src.view.superview?.insertSubview(dst.view, aboveSubview: src.view)
        dst.view.transform = CGAffineTransform(translationX: src.view.frame.size.width, y: 0)
        
        UIView.animate(withDuration: 0.25,
                       delay: 0.0,
                       options: .curveEaseInOut,
                       animations: {
                        dst.view.transform = CGAffineTransform(translationX: 0, y: 0)
        },
                       completion: { finished in
                        src.present(dst, animated: false, completion: nil)
        }
        )
    }
}

