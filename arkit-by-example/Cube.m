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

  SCNBox *cube = [SCNBox boxWithWidth:1 height:1 length:1 chamferRadius:0.01];
  cube.materials = @[material];
  SCNNode *node = [SCNNode nodeWithGeometry:cube];
  /*
  // The physicsBody tells SceneKit this geometry should be manipulated by the physics engine
  node.physicsBody = [SCNPhysicsBody bodyWithType:SCNPhysicsBodyTypeDynamic shape:nil];
  node.physicsBody.mass = 2.0;
  node.physicsBody.categoryBitMask = CollisionCategoryCube;*/
  node.position = SCNVector3Make(position.x, position.y - 0.5, position.z);
  node.pivot = SCNMatrix4MakeTranslation(0, -0.5, 0);
  node.scale = SCNVector3Make(0.2, 0.2, 0.2);
  [self addChildNode:node];
  return self;
}

- (void)updateSizeWithWidth:(CGFloat)width height:(CGFloat)height length:(CGFloat)length {
  SCNNode *cubeNode = self.childNodes.firstObject;
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
