//
//  ViewController.h
//  DrawApp
//
//  Created by Kurt Jensen on 3/9/15.
//  Copyright (c) 2015 EECS 497. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HSVColorPicker.h"
#import <HSVColorPicker/HSVColorPicker.h>
#import "UIColor+HexCodes.h"

@interface ViewController : UIViewController
{
    CGPoint lastPoint;
    CGFloat hue;
    CGFloat saturation;
    CGFloat brightness;
    CGFloat brush;
    CGFloat opacity;
    BOOL mouseSwiped;
    
    UIView *brushView;
    UIImage *previousImage;
    BOOL pixelized;
}

@property (weak, nonatomic) IBOutlet UIImageView *actualImageView;
@property (weak, nonatomic) IBOutlet UIImageView *pixelizedImageView;
@property (weak, nonatomic) IBOutlet UIImageView *tempDrawImage;
@property (strong, nonatomic) IBOutlet UIView *colorView;
@property (strong, nonatomic) IBOutlet UIView *canvasView;

@property (strong, nonatomic) IBOutlet UISlider *hueSlider;
@property (weak, nonatomic) HSVColorPicker *colorPicker;
@property (weak, nonatomic) UITextField *colorTextField;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *undoButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveButton;

- (IBAction)hueSliderChanged:(id)sender;
- (IBAction)saturationSliderChanged:(id)sender;
- (IBAction)brightnessSliderChanged:(id)sender;
- (IBAction)opacitySliderChanged:(UISlider *)sender;

- (IBAction)palletSelected:(id)sender;
- (IBAction)brushSizeChanged:(UIStepper *)sender;
- (IBAction)save:(id)sender;

- (IBAction)pixelate:(id)sender;
- (IBAction)sendText:(id)sender;
- (IBAction)reset:(id)sender;
- (IBAction)undo:(id)sender;

@end

