//
//  ViewController.m
//  DrawApp
//
//  Created by Kurt Jensen on 3/9/15.
//  Copyright (c) 2015 EECS 497. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "GPUImage.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize actualImageView;
@synthesize pixelizedImageView;
@synthesize tempDrawImage;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    brush = 10.0;
    opacity = 1.0;
    /*hue = .5;
    saturation = .5;
    brightness = .5;*/

    [self.undoButton setEnabled:NO];
    [self.saveButton setEnabled:NO];
}

- (void)colorPicker:(HSVColorPicker *)colorPicker changedColor:(UIColor *)color {
    selectedColor = color;
    [self updateColorView];
}

- (void)viewDidLayoutSubviews {
    //self.canvasView.layer.cornerRadius = 10.0;
    self.canvasView.layer.shadowOffset = CGSizeMake(1, 0);
    self.canvasView.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.canvasView.layer.shadowRadius = 5.0;
    self.canvasView.layer.shadowOpacity = .25;
    
    //self.colorView.layer.cornerRadius = 10.0;
    self.colorView.layer.shadowOffset = CGSizeMake(1, 0);
    self.colorView.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.colorView.layer.shadowRadius = 5.0;
    self.colorView.layer.shadowOpacity = .25;
    [self.colorView setBackgroundColor:[UIColor whiteColor]];

    [self.colorPickerView setBackgroundColor:[UIColor clearColor]];
    if (!colorPicker) {
       colorPicker = [[HSVColorPicker alloc] initWithFrame:self.colorPickerView.frame];
       
       colorPicker.delegate = self;
       selectedColor = [UIColor redColor];//default
       [colorPicker setColor:selectedColor];
       [self colorPicker:colorPicker changedColor:selectedColor];
       
       [self.view addSubview:colorPicker];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) updateColorView {
    if (brushView) {
        [brushView removeFromSuperview];
    }
    brushView = [[UIView alloc] initWithFrame:CGRectMake(0,0, brush, brush)];
    brushView.layer.cornerRadius = brush/2;
    [brushView setBackgroundColor:selectedColor];
    [brushView setCenter:CGPointMake(self.colorView.frame.size.width/2, self.colorView.frame.size.height/2)];
    [brushView setAlpha:opacity];
    
    //NSLog(@"%@", brushView);
    [self.colorView addSubview:brushView];
}

- (IBAction)opacitySliderChanged:(UISlider *)sender {
    opacity = [sender value];
    [self updateColorView];
}
/*
- (IBAction)hueSliderChanged:(UISlider *)sender {
    hue = [sender value];
    //[self.redLabel setTextColor:[UIColor colorWithRed:red green:0 blue:0 alpha:1.0]];
    //[self updateColorView];
}

- (IBAction)saturationSliderChanged:(UISlider *)sender {
    saturation = [sender value];
    //[self.greenLabel setTextColor:[UIColor colorWithRed:0 green:green blue:0 alpha:1.0]];
    //[self updateColorView];
}

- (IBAction)brightnessSliderChanged:(UISlider *)sender {
    brightness = [sender value];
    //[self.blueLabel setTextColor:[UIColor colorWithRed:0 green:0 blue:blue alpha:1.0]];
    //[self updateColorView];
}

- (IBAction)palletSelected:(id)sender {

    switch ([(UIBarButtonItem *)sender tag]) {
        case 0:
            hue = 0.0/6.0;
            break;
        case 1:
            hue = 1.0/6.0;
            break;
        case 2:
            hue = 2.0/6.0;
            break;
        case 3:
            hue = 3.0/6.0;
            break;
        case 4:
            hue = 4.0/6.0;
            break;
        case 5:
            hue = 5.0/6.0;
            break;
        case 6:
            hue = 6.0/6.0;
            break;
        default:
            break;
    }
    
    [self.hueSlider setValue:hue animated:YES];
    //[self updateColorView];
}
*/
- (IBAction)brushSizeChanged:(UIStepper *)sender {
    brush = sender.value;
    [self updateColorView];
}

- (IBAction)save:(id)sender {
    
    NSData *imageData = nil;
    if (pixelized) {
        if (self.pixelizedImageView.image) {
            imageData = UIImagePNGRepresentation(self.pixelizedImageView.image);
        }
    }
    else {
        if (self.actualImageView.image) {
            imageData = UIImagePNGRepresentation(self.actualImageView.image);
        }
    }
    
    if (!imageData) {
        return;
    }
    
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.sDraw"];
    id images = [defaults objectForKey:@"images"];
    if (!images) {
        images = @[];
    }
    
    NSMutableArray *newImages = [NSMutableArray arrayWithArray:images];
    [newImages addObject:imageData];
    
    [defaults setObject:[NSArray arrayWithArray:newImages] forKey:@"images"];
    [defaults synchronize];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"dontShowAlert"] != YES) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Saved to Keyboard"
                                                                                 message:@"To Enable sDraw Keyboard:\nSettings -> General -> Keyboards -> Add Keyboard -> sDraw Keyboard -> Allow Full Access" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Close"
                                                               style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *dontShowAction = [UIAlertAction actionWithTitle:@"Don't Show Again"
                                                                 style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                                                                     [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"dontShowAlert"];
                                                                 }];

        [alertController addAction:cancelAction];
        [alertController addAction:dontShowAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (UIImage *)pixelatedImage:(UIImage *)sourceImage {
    GPUImagePicture *stillImageSource = [[GPUImagePicture alloc] initWithImage:sourceImage];
    GPUImagePixellateFilter *pixellateFilter = [[GPUImagePixellateFilter alloc] init];
    [pixellateFilter setFractionalWidthOfAPixel:.03];
    
    [stillImageSource addTarget:pixellateFilter];
    [pixellateFilter useNextFrameForImageCapture];
    [stillImageSource processImage];
    
    return [pixellateFilter imageFromCurrentFramebuffer];
}

- (IBAction)pixelate:(id)sender {
    pixelized = !pixelized;
    if (pixelized) {
        [(UIBarButtonItem *)sender setTitle:@"De-Pixelize"];
        [self pixelizeIfNeeded];
    }
    else {
        [(UIBarButtonItem *)sender setTitle:@"Pixelize"];
        [self.pixelizedImageView setBackgroundColor:[UIColor clearColor]];
        [self.pixelizedImageView setHidden:YES];
    }
}

- (void)pixelizeIfNeeded {
    if (pixelized) {
        if (self.actualImageView.image) {
            UIImage *pixelatedImage = [self pixelatedImage:self.actualImageView.image];
            [self.pixelizedImageView setImage:pixelatedImage];
            [self.pixelizedImageView setBackgroundColor:[UIColor whiteColor]];
            [self.pixelizedImageView setHidden:NO];
        }
        else {
            [self.pixelizedImageView setImage:nil];
        }
    }
}

- (IBAction)sendText:(id)sender {
    if (!self.actualImageView.image) {
        return;
    }
    
    NSArray * shareItems = @[self.actualImageView.image];
    
    UIActivityViewController * avc = [[UIActivityViewController alloc] initWithActivityItems:shareItems applicationActivities:nil];
    
    [self presentViewController:avc animated:YES completion:nil];
}

- (IBAction)reset:(id)sender {
    [self.actualImageView setImage:nil];
    [self.pixelizedImageView setImage:nil];
    [self.undoButton setEnabled:NO];
    [self.saveButton setEnabled:NO];
}

- (IBAction)undo:(id)sender {
    self.actualImageView.image = previousImage;
    [self pixelizeIfNeeded];
    
    [self.undoButton setEnabled:NO];
    [self.saveButton setEnabled:(self.actualImageView.image != nil)];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    mouseSwiped = NO;
    UITouch *touch = [touches anyObject];
    lastPoint = [touch locationInView:self.tempDrawImage];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    mouseSwiped = YES;
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self.tempDrawImage];
    
    UIGraphicsBeginImageContext(self.tempDrawImage.frame.size);
    [self.tempDrawImage.image drawInRect:CGRectMake(0, 0, self.tempDrawImage.frame.size.width, self.tempDrawImage.frame.size.height)];
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brush );
    CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(), selectedColor.CGColor);
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeNormal);
    
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    self.tempDrawImage.image = UIGraphicsGetImageFromCurrentImageContext();
    [self.tempDrawImage setAlpha:opacity];
    UIGraphicsEndImageContext();
    
    lastPoint = currentPoint;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if(!mouseSwiped) {

        UIGraphicsBeginImageContext(self.tempDrawImage.frame.size);
        [self.tempDrawImage.image drawInRect:CGRectMake(0, 0, self.tempDrawImage.frame.size.width, self.view.frame.size.height)];
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brush);
        CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(), selectedColor.CGColor);
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        CGContextFlush(UIGraphicsGetCurrentContext());
        self.tempDrawImage.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }

    previousImage = self.actualImageView.image;
    [self.undoButton setEnabled:YES];
    [self.saveButton setEnabled:YES];

    UIGraphicsBeginImageContext(self.actualImageView.frame.size);
    [self.actualImageView.image drawInRect:CGRectMake(0, 0, self.actualImageView.frame.size.width, self.actualImageView.frame.size.height) blendMode:kCGBlendModeNormal alpha:1.0];
    [self.tempDrawImage.image drawInRect:CGRectMake(0, 0, self.actualImageView.frame.size.width, self.actualImageView.frame.size.height) blendMode:kCGBlendModeNormal alpha:opacity];
    self.actualImageView.image = UIGraphicsGetImageFromCurrentImageContext();
    self.tempDrawImage.image = nil;
    UIGraphicsEndImageContext();
    
    [self pixelizeIfNeeded];
}

@end
