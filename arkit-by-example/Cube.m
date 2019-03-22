//
//  Cube.m
//  arkit-by-example
//
//  Created by md on 6/15/17.
//  Copyright © 2017 ruanestudios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Cube.h"
#import "CollisionCategory.h"
#import "PBRMaterial.h"

@implementation Cube

- (instancetype)initAtPosition:(SCNVector3)position withMaterial:(SCNMaterial *)material {
  self = [super init];
  _mode = CubeModeNormal;

  SCNBox *cube = [SCNBox boxWithWidth:1 height:1 length:1 chamferRadius:0.01];
  cube.materials = @[material];
  self.cubeNode = [SCNNode nodeWithGeometry:cube];
  /*
  // The physicsBody tells SceneKit this geometry should be manipulated by the physics engine
  node.physicsBody = [SCNPhysicsBody bodyWithType:SCNPhysicsBodyTypeDynamic shape:nil];
  node.physicsBody.mass = 2.0;
  node.physicsBody.categoryBitMask = CollisionCategoryCube;*/
  self.cubeNode.position = SCNVector3Make(0, 0, 0);
  self.cubeNode.pivot = SCNMatrix4MakeTranslation(0, -0.5, 0);
  self.cubeNode.scale = SCNVector3Make(0.2, 0.2, 0.2);

  [self addChildNode:self.cubeNode];
  self.position = position;
  return self;
}

- (void)setMode:(CubeMode)mode {
    CGFloat scalingNodeSize = 0.05;
    _mode = mode;
    if (_mode == CubeModeResizing) {
        _widthScalingControlNode = [SCNNode nodeWithGeometry:[SCNBox boxWithWidth:scalingNodeSize
                                                                               height:scalingNodeSize
                                                                               length:scalingNodeSize
                                                                        chamferRadius:0]];
        _heightScalingControlNode = [SCNNode nodeWithGeometry:[SCNBox boxWithWidth:scalingNodeSize
                                                                            height:scalingNodeSize
                                                                            length:scalingNodeSize
                                                                     chamferRadius:0]];
        _depthScalingControlNode = [SCNNode nodeWithGeometry:[SCNBox boxWithWidth:scalingNodeSize
                                                                           height:scalingNodeSize
                                                                           length:scalingNodeSize
                                                                    chamferRadius:0]];

        _widthScalingControlNode.geometry.firstMaterial.diffuse.contents = [UIColor redColor];
        _heightScalingControlNode.geometry.firstMaterial.diffuse.contents = [UIColor greenColor];
        _depthScalingControlNode.geometry.firstMaterial.diffuse.contents = [UIColor blueColor];

        [self updateScaleControlsPosition];

        [self addChildNode:_widthScalingControlNode];
        [self addChildNode:_heightScalingControlNode];
        [self addChildNode:_depthScalingControlNode];
    } else {
        [_widthScalingControlNode removeFromParentNode];
        [_heightScalingControlNode removeFromParentNode];
        [_depthScalingControlNode removeFromParentNode];
        _widthScalingControlNode = nil;
        _heightScalingControlNode = nil;
        _depthScalingControlNode = nil;
    }
}

- (void)updateScaleControlsPosition {
    _widthScalingControlNode.position = SCNVector3Make(self.cubeNode.scale.x / 2.0, self.cubeNode.scale.y / 2.0, 0.0);
    _heightScalingControlNode.position = SCNVector3Make(0.0, self.cubeNode.scale.y, 0.0);
    _depthScalingControlNode.position = SCNVector3Make(0.0, self.cubeNode.scale.y / 2.0, self.cubeNode.scale.z / 2.0);
}

- (void)updateSizeWithWidth:(CGFloat)width height:(CGFloat)height length:(CGFloat)length {
  SCNNode *cubeNode = self.cubeNode;
  cubeNode.scale = SCNVector3Make(width, height, length);
}

- (void)changeMaterial {
  [self.childNodes firstObject].geometry.materials = @[[Cube currentMaterial]];
}

+ (SCNMaterial *)currentMaterial {
  SCNMaterial* material = [[PBRMaterial materialNamed:@"tron-red"] copy];
  //[material setDoubleSided:YES];
  return material;
}

- (void) remove {
  [self removeFromParentNode];
}

@end
