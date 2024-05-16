//
//  DetailsVC.swift
//  Empara
//
//  Created by Emre Şahin on 15.05.2024.
//

import UIKit
import CoreData

class DetailsVC: UIViewController , UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var detayText: UITextView!
    @IBOutlet weak var saveButton: UIButton!
    
    var chosenPainting = ""
    var chosenPaintingId : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if chosenPainting != "" {
            //coredata
            
            saveButton.isHidden = true
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Save")
            let idString = chosenPaintingId?.uuidString
            
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            fetchRequest.returnsObjectsAsFaults = false
            do {
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        if let name = result.value(forKey: "isim") as? String {
                            nameText.text = name
                        }
                        if let artist = result.value(forKey: "detay") as? String {
                            detayText.text = artist
                        }
                       
                        if let imageData = result.value(forKey: "image") as? Data {
                            let image = UIImage(data: imageData)
                            imageView.image = image
                        }
                    }
                }
            } catch {
                print("error")
            }
        }
        else {
            saveButton.isHidden = false
            saveButton.isEnabled = false
            nameText.text = ""
            detayText.text = ""
        }
        //recognizer
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        
        imageView.isUserInteractionEnabled = true
        let imageTapRezognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(imageTapRezognizer)
    }
    @objc func selectImage() {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.editedImage] as? UIImage
        saveButton.isEnabled = true
        self.dismiss(animated: true, completion: nil)
    }
    @objc func hideKeyboard() {
        view.endEditing(true)
    }

    @IBAction func saveButtonClicked(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Save", into: context)
        
        newPainting.setValue(nameText.text!, forKey: "isim")
        newPainting.setValue(detayText.text!, forKey: "detay")
        
        newPainting.setValue(UUID(), forKey: "id")
        let data = imageView.image!.jpegData(compressionQuality: 0.7)
        newPainting.setValue(data, forKey: "image")
        do {
            try context.save()
            print("success")
        } catch {
            print("hata")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        self.navigationController?.popViewController(animated: true)
        
        
    }
}
