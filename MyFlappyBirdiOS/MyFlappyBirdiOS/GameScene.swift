//
//  GameScene.swift
//  MyFlappyBirdiOS


import SpriteKit

//implementing protocols, just like implementing an interface in Java or C#

//SKScene: An SKScene object represents a scene of content in Sprite Kit. A scene is the root node in a tree of Sprite Kit nodes (SKNode). These nodes provide content that the scene animates and renders for display. To display a scene, you present it from an SKView object.

//SKPhysicsContactDelegate: An object that implements the SKPhysicsContactDelegate protocol can respond when two physics bodies are in contact with each other in a physics world. To receive contact messages, you set the contactDelegate property of a SKPhysicsWorld object. The delegate is called when a contact starts or ends
class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var bird = SKSpriteNode();
    //let is like a final variable in Java
    //UInt32 is a 32-bit unsigned integer. The int will signify which group a given entity in our game belongs to
    let birdGroup:UInt32=1;
    let objectGroup:UInt32=2;
    
    //this overriden method is called immediately after a scene is presented by a view. So it's here we "run" our game
    //the parameter is the view that presents the scene
    override func didMoveToView(view: SKView) {
        //The physicsWorld object is where the global physics attributes of a scene is stored. So physics stuff that
        //applies to the whole scene, such as gravity
        self.physicsWorld.gravity = CGVectorMake(0, -5.0);
        
        //A delegate that is called when two physics bodies come in contact with each other.
        //A contact is created when two physics bodies overlap and one of the physics bodies has a contactTestBitMask
        //property that overlaps with the other body’s categoryBitMask property.
        self.physicsWorld.contactDelegate = self;
        createBackground();
        createBird();
        createGround();
        
        //An SKAction object is an action that is executed by a node in the scene (SKScene).
        //runBlock() creates an action that executes a block.
        var spawnPipes = SKAction.runBlock{ () -> Void in
            self.createPipes();
        }
        
        //let's wait a bit before creating the pipes
        var sleepAction = SKAction.waitForDuration(3);
        //make a sequence of executable actions
        var runAll = SKAction.sequence([spawnPipes, sleepAction]);
        //let's repeat them forever, creating the pipes at regular intervals
        var repeatForever = SKAction.repeatActionForever(runAll);
        runAction(repeatForever);
    }
    
    /* Birds fly, so they shouldn't hit the ground. Therefore we make a ground with collision detection
    */
    func createGround(){
        //creating a node to put in the scene
        var ground = SKNode();
        //ground position
        ground.position = CGPoint(x: 0, y: 0);
        //make the ground the width of the frame, that's width: size.width, and just height: 1
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: size.width, height: 1));
        //dynamic is a Boolean value that indicates whether the physics body is moved by the physics simulation.
        //default is true
        ground.physicsBody?.dynamic=false;
        //we define which category the ground belongs to.
        ground.physicsBody?.categoryBitMask=objectGroup;
        //adding the ground node to the scene tree
        self.addChild(ground);
    }
    
    //Called when two bodies first contact each other.
    //the parameter is an object that holds some information about the contact
    func didBeginContact(contact: SKPhysicsContact) {
        println("collision happened");
        
    }
    
    //make pipes
    func createPipes(){
        
        //define the gap between the two pipes
        var gapHeight = bird.size.height * 4;
        
        //a number between 0 and size.height/2 is generated. arc4Random is a good C library random generator
        var movementAmount = arc4random() % UInt32(size.height/2);
        
        //this is how you do a println with a variable reference in swift:
        println("movementAmount was: \(movementAmount)");
        
        //from where do we want the pipes to begin?
        var pipeOffset = CGFloat(movementAmount) - size.height/4;
        
        //making the topPipe
        //make the texture for the node to be inserted in the scene. Texture is the graphical layout
        var topPipeTexture = SKTexture(imageNamed: "pipe1");
        //make the node with the given texture
        var topPipe = SKSpriteNode(texture: topPipeTexture);
        //set position of the node
        topPipe.position = CGPoint(x: size.width, y: size.height/2 + topPipe.size.height/2 + gapHeight/2 + pipeOffset);

        //making the bottomPipe
        var bottomPipeTexture = SKTexture(imageNamed: "pipe2");
        var bottomPipe = SKSpriteNode(texture: bottomPipeTexture);
        bottomPipe.position = CGPoint(x: size.width, y: size.height/2 - bottomPipe.size.height/2 - gapHeight/2 + pipeOffset);
        
        //physics properties of topPipe
        topPipe.physicsBody = SKPhysicsBody(rectangleOfSize: topPipe.size);
        topPipe.physicsBody?.categoryBitMask = objectGroup;
        topPipe.physicsBody?.dynamic=false;
        
        //physics properties of bottomPipe
        bottomPipe.physicsBody = SKPhysicsBody(rectangleOfSize: bottomPipe.size);
        bottomPipe.physicsBody?.categoryBitMask = objectGroup;
        bottomPipe.physicsBody?.dynamic=false;
        
        //move pipes
        //the first parameter is delta x, the value to add the the current x position.
        //duration is how long time the animation shall take. So the larger the interval, the slower the pipes move
        var movePipes = SKAction.moveByX(-size.width * 2, y: 0, duration: NSTimeInterval(size.width/100));
        
        //run the action on the pipes
        topPipe.runAction(movePipes);
        bottomPipe.runAction(movePipes);
        
        //add the pipe nodes to the scene tree
        addChild(topPipe);
        addChild(bottomPipe);
    }
    
    func createBird(){
        //fetch the texture, the graphical layout
        var birdTexture1 = SKTexture(imageNamed:"flappy1.png");
        var birdTexture2 = SKTexture(imageNamed:"flappy2.png");
        
        //make a node with the given texture
        bird = SKSpriteNode(texture: birdTexture1);
        
        //make a texture which animates from one to the other
        var alternateTexture = SKAction.animateWithTextures([birdTexture1, birdTexture2], timePerFrame: 0.1);
        
        //repeat the animated texture
        var repeatForever = SKAction.repeatActionForever(alternateTexture);
        //call the action on the bird: make it flapp it wings
        bird.runAction(repeatForever);
        
        bird.position = CGPoint(x: size.width/2, y: size.height/2);
        //put the bird on top of the resulting layered image
        bird.zPosition = 9;
        
        //assigning the bird a physical body
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height/2);
        bird.physicsBody?.categoryBitMask = birdGroup;
        bird.physicsBody?.contactTestBitMask = objectGroup;
        bird.physicsBody?.collisionBitMask = birdGroup;
        
        addChild(bird);
    }
    
    func createBackground(){
        
        var backgroundTexture = SKTexture(imageNamed:"bg.png");
        var background = SKSpriteNode(texture: backgroundTexture);
        
        var moveLeft = SKAction.moveByX(-backgroundTexture.size().width, y: 0, duration:9);
        var moveBack = SKAction.moveByX(backgroundTexture.size().width, y: 0, duration:0);
        //sequence runs any action listed in the array - one after the other
        var groupAction = SKAction.sequence([moveLeft, moveBack]);
        //we would like it to run forever
        var repeatForever = SKAction.repeatActionForever(groupAction);
        
        //solve "grey area betweeen backgrounds"
        for var i:CGFloat = 0; i<2; i++ {
            background = SKSpriteNode(texture: backgroundTexture);
            background.position=CGPoint(x: size.width/2 + backgroundTexture.size().width * i, y: CGRectGetMidY(self.frame));
            background.size.height = size.height;
            background.runAction(repeatForever);
            addChild(background);
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent){
        bird.physicsBody?.velocity=CGVector(dx: 0, dy: 0);
        bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy:50));
    }
}
