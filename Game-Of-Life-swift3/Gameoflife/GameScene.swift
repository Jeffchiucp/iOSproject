//
//  GameScene.swift
//  Gameoflife
//
//  Created by Jeff Chiu on 6/22/16.
//  Copyright (c) 2016 Jeff Chiu. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    /* Game objects */
    var gridNode: Grid!
    
    /* UI Objects */
    var stepButton: MSButtonNode!
    var populationLabel: SKLabelNode!
    var generationLabel: SKLabelNode!
    var playButton: MSButtonNode!
    var pauseButton: MSButtonNode!
    
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        
        /* Connect scene objects */
        gridNode = childNode(withName: "gridNode") as! Grid
        
        /* Connect UI scene objects */
        stepButton = childNode(withName: "stepButton") as! MSButtonNode
        populationLabel = childNode(withName: "populationLabel") as! SKLabelNode
        generationLabel = childNode(withName: "generationLabel") as! SKLabelNode
        playButton = childNode(withName: "playButton") as! MSButtonNode
        pauseButton = childNode(withName: "pauseButton") as! MSButtonNode
        
        /* Setup testing button selected handler */
        stepButton.selectedHandler = {
            [unowned self] in
            self.stepSimulation()
        }
        
        /* Setup play button selected handler */
        playButton.selectedHandler = {
            [unowned self] in
            self.isPaused = false
        }
        
        /* Setup pause button selected handler */
        pauseButton.selectedHandler = {
            [unowned self] in
            self.isPaused = true
        }
        
        /* Create an SKAction based timer, 0.5 second delay */
        let delay = SKAction.wait(forDuration: 0.5)
        
        /* Call the stepSimulation() method to advance the simulation */
        let callMethod = SKAction.perform(#selector(GameScene.stepSimulation), onTarget: self)
        
        /* Create the delay,step cycle */
        let stepSequence = SKAction.sequence([delay,callMethod])
        
        /* Create an infinite simulation loop */
        let simulation = SKAction.repeatForever(stepSequence)
        
        /* Run simulation action */
        self.run(simulation)
        
        /* Default simulation to pause state */
        self.isPaused = true

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /* Called when a touch begins */
    }
   
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
    }
    
    func stepSimulation() {
        /* Step Simulation */
        
        /* Run next step in simulation */
        gridNode.evolve()
        
        /* Update UI label objects */
        populationLabel.text = String(gridNode.population)
        generationLabel.text = String(gridNode.generation)  
    }
}
