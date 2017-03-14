//
//  CategoryViewController.swift
//  PokedexLab
//
//  Created by SAMEER SURESH on 2/25/17.
//  Copyright © 2017 iOS Decal. All rights reserved.
//

import UIKit

class CategoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var pokemons: UITableView!
    
    var pokemonArray: [Pokemon]?
    var cachedImages: [Int:UIImage] = [:]
    var selectedIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pokemons.delegate = self
        pokemons.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pokemonArray!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "thePokeCell", for: indexPath) as! PokeTableCellElem
        
        // check if unwrap is possible
        if let pokemon = pokemonArray?[indexPath.row] {
            cell.thePokeName.text = pokemon.name
            cell.thePokeNum.text = String(pokemon.number)
            cell.thePokeStats.text = String.init(format: "%d/%d/%d", pokemon.attack, pokemon.defense, pokemon.health)
            
            if let image = cachedImages[indexPath.row] {
                cell.thePoke.image = image // may need to change this!
            } else {
                let url = URL(string: pokemon.imageUrl)! //whut??????
                let session = URLSession(configuration: .default)
                let downloadPicTask = session.dataTask(with: url) { (data, response, error) in
                    if let e = error {
                        print("Error downloading picture: \(e)")
                    } else {
                        if let _ = response as? HTTPURLResponse {
                            if let imageData = data {
                                let image = UIImage(data: imageData)
                                self.cachedImages[indexPath.row] = image
                                
                                // telling main thread to run this block of code
                                // async -> multiple things can do stuff @ same time (used more often)
                                // sync programming -> one program runs until finished & then next things run after
                                DispatchQueue.main.async {
                                    cell.thePoke.image = UIImage(data: imageData) // may need to change this!
                                }
                       
                            } else {
                                
                                print("Couldn't get image: Image is nil")
                            }
                        } else {
                            print("Couldn't get response code")
                        }
                    }
                }
                downloadPicTask.resume()
            }
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        performSegue(withIdentifier: "toPokemon", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toPokemon") {
            if let dest = segue.destination as? PokemonInfoViewController {
                dest.image = self.cachedImages[(selectedIndexPath?.row)!]
                dest.pokemon = self.pokemonArray?[(selectedIndexPath?.row)!]
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}
