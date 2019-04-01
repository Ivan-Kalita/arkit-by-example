//
//  ViewController.h
//  arkit-by-example
//
//  Created by md on 6/8/17.
//  Copyright © 2017 ruanestudios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <SceneKit/SceneKit.h>
#import <ARKit/ARKit.h>
#import "Cube.h"
#import "Config.h"
#import "MessageView.h"

typedef struct CaliperResult {
    float length;
    float width;
    float height;
    SCNVector3 cenroid;
    float rotation2D;
} CaliperResult;

typedef NS_ENUM(NSUInteger, ARInteractionMode) {
    ARInteractionModeDefault,
    ARInteractionModeBoundingBox
};

@interface ViewController : UIViewController<UIPopoverPresentationControllerDelegate>
- (void)setupScene;
- (void)setupLights;
- (void)setupPhysics;
- (void)setupRecognizers;
- (void)updateConfig;
- (void)hidePlanes;
- (void)refresh;
- (void)disableTracking:(BOOL)disabled;
- (void)updateCube:(ARHitTestResult *)hitResult;
- (void)insertCubeFrom: (UITapGestureRecognizer *)recognizer;
- (void)explodeFrom: (UITapGestureRecognizer *)recognizer;
- (void)geometryConfigFrom: (UITapGestureRecognizer *)recognizer;
- (IBAction)settingsUnwind:(UIStoryboardSegue *)segue;
- (IBAction)boundingBoxModeChanged:(id)sender;

@property (nonatomic, retain) Cube *cube;
@property (nonatomic, retain) Config *config;
@property (nonatomic, retain) ARWorldTrackingConfiguration *arConfig;
@property (weak, nonatomic) IBOutlet MessageView *messageViewer;
@property (nonatomic) ARTrackingState currentTrackingState;
@property (nonatomic) ARInteractionMode interactionMode;

@end
