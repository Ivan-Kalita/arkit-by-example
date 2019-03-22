//
//  Cube.h
//  arkit-by-example
//
//  Created by md on 6/15/17.
//  Copyright © 2017 ruanestudios. All rights reserved.
//

#import <SceneKit/SceneKit.h>

typedef NS_ENUM(NSUInteger, CubeMode) {
    CubeModeNormal,
    CubeModeResizing
};

@interface Cube : SCNNode
@property (nonatomic) CubeMode mode;
- (void)updateScaleControlsPosition;
- (instancetype)initAtPosition:(SCNVector3)position withMaterial:(SCNMaterial *)material;
- (void)changeMaterial;
- (void)remove;
+ (SCNMaterial *)currentMaterial;
@property (nonatomic) SCNNode* widthScalingControlNode;
@property (nonatomic) SCNNode* heightScalingControlNode;
@property (nonatomic) SCNNode* depthScalingControlNode;
@property (nonatomic) SCNNode* cubeNode;
@end
