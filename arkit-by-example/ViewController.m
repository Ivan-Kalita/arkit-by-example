//
//  ViewController.m
//  arkit-by-example
//
//  Created by md on 6/8/17.
//  Copyright © 2017 ruanestudios. All rights reserved.
//

#import "ViewController.h"
#import <SceneKit/SceneKitTypes.h>
#import "CollisionCategory.h"
#import "PBRMaterial.h"
#import <arkit_by_example-Swift.h>

typedef BOOL(^NSArrayFilterBlock)(id element);

typedef id(^NSArrayFilterMapBlock)(id element);

typedef void(^NSArrayForeachBlock)(id element);

@interface NSArray (Functor)

- (NSArray*)filter:(NSArrayFilterBlock)block;
- (NSArray*)map:(NSArrayFilterMapBlock)block;
- (void)foreach:(NSArrayForeachBlock)block;

@end

@implementation NSArray (Functor)

- (NSArray*)filter:(NSArrayFilterBlock)block {
    NSMutableArray* array = [NSMutableArray new];
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (block(obj)) {
            [array addObject:obj];
        }
    }];
    return array;
}

- (NSArray*)map:(NSArrayFilterMapBlock)block {
    NSMutableArray* array = [NSMutableArray new];
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [array addObject:block(obj)];
    }];
    return array;
}

- (void)foreach:(NSArrayForeachBlock)block {
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        block(obj);
    }];
}

@end

@interface ViewController () <ARSCNViewDelegate, UIGestureRecognizerDelegate, SCNPhysicsContactDelegate>
@property (nonatomic, strong) IBOutlet ARSCNView *sceneView;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *widthLabels;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *heightLabels;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *depthLabels;
@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  // Used to keep track of the current tracking state of the ARSession
  self.currentTrackingState = ARTrackingStateNormal;
  
  [self setupScene];
  [self setupLights];
  [self setupRecognizers];
  
  // Create a ARSession confi object we can re-use
  self.arConfig = [ARWorldTrackingConfiguration new];
  self.arConfig.lightEstimationEnabled = YES;
  self.arConfig.planeDetection = ARPlaneDetectionHorizontal;
  
  Config *config = [Config new];
  config.showStatistics = NO;
  config.showWorldOrigin = YES;
  config.showFeaturePoints = YES;
  config.showPhysicsBodies = NO;
  config.detectPlanes = YES;
  self.config = config;
  [self updateConfig];
  [self updateLabels];
  // Stop the screen from dimming while we are using the app
  [UIApplication.sharedApplication setIdleTimerDisabled:YES];
}

- (void)updateLabels {
    [[[_widthLabels
       arrayByAddingObjectsFromArray:_heightLabels]
      arrayByAddingObjectsFromArray:_depthLabels]
     foreach:^(UILabel* label) {
        label.hidden = !self.cube;
    }];
    if (!self.cube) {
        return;
    }
    [_widthLabels
     foreach:^(UILabel* label) {
         [self setValue:self.cube.cubeNode.scale.x toLabel:label];
     }];
    [_heightLabels
     foreach:^(UILabel* label) {
         [self setValue:self.cube.cubeNode.scale.y toLabel:label];
     }];
    [_depthLabels
     foreach:^(UILabel* label) {
         [self setValue:self.cube.cubeNode.scale.z toLabel:label];
     }];
    [self updateLabelsPosition];
}

- (void)setValue:(double)value toLabel:(UILabel *)label {
    label.text = [NSString stringWithFormat:@"%@ см", @((NSUInteger)(value * 100))];
}

- (void)updateLabelsPosition {
    [self setPosition:SCNVector3Make(-_cube.cubeNode.scale.x / 2.0, 0, 0)
             forLabel:_depthLabels[0]];
    [self setPosition:SCNVector3Make(_cube.cubeNode.scale.x / 2.0, 0, 0)
             forLabel:_depthLabels[1]];
    [self setPosition:SCNVector3Make(-_cube.cubeNode.scale.x / 2.0, _cube.cubeNode.scale.y, 0)
             forLabel:_depthLabels[2]];
    [self setPosition:SCNVector3Make(_cube.cubeNode.scale.x / 2.0, _cube.cubeNode.scale.y, 0)
             forLabel:_depthLabels[3]];

    [self setPosition:SCNVector3Make(0, 0, -_cube.cubeNode.scale.z  / 2.0)
             forLabel:_widthLabels[0]];
    [self setPosition:SCNVector3Make(0, 0, _cube.cubeNode.scale.z  / 2.0)
             forLabel:_widthLabels[1]];
    [self setPosition:SCNVector3Make(0, _cube.cubeNode.scale.y, -_cube.cubeNode.scale.z  / 2.0)
             forLabel:_widthLabels[2]];
    [self setPosition:SCNVector3Make(0, _cube.cubeNode.scale.y, _cube.cubeNode.scale.z  / 2.0)
             forLabel:_widthLabels[3]];

    [self setPosition:SCNVector3Make(-_cube.cubeNode.scale.x / 2.0,
                                     _cube.cubeNode.scale.y / 2.0,
                                     -_cube.cubeNode.scale.z  / 2.0)
             forLabel:_heightLabels[0]];
    [self setPosition:SCNVector3Make(_cube.cubeNode.scale.x / 2.0,
                                     _cube.cubeNode.scale.y / 2.0,
                                     _cube.cubeNode.scale.x / 2.0)
             forLabel:_heightLabels[1]];
    [self setPosition:SCNVector3Make(-_cube.cubeNode.scale.x / 2.0,
                                     _cube.cubeNode.scale.y / 2.0,
                                     _cube.cubeNode.scale.z / 2.0)
             forLabel:_heightLabels[2]];
    [self setPosition:SCNVector3Make(_cube.cubeNode.scale.x / 2.0,
                                     _cube.cubeNode.scale.y / 2.0,
                                     -_cube.cubeNode.scale.z / 2.0)
             forLabel:_heightLabels[3]];

}

- (void)setPosition:(SCNVector3)position forLabel:(UILabel*)label {
    SCNVector3 calculatedPosition = [[[[self sceneView] scene] rootNode] convertPosition:position fromNode:_cube];
    SCNVector3 projectedPoint = [[self sceneView] projectPoint:calculatedPosition];
    [label sizeToFit];
    label.frame = CGRectMake(projectedPoint.x - label.frame.size.width ,
                              projectedPoint.y - label.frame.size.height,
                              label.frame.size.width,
                              label.frame.size.height);
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self.navigationController setNavigationBarHidden:YES animated:NO];
  
  // Run the view's session
  [self.sceneView.session runWithConfiguration: self.arConfig options: 0];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];

  // Pause the view's session
  [self.sceneView.session pause];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Release any cached data, images, etc that aren't in use.
}

- (void)setupScene {
  // Setup the ARSCNViewDelegate - this gives us callbacks to handle new
  // geometry creation
  self.sceneView.delegate = self;
  
  // Make things look pretty :)
  self.sceneView.antialiasingMode = SCNAntialiasingModeMultisampling4X;
  
  // This is the object that we add all of our geometry to, if you want
  // to render something you need to add it here
  SCNScene *scene = [SCNScene new];
  self.sceneView.scene = scene;
}

- (void)setupLights {
  // Turn off all the default lights SceneKit adds since we are handling it ourselves
  self.sceneView.autoenablesDefaultLighting = NO;
  self.sceneView.automaticallyUpdatesLighting = NO;
  
  UIImage *env = [UIImage imageNamed: @"./Assets.scnassets/Environment/spherical.jpg"];
  self.sceneView.scene.lightingEnvironment.contents = env;
  
  //TODO: wantsHdr
}

- (void)setupRecognizers {
  // Single tap will insert a new piece of geometry into the scene
  UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]
                                                  initWithTarget:self
                                                  action:@selector(insertCubeFrom:)];
  tapGestureRecognizer.numberOfTapsRequired = 1;
  [self.sceneView addGestureRecognizer:tapGestureRecognizer];


  UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc]
                                                            initWithTarget:self
                                                            action:@selector(longPressDetected:)];
  longPressRecognizer.minimumPressDuration = 1.0;
    longPressRecognizer.numberOfTouchesRequired = 1;
  [self.sceneView addGestureRecognizer:longPressRecognizer];

    [tapGestureRecognizer requireGestureRecognizerToFail:longPressRecognizer];

  UIPanGestureRecognizer* panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                         action:@selector(dragCubeFrom:)];
  [self.sceneView addGestureRecognizer:panGestureRecognizer];

  UIRotationGestureRecognizer* rotationGestureRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self
                                                                                         action:@selector(rotateCubeFrom:)];
  [self.sceneView addGestureRecognizer:rotationGestureRecognizer];

}

- (void)rotateCubeFrom:(UIRotationGestureRecognizer *)recognizer {
  static SCNVector3 originalRotation;
  if (!self.cube)
    return;
  if (recognizer.state == UIGestureRecognizerStateBegan) {
    originalRotation = self.cube.eulerAngles;
  } else if (recognizer.state == UIGestureRecognizerStateChanged) {
    self.cube.eulerAngles = SCNVector3Make(originalRotation.x,
                                           originalRotation.y - recognizer.rotation,
                                           originalRotation.z);
  }
}

- (void)dragCubeFrom:(UIPanGestureRecognizer *)recognizer {
  [self dragOrInsertCubeFrom:recognizer];
}

- (void)insertCubeFrom:(UITapGestureRecognizer *)recognizer {
  [self dragOrInsertCubeFrom:recognizer];
}

- (void)dragOrInsertCubeFrom:(UIGestureRecognizer *)recognizer {
    if (!_cube || _cube.mode == CubeModeNormal) {
        // Take the screen space tap coordinates and pass them to the hitTest method on the ARSCNView instance
        CGPoint tapPoint = [recognizer locationInView:self.sceneView];
        NSArray<ARHitTestResult *> *result = [self.sceneView hitTest:tapPoint types:ARHitTestResultTypeEstimatedHorizontalPlane];

        // If the intersection ray passes through any plane geometry they will be returned, with the planes
        // ordered by distance from the camera
        if (result.count == 0) {
            [self showMessage:@"No plane detected"];
            return;
        }

        // If there are multiple hits, just pick the closest plane
        ARHitTestResult * hitResult = [result firstObject];

        [self updateCube:hitResult];

    } else {
        CGPoint holdPoint = [recognizer locationInView:self.sceneView];

        NSArray* scalingControls = @[_cube.widthScalingControlNode,
                                     _cube.depthScalingControlNode,
                                     _cube.heightScalingControlNode];


        NSArray<SCNHitTestResult *> *result = [[self.sceneView hitTest:holdPoint options:@{
                                                                                           SCNHitTestOptionSearchMode: @(SCNHitTestSearchModeAll)
                                                                                           }]
                                               filter:^BOOL(SCNHitTestResult* element) {
                                                   return [scalingControls containsObject:element.node];
                                               }];

        if (result.count == 0) {
            return;
        }
        SCNHitTestResult *hitResult = result.firstObject;
        SCNVector3 position = hitResult.localCoordinates;
        SCNNode* resultNode = result.firstObject.node;
        if (resultNode == _cube.widthScalingControlNode) {
            resultNode.position = SCNVector3Make(resultNode.position.x + position.x, resultNode.position.y, resultNode.position.z);
        } else if (resultNode == _cube.heightScalingControlNode) {
            resultNode.position = SCNVector3Make(resultNode.position.x, resultNode.position.y + position.y, resultNode.position.z);
        } else {
            resultNode.position = SCNVector3Make(resultNode.position.x, resultNode.position.y, resultNode.position.z + position.z);
        }
        self.cube.cubeNode.scale = SCNVector3Make(self.cube.widthScalingControlNode.position.x * 2.0,
                                                  self.cube.heightScalingControlNode.position.y,
                                                  self.cube.depthScalingControlNode.position.z * 2.0);

        [self updateLabels];

        if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateFailed) {
            [self.cube updateScaleControlsPosition];
        }
    }
}

- (void)longPressDetected: (UILongPressGestureRecognizer *)recognizer {
  if (recognizer.state != UIGestureRecognizerStateBegan) {
    return;
  }

  //CGPoint holdPoint = [recognizer locationInView:self.sceneView];
  //NSArray<SCNHitTestResult *> *result = [self.sceneView hitTest:holdPoint options:nil];
  //if (result.count == 0) {
  //  return;
  //}
  
  //SCNHitTestResult *hitResult = [result firstObject];
    _cube.mode = (_cube.mode == CubeModeNormal) ? CubeModeResizing : CubeModeNormal;
}

- (void)disableTracking:(BOOL)disabled {
  // Stop detecting new planes or updating existing ones.
  
  if (disabled) {
    self.arConfig.planeDetection = ARPlaneDetectionNone;
  } else {
    self.arConfig.planeDetection = ARPlaneDetectionHorizontal;
  }
  
  [self.sceneView.session runWithConfiguration:self.arConfig];
}

- (void)updateCube:(ARHitTestResult *)hitResult {
  // We insert the geometry slightly above the point the user tapped, so that it drops onto the plane
  // using the physics engine
  SCNVector3 position = SCNVector3Make(
                                       hitResult.worldTransform.columns[3].x,
                                       hitResult.worldTransform.columns[3].y,
                                       hitResult.worldTransform.columns[3].z
                                       );
  if (self.cube) {
    self.cube.position = position;
    [self updateLabels];
    return;
  }

  Cube *cube = [[Cube alloc] initAtPosition:position withMaterial:[Cube currentMaterial]];
  [self updateLabels];
  self.cube = cube;
  [self.sceneView.scene.rootNode addChildNode:cube];
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
  return UIModalPresentationNone;
}

- (IBAction)detectPlanesChanged:(id)sender {
  BOOL enabled = ((UISwitch *)sender).on;
  
  if (enabled == self.config.detectPlanes) {
    return;
  }
  
  self.config.detectPlanes = enabled;
  if (enabled) {
    [self disableTracking: NO];
  } else {
    [self disableTracking: YES];
  }
}

- (void)updateConfig {
  SCNDebugOptions opts = SCNDebugOptionNone;
  Config *config = self.config;
  if (config.showWorldOrigin) {
    opts |= ARSCNDebugOptionShowWorldOrigin;
  }
  if (config.showFeaturePoints) {
    opts = ARSCNDebugOptionShowFeaturePoints;
  }
  if (config.showPhysicsBodies) {
    opts |= SCNDebugOptionShowPhysicsShapes;
  }
  self.sceneView.debugOptions = opts;
  if (config.showStatistics) {
    self.sceneView.showsStatistics = YES;
  } else {
    self.sceneView.showsStatistics = NO;
  }
}

- (void)clean
{
  [self.cube remove];
    self.cube = nil;
}

- (IBAction)reset:(id)sender {
  [self showMessage:@"Start new tracking session"];
  [self refresh];
}

- (void)refresh {
  [self clean];
  [self.sceneView.session runWithConfiguration:self.arConfig options:ARSessionRunOptionResetTracking | ARSessionRunOptionRemoveExistingAnchors];
}

#pragma mark - SCNPhysicsContactDelegate

- (void)physicsWorld:(SCNPhysicsWorld *)world didBeginContact:(SCNPhysicsContact *)contact {
  // Here we detect a collision between pieces of geometry in the world, if one of the pieces
  // of geometry is the bottom plane it means the geometry has fallen out of the world. just remove it
  CollisionCategory contactMask = contact.nodeA.physicsBody.categoryBitMask | contact.nodeB.physicsBody.categoryBitMask;
  
  if (contactMask == (CollisionCategoryBottom | CollisionCategoryCube)) {
    if (contact.nodeA.physicsBody.categoryBitMask == CollisionCategoryBottom) {
      [contact.nodeB removeFromParentNode];
    } else {
      [contact.nodeA removeFromParentNode];
    }
  }
}

#pragma mark - ARSCNViewDelegate

- (void)renderer:(id <SCNSceneRenderer>)renderer updateAtTime:(NSTimeInterval)time {
  ARLightEstimate *estimate = self.sceneView.session.currentFrame.lightEstimate;
  if (!estimate) {
    return;
  }
  
  // A value of 1000 is considered neutral, lighting environment intensity normalizes
  // 1.0 to neutral so we need to scale the ambientIntensity value
  CGFloat intensity = estimate.ambientIntensity / 1000.0;
  self.sceneView.scene.lightingEnvironment.intensity = intensity;
}

/**
 Called when a new node has been mapped to the given anchor.
 
 @param renderer The renderer that will render the scene.
 @param node The node that maps to the anchor.
 @param anchor The added anchor.
 */
- (void)renderer:(id <SCNSceneRenderer>)renderer didAddNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {
  if (![anchor isKindOfClass:[ARPlaneAnchor class]]) {
    return;
  }
  [self showMessage:@"Plane detected"];
  // When a new plane is detected we create a new SceneKit plane to visualize it in 3D
}

/**
 Called when a node has been updated with data from the given anchor.
 
 @param renderer The renderer that will render the scene.
 @param node The node that was updated.
 @param anchor The anchor that was updated.
 */
- (void)renderer:(id <SCNSceneRenderer>)renderer didUpdateNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {
  // When an anchor is updated we need to also update our 3D geometry too. For example
  // the width and height of the plane detection may have changed so we need to update
  // our SceneKit geometry to match that
}

/**
 Called when a mapped node has been removed from the scene graph for the given anchor.
 
 @param renderer The renderer that will render the scene.
 @param node The node that was removed.
 @param anchor The anchor that was removed.
 */
- (void)renderer:(id <SCNSceneRenderer>)renderer didRemoveNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {
  // Nodes will be removed if planes multiple individual planes that are detected to all be
  // part of a larger plane are merged.
}

/**
 Called when a node will be updated with data from the given anchor.
 
 @param renderer The renderer that will render the scene.
 @param node The node that will be updated.
 @param anchor The anchor that was updated.
 */
- (void)renderer:(id <SCNSceneRenderer>)renderer willUpdateNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {
}

/**
 Implement this to provide a custom node for the given anchor.
 
 @discussion This node will automatically be added to the scene graph.
 If this method is not implemented, a node will be automatically created.
 If nil is returned the anchor will be ignored.
 @param renderer The renderer that will render the scene.
 @param anchor The added anchor.
 @return Node that will be mapped to the anchor or nil.
 */
//- (nullable SCNNode *)renderer:(id <SCNSceneRenderer>)renderer nodeForAnchor:(ARAnchor *)anchor {
//  return nil;
//}

- (void)showMessage:(NSString *)message {
  [NSOperationQueue.mainQueue addOperationWithBlock:^{
    [self.messageViewer queueMessage:message];
  }];
}

- (void)session:(ARSession *)session cameraDidChangeTrackingState:(ARCamera *)camera {
  ARTrackingState trackingState = camera.trackingState;
  if (self.currentTrackingState == trackingState) {
    return;
  }
  self.currentTrackingState = trackingState;
  
  switch(trackingState) {
    case ARTrackingStateNotAvailable:
      [self showMessage:@"Camera tracking is not available on this device"];
      break;
      
    case ARTrackingStateLimited:
      switch(camera.trackingStateReason) {
        case ARTrackingStateReasonExcessiveMotion:
          [self showMessage:@"Limited tracking: slow down the movement of the device"];
          break;
        case ARTrackingStateReasonInsufficientFeatures:
          [self showMessage:@"Limited tracking: too few feature points, view areas with more textures"];
          break;
        case ARTrackingStateReasonNone:
          NSLog(@"Tracking limited none");
          break;
        case ARTrackingStateReasonInitializing:
          [self showMessage:@"Tracking is initializing"];
          break;
        case ARTrackingStateReasonRelocalizing:
          [self showMessage:@"Tracking is relocalizing"];
          break;
      }
      break;
      
    case ARTrackingStateNormal:
      [self showMessage:@"Tracking is back to normal"];
      break;
  }
}

- (void)session:(ARSession *)session didFailWithError:(NSError *)error {
  // Present an error message to the user
  [self showMessage:@"session error"];
}

- (void)sessionWasInterrupted:(ARSession *)session {
  // Inform the user that the session has been interrupted, for example, by presenting an overlay, or being put in to the background
  UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Interruption" message:@"The tracking session has been interrupted. The session will be reset once the interruption has completed" preferredStyle:UIAlertControllerStyleAlert];
  
  UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
  }];
  
  [alert addAction:ok];
  [self presentViewController:alert animated:YES completion:^{
  }];
  
}

- (void)sessionInterruptionEnded:(ARSession *)session {
  // Reset tracking and/or remove existing anchors if consistent tracking is required
  [self showMessage:@"Tracking session has been reset due to interruption"];
  [self refresh];
}

- (void)renderer:(id<SCNSceneRenderer>)renderer willRenderScene:(SCNScene *)scene atTime:(NSTimeInterval)time {
    [NSOperationQueue.mainQueue addOperationWithBlock:^{
        [self updateLabels];
    }];
}

+ (SCNVector3)calculateCentroidForPointcloud:(SCNVector3*)arrayOfPoints count:(NSUInteger)count {
    SCNVector3 avg;
    for(NSUInteger i = 0; i < count; i++) {
        avg.x += arrayOfPoints[i].x;
        avg.y += arrayOfPoints[i].y;
        avg.z += arrayOfPoints[i].z;
    }
    return SCNVector3Make(avg.x / count, avg.y / count, avg.z / count);
}

+ (CaliperResult)calculateOptimalBoundingRectangleForPointcloud:(SCNVector3*)arrayOfPoints
                                                          count:(NSUInteger)count {
    return (CaliperResult){ .0, .0, .0 };
}

@end
