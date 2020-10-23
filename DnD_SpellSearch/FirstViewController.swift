//
//  FirstViewController.swift
//  DnD_SpellSearch
//
//  Created by student on 10/13/20.
//  Copyright © 2020 Dillon Jones. All rights reserved.
//

import UIKit
import CoreData

struct Type: Codable {
    init() {
        name = ""
    }
    let name: String
}
struct damageType: Codable {
    init(){
        damage_type = Type()
        //damage_at_slot_level = [:]
    }
    let damage_type: Type
   // let damage_at_slot_level:[String:String]
}
struct schoolType: Codable {
    init() {
        name = ""
    }
    let name: String
}
struct classType: Codable {
    init(){
        name = ""
    }
    let name: String
}
struct spellDetails : Codable {
    init(){
        name = ""
        desc = []
        higher_level = []
        range = ""
        components = []
        material = ""
        ritual = false
        duration = ""
        concentration = false
        casting_time = ""
        level = 0
        attack_type = ""
        damage = damageType()
        school = schoolType()
        classes = []
        url = ""
    }
    let name: String
    let desc: [String]
    let range: String
    let components: [String]
    let ritual: Bool
    let duration: String
    let concentration: Bool
    let casting_time: String
    let level: Int
    let school: schoolType
    let classes: [classType]
    let url: String
    
    //items found to be optional
    let higher_level: [String]?
    let material: String?
    let attack_type: String?
    let damage: damageType?
}



class FirstViewController: UIViewController {

    var favorites:[NSManagedObject] = []
    var passedInformation: String = ""
    var thisSpell = spellDetails()
    
    @IBOutlet weak var navBar: UINavigationItem!
    
    @IBOutlet weak var spellDesc: UITextView!
    
    @IBOutlet weak var spellSchool: UILabel!
    
    @IBOutlet weak var spellCastingTime: UILabel!
    @IBOutlet weak var spellRange: UILabel!
    
    @IBOutlet weak var spellComponents: UILabel!
    @IBOutlet weak var spellClasses: UILabel!
    
    @IBOutlet weak var spellExtra: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string: "https://www.dnd5eapi.co\(passedInformation)" )
        if url != nil {
            downloadData(url:url!)
        }
    }
    @IBAction func homeButton(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    @IBAction func likeButton(_ sender: Any) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        //step 1
        let managedContent = appDelegate.persistentContainer.viewContext
        //2
        let entity = NSEntityDescription.entity(forEntityName: "Favorite", in: managedContent)!
        let fav = NSManagedObject(entity: entity, insertInto: managedContent)
        //3
        fav.setValue(thisSpell.name, forKey: "name")
        fav.setValue(thisSpell.url, forKey: "url")
        //4
        do {
            try managedContent.save()
            favorites.append(fav)
            print("Save complete")
        } catch let error as NSError{
            print("Could not save. \(error), \(error.userInfo)")
        }

    }
    
    func loadData(){
        DispatchQueue.main.async {
            self.navBar.title = self.thisSpell.name
            self.spellDesc.text = self.thisSpell.desc.joined(separator: "\n \n")
            self.spellSchool.text = "Level \(self.thisSpell.level) \(self.thisSpell.school.name)"
            self.spellCastingTime.text  = "Casting Time: \(self.thisSpell.casting_time)"
            self.spellRange.text = "Range: \(self.thisSpell.range)"
            self.spellComponents.text = "Components: \(self.thisSpell.components.joined())"
            self.getClasses()
            self.getExtra()
        }
    }
    func getComponents() {
        var comp = ""
        for item in thisSpell.components {

            comp += item
        }
        print("here")
        spellComponents.text = "Components: \(comp)"
        
    }
    func getExtra() {
        //need to work on getting info from api (damage at level/healing at level)
    }
    func getClasses() {
        var classList = ""
        var first = true
        for items in thisSpell.classes {
            if first == true {
                first = false
                classList += items.name
            }
            else {
            classList += ",\(items.name)"
            }
            
        }
        spellClasses.text = "Classes: \(classList)"
    }
    
    func decodeData(downloaded_data: Data){
         do {
           let downloaded_info = try JSONDecoder().decode(spellDetails.self, from:downloaded_data)
            self.thisSpell = downloaded_info
            loadData()
               } catch {
                   print("Decoding Error")
               }
        
    }
    func downloadData(url: URL) {
        let _ = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            //decode
            if let downloaded_data = data {
                self.decodeData(downloaded_data: downloaded_data)
            } else if let error = error {
                print(error)
            }
            }).resume()
    }


}

