//
//  GameScene.swift
//  Filpping Bird
//
//  Created by Thomas Yu on 4/20/20.
//  Copyright © 2020 Thomas Yu. All rights reserved.
//

import SpriteKit
import GameplayKit

struct PhysicsCategory {
    static let man: UInt32 = 0x1 << 1
    static let ground: UInt32 = 0x1 << 2
    static let pip: UInt32 = 0x1 << 3
    static let score: UInt32 = 0x1 << 4
}

class GameScene: SKScene, SKPhysicsContactDelegate{
    
    var ground = SKSpriteNode()
    var man = SKSpriteNode()
    var bg = SKSpriteNode()
    var pipPair = SKNode()
    var moveandRemove = SKAction()
    var isStarted = false
    var score = Int()
    var scoreLbl = SKLabelNode()
    var tapLbl = SKLabelNode()
    var menuBTN = SKSpriteNode()
    var restartBtn = SKSpriteNode()
    var startBTN = SKSpriteNode()
    var pausedBTN = SKSpriteNode()
    var audioBTN = SKSpriteNode()
    var bgmSound = SKAudioNode()
    var pause = false
    var mute = true
    var isDied = Bool()
    
    override func didMove(to view: SKView) {
        creatSence()
    }
    
    override func update(_ currentTime: TimeInterval) {
        if isDied == true || isStarted == false || pause == true{
            
        }else{
            moveGround()
            movePip()
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isDied == true || pause == true {
            
        }else{
            man.physicsBody?.affectedByGravity = true
            man.physicsBody?.velocity = CGVector(dx: 0,dy: 0)
            man.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 180))
            isStarted = true
            self.tapLbl.isHidden = true
            self.pausedBTN.isHidden = false
        }
        
        
        for touch in touches{
            let location = touch.location(in: self)
            if(pause == false){
                if pausedBTN.contains(location){
                    self.createMenuLbl()
                    self.createPlayBtn()
                    self.createRestartBtn()
                    self.createAudioBtn()
                    self.man.physicsBody?.isDynamic = false
                    self.pipPair.isPaused = true
                    isStarted = false
                    pause = true
                    self.pausedBTN.isHidden = true
                }
                
            }
            else if(pause == true){
                if startBTN.contains(location){
                    pause = false
                    self.man.physicsBody?.isDynamic = true
                    self.pipPair.isPaused = false
                    isStarted = true
                    self.startBTN.isHidden = true
                    self.restartBtn.isHidden = true
                    self.menuBTN.isHidden = true
                    self.audioBTN.isHidden = true
                }
                else if (menuBTN.contains(location)){
                    let transition = SKTransition.flipVertical(withDuration: 0.3)
                    let menuScene = GameScene(fileNamed: "MenuScene")
                    menuScene?.scaleMode = .aspectFill
                    self.view?.presentScene(menuScene!,transition: transition)
                }
                else if (audioBTN.contains(location)){
                    if(mute == true){
                        bgmSound.run(SKAction.stop())
                        mute = false
                    }else{
                        bgmSound.run(SKAction.play())
                        mute = true
                    }
                }else{
                    
                }
            }
            
            if(isDied == true || pause == true){
                if restartBtn.contains(location){
                    restartSence()
                }
            }
        }
    }
    
    func createtaplabel(){
        tapLbl.fontColor = SKColor.white
        tapLbl.position = CGPoint(x: self.frame.width / 90, y: self.frame.height / 90 )
        tapLbl.text = "Tap to Start"
        tapLbl.fontName = "04b_19"
        tapLbl.fontSize = 70
        tapLbl.zPosition = 5
        self.addChild(tapLbl)
    }
    
    func createScoreLabel(){
        scoreLbl.fontColor = SKColor.white
        scoreLbl.position = CGPoint(x: self.frame.width / 90, y: self.frame.height / 90 + 500)
        scoreLbl.text = "\(score)"
        scoreLbl.fontName = "04b_19"
        scoreLbl.fontSize = 100
        scoreLbl.zPosition = 5
        self.addChild(scoreLbl)
    }
    
    func createMenuLbl(){
        menuBTN = SKSpriteNode(imageNamed: "menu")
        menuBTN.position = CGPoint(x: self.frame.width / 90, y: self.frame.height / 90 - 200)
        menuBTN.size = CGSize(width: 150, height: 150)
        menuBTN.zPosition = 5
        self.addChild(menuBTN)
    }
    
    func createPlayBtn(){
        startBTN = SKSpriteNode(imageNamed: "play")
        startBTN.position = CGPoint(x: self.frame.width / 90, y: self.frame.height / 90 + 200)
        startBTN.size = CGSize(width: 150, height: 150)
        startBTN.zPosition = 5
        self.addChild(startBTN)
    }
    
    func createAudioBtn(){
        audioBTN = SKSpriteNode(imageNamed: "audio")
        audioBTN.position = CGPoint(x: self.frame.width / 90 , y: self.frame.height / 90 + 400)
        audioBTN.size = CGSize(width: 150, height: 150)
        audioBTN.zPosition = 5
        self.addChild(audioBTN)
    }
    
    func createRestartBtn(){
        restartBtn = SKSpriteNode(imageNamed: "restart")
        restartBtn.position = CGPoint(x: self.frame.width / 90, y: self.frame.height / 90)
        restartBtn.size = CGSize(width: 150, height: 150)
        restartBtn.zPosition = 6
        addChild(restartBtn)
    }
    
    func createPausedBTN(){
        pausedBTN = SKSpriteNode(imageNamed: "pause")
        pausedBTN.position = CGPoint(x: self.frame.width / 90 + 200, y: self.frame.height / 90 + 500)
        pausedBTN.size = CGSize(width: 100, height: 100)
        pausedBTN.zPosition = 6
        self.pausedBTN.isHidden = true
        addChild(pausedBTN)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        if firstBody.categoryBitMask == PhysicsCategory.score && secondBody.categoryBitMask == PhysicsCategory.man || firstBody.categoryBitMask == PhysicsCategory.man && secondBody.categoryBitMask == PhysicsCategory.score{
            score += 1
            scoreLbl.text = "\(score)"
            
        }
        
        else if firstBody.categoryBitMask == PhysicsCategory.man && secondBody.categoryBitMask == PhysicsCategory.pip || firstBody.categoryBitMask == PhysicsCategory.pip && secondBody.categoryBitMask == PhysicsCategory.man{
            
            enumerateChildNodes(withName: "pipe") { (node, error) in
                node.speed = 0
                self.ground.removeAllActions()
                self.removeAllActions()
            }
            if isDied == false{
                isDied = true
                createRestartBtn()
            }
        }
        
        else if firstBody.categoryBitMask == PhysicsCategory.man && secondBody.categoryBitMask == PhysicsCategory.ground || firstBody.categoryBitMask == PhysicsCategory.ground && secondBody.categoryBitMask == PhysicsCategory.man{
            
            
            enumerateChildNodes(withName: "ground") { (node, error) in
               
               
                self.removeAllActions()
                self.pipPair.removeAllActions()
                //node.isPaused = true

            }
            if isDied == false{
                isDied = true
                createRestartBtn()
            }
            
        }
        
    }
    

    
    //create combined pip
    func createPipe(){
        if isStarted == true{
            let scoreNode = SKSpriteNode()
            
            scoreNode.size = CGSize(width: 1, height: 800)
            scoreNode.position = CGPoint(x: self.frame.width, y: self.frame.height / 5)
            scoreNode.physicsBody = SKPhysicsBody(rectangleOf: scoreNode.size)
            scoreNode.physicsBody?.affectedByGravity = false
            scoreNode.physicsBody?.isDynamic = false
            scoreNode.physicsBody?.categoryBitMask = PhysicsCategory.score
            scoreNode.physicsBody?.collisionBitMask = 0
            scoreNode.physicsBody?.contactTestBitMask = PhysicsCategory.man
            
            
            pipPair = SKNode()
            
            let pipDown = SKSpriteNode(imageNamed: "flappy-bird-pipe-down")
            let pipUp = SKSpriteNode(imageNamed: "flappy-bird-pipe-up")
            
            pipDown.position = CGPoint(x: self.frame.width, y: self.frame.height / 5 + 400)
            pipUp.position = CGPoint(x: self.frame.width, y: self.frame.height / 5 - 800)

            pipDown.setScale(1)
            pipUp.setScale(1)
            
            pipDown.physicsBody = SKPhysicsBody(rectangleOf: pipDown.size)
            pipDown.physicsBody?.categoryBitMask = PhysicsCategory.pip
            pipDown.physicsBody?.collisionBitMask = PhysicsCategory.man
            pipDown.physicsBody?.contactTestBitMask = PhysicsCategory.man
            pipDown.physicsBody?.isDynamic = false
            pipDown.physicsBody?.affectedByGravity = false
            
            pipUp.physicsBody = SKPhysicsBody(rectangleOf: pipDown.size)
            pipUp.physicsBody?.categoryBitMask = PhysicsCategory.pip
            pipUp.physicsBody?.collisionBitMask = PhysicsCategory.man
            pipUp.physicsBody?.contactTestBitMask = PhysicsCategory.man
            pipUp.physicsBody?.isDynamic = false
            pipUp.physicsBody?.affectedByGravity = false
            
            pipPair.addChild(pipDown)
            pipPair.addChild(pipUp)
            pipPair.name = "pipe"
            pipPair.zPosition = 1
            let randomPosition = CGFloat.random(min: -300, max: 300)
            pipPair.position.y = pipPair.position.y + randomPosition
            pipPair.addChild(scoreNode)
            pipPair.run(moveandRemove)
            self.addChild(pipPair)
        }
    }
    
    func playbgm(){
        bgmSound = SKAudioNode(fileNamed: "Flappy Bird Theme Song")
        self.addChild(bgmSound)
    }
    
    
    //creat a game character
    func createFlappyMan(){
        man = SKSpriteNode(imageNamed: "Atlas")
        man.setScale(0.25)
        man.position = CGPoint(x: self.frame.width / 10 - 200, y: self.frame.height / 10)
        man.physicsBody = SKPhysicsBody(circleOfRadius: man.frame.height/2)
        man.physicsBody?.categoryBitMask = PhysicsCategory.man
        man.physicsBody?.collisionBitMask = PhysicsCategory.ground | PhysicsCategory.pip
        man.physicsBody?.contactTestBitMask = PhysicsCategory.ground | PhysicsCategory.pip | PhysicsCategory.score
        man.physicsBody?.affectedByGravity = false
        man.physicsBody?.isDynamic = true
        
        man.zPosition = 2
        
        self.addChild(man)
    }
    
    func createBg(){
        for i in 0...1{
            bg = SKSpriteNode(imageNamed: "bg")
            ground.position = CGPoint(x: CGFloat(i)*ground.size.width, y: self.frame.size.height/2)
            bg.name = "bg"
            bg.zPosition = 0
            self.addChild(bg)
        }
    }
    
    //make ground
    func createGround(){
        for i in 0...3{
            ground = SKSpriteNode(imageNamed: "Ground")
            ground.size = CGSize(width: (self.scene?.size.width)!, height: 250)
            ground.anchorPoint = CGPoint(x: 0.5 ,y:0.5)
            ground.name = "ground"
            ground.position = CGPoint(x: CGFloat(i)*ground.size.width, y: -(self.frame.size.height / 2))
            ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
            ground.physicsBody?.categoryBitMask = PhysicsCategory.ground
            ground.physicsBody?.collisionBitMask = PhysicsCategory.man
            ground.physicsBody?.contactTestBitMask = PhysicsCategory.man
            ground.physicsBody?.affectedByGravity = false
            ground.physicsBody?.isDynamic = false
            
            ground.zPosition = 3
            
            self.addChild(ground)
        }
    }
    
    func restartSence(){
        self.removeAllChildren()
        self.removeAllActions()
        isDied = false
        pause = false
        score = 0
        isStarted = false
        creatSence()
        self.restartBtn.removeFromParent()
        self.tapLbl.isHidden = false
    }
       
       func creatSence(){
        self.physicsWorld.contactDelegate = self
        createtaplabel()
        createScoreLabel()
        createBg()
        createGround()
        createFlappyMan()
        createPausedBTN()
        playbgm()
        let spawn = SKAction.run({
            () in
            self.createPipe()
            })
        let delay = SKAction.wait(forDuration: 3.0)
        let spawnDelay = SKAction.sequence([spawn, delay])
        let spawnDelayForever = SKAction.repeatForever(spawnDelay)
        self.run(spawnDelayForever)
        let distance = CGFloat(self.frame.width + pipPair.frame.width)
        let movePipes = SKAction.moveBy(x: -distance, y: 0, duration: TimeInterval(0.01 * distance))
        let removePipes = SKAction.removeFromParent()
        moveandRemove = SKAction.sequence([movePipes, removePipes])
    }
    
    //moving ground
    func moveGround() {
        self.enumerateChildNodes(withName: "ground", using: ({
            (node, Error) in
            node.position.x -= 2
            if node.position.x < -((self.scene?.size.width)!){
                node.position.x += (self.scene?.size.width)! * 3
            }
        }))
    }
    
    func movePip(){
        self.enumerateChildNodes(withName: "pipe", using: ({
            (node, Error) in
            node.position.x -= 4
        }))
    }
}
