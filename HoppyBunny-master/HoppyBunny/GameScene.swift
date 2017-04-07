//
//  GameScene.swift
//  HoppyBunny
//
//  Created by JeffChiu on 6/21/16.
//  Copyright © 2016 JeffChiu. All rights reserved.
//

import SpriteKit


enum GameSceneState {
    case Active
    case GameOver
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var clouds: SKSpriteNode!
    var clouds2: SKSpriteNode!
    
    var crystals: SKSpriteNode!
    var crystals2: SKSpriteNode!
    
    var hero: SKSpriteNode!
    var scrollLayer: SKNode!
    var obstacleLayer: SKNode!
    var buttonRestart: MSButtonNode!
    var scoreLabel: SKLabelNode!
    var obstacleSource: SKNode!
    
    var sinceTouch : CFTimeInterval = 0
    let fixedDelta: CFTimeInterval = 1.0 / 60.0 /* 60 FPS */
    let scrollSpeed: CGFloat = 100
    
    var spawnTimer: CFTimeInterval = 0
    
    var gameState: GameSceneState = .Active
    
    var points: Int = 0 {
        didSet {
            scoreLabel.text = "\(points)"
        }
    }
    
    
    
    
    func scrollWorld() {
        /* Scroll World */
        scrollLayer.position.x -= scrollSpeed * CGFloat(fixedDelta)
        /* Loop through scroll layer nodes */
        for ground in scrollLayer.children as! [SKSpriteNode] {
            
            /* Get ground node position, convert node position to scene space */
            let groundPosition = scrollLayer.convertPoint(ground.position, toNode: self)
            
            /* Check if ground sprite has left the scene */
            if groundPosition.x <= -ground.size.width / 2 {
                
                /* Reposition ground sprite to the second starting position */
                let newPosition = CGPointMake( (self.size.width / 2) + ground.size.width, groundPosition.y)
                
                /* Convert new node position back to scroll layer space */
                ground.position = self.convertPoint(newPosition, toNode: scrollLayer)
            }
        }
    }
    
    
    func updateObstacles() {
        /* Update Obstacles */
        
        obstacleLayer.position.x -= scrollSpeed * CGFloat(fixedDelta)
        
        /* Loop through obstacle layer nodes */
        for obstacle in obstacleLayer.children as! [SKReferenceNode] {
            
            /* Get obstacle node position, convert node position to scene space */
            let obstaclePosition = obstacleLayer.convertPoint(obstacle.position, toNode: self)
            
            /* Check if obstacle has left the scene */
            if obstaclePosition.x <= 0 {
                print("removing obstacle")
                /* Remove obstacle node from obstacle layer */
                obstacle.removeFromParent()
            }
            
        }
        
        /* Time to add a new obstacle? */
        if spawnTimer >= 1.5 {
            
            /* Create a new obstacle reference object using our obstacle resource */
            // let newObstacle = SKReferenceNode.init(fileNamed: "Obstacle")!
            
            let newObstacle = obstacleSource.copy() as! SKNode
            
            obstacleLayer.addChild(newObstacle)
            
            /* Generate new obstacle position, start just outside screen and with a random y value */
            let randomPosition = CGPointMake(352, CGFloat.random(min: 234, max: 382))
            
            /* Convert new node position back to obstacle layer space */
            newObstacle.position = self.convertPoint(randomPosition, toNode: obstacleLayer)
            
            // Reset spawn timer
            spawnTimer = 0
        }
        
    }
    
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        // ******* Check for contact with goal ***************
        let contactA: SKPhysicsBody = contact.bodyA
        let contactB: SKPhysicsBody = contact.bodyB
        let nodeA = contactA.node!
        let nodeB = contactB.node!
        
        if nodeA.name == "obstacleCenter" || nodeB.name == "obstacleCenter" {
            points += 1
            return
        }
        
        
        // ****** contact with anything else ends game *****
        
        if gameState != .Active { return }
        
        gameState = .GameOver
        
        hero.physicsBody?.allowsRotation = false
        hero.physicsBody?.angularVelocity = 0
        hero.removeAllActions()
        buttonRestart.state = .MSButtonNodeStateActive
        
        let heroDeath = SKAction.runBlock { 
            self.hero.zRotation = CGFloat(-90).degreesToRadians()
        }
        
        hero.runAction(heroDeath)
        
        let shakeScene: SKAction = SKAction.init(named: "Shake")!
        
        for node in self.children {
            node.runAction(shakeScene)
        }
    }
    
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        clouds = self.childNodeWithName("clouds") as! SKSpriteNode
        clouds2 = self.childNodeWithName("clouds2") as! SKSpriteNode
        
        crystals = self.childNodeWithName("crystals") as! SKSpriteNode
        crystals2 = self.childNodeWithName("crystals2") as! SKSpriteNode
        
        /* Recursive node search for 'hero' (child of referenced node) */
        hero = self.childNodeWithName("//hero") as! SKSpriteNode
        
        /* Set reference to scroll layer node */
        scrollLayer = self.childNodeWithName("scrollLayer")
        
        /* Set reference to obstacle layer node */
        obstacleLayer = self.childNodeWithName("obstacleLayer")
        obstacleSource = self.childNodeWithName("obstacle")
        
        physicsWorld.contactDelegate = self
        
        buttonRestart = self.childNodeWithName("buttonRestart") as! MSButtonNode
        buttonRestart.selectedHandler = {
            let skView = self.view as SKView!
            let scene = GameScene(fileNamed: "GameScene") as GameScene!
            scene.scaleMode = .AspectFill
            skView.presentScene(scene)
        }
        
        buttonRestart.state = .MSButtonNodeStateHidden
        
        scoreLabel = self.childNodeWithName("scoreLabel") as! SKLabelNode
        points = 0
    }
    
    
    
    
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        
        if gameState != .Active { return }
        
        hero.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        
        /* Apply vertical impulse */
        hero.physicsBody?.applyImpulse(CGVectorMake(0, 8))
        
        /* Apply subtle rotation */
        hero.physicsBody?.applyAngularImpulse(1)
        
        /* Reset touch timer */
        sinceTouch = 0
    }
    
    
    
    func scrollSprite(sprite: SKSpriteNode, speed: CGFloat) {
        sprite.position.x -= speed
        
        if sprite.position.x < sprite.size.width / -2 {
            sprite.position.x += sprite.size.width * 2
        }
    }
    
    
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        scrollSprite(clouds, speed: 3)
        scrollSprite(clouds2, speed: 3)
        
        scrollSprite(crystals, speed: 1)
        scrollSprite(crystals2, speed: 1)
        
        if gameState != .Active { return }
        
        
        /* Grab current velocity */
        let velocityY = hero.physicsBody?.velocity.dy ?? 0
        
        /* Check and cap vertical velocity */
        if velocityY > 400 {
            hero.physicsBody?.velocity.dy = 400
        }
        
        /* Apply falling rotation */
        if sinceTouch > 0.1 {
            let impulse = -20000 * fixedDelta
            hero.physicsBody?.applyAngularImpulse(CGFloat(impulse))
        }
        
        /* Clamp rotation */
        hero.zRotation.clamp(CGFloat(-90).degreesToRadians(),CGFloat(30).degreesToRadians())
        hero.physicsBody?.angularVelocity.clamp(-2, 2)
        
        /* Update last touch timer */
        sinceTouch += fixedDelta
        
        /* Process world scrolling */
        scrollWorld()
        
        /* Process obstacles */
        updateObstacles()
        
        spawnTimer += fixedDelta
    }
}