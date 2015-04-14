//
//  KeyboardViewController.m
//  Keyboard
//
//  Created by Kurt Jensen on 4/12/15.
//  Copyright (c) 2015 EECS 497. All rights reserved.
//

#import "KeyboardViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>

@interface KeyboardViewController ()
@end

@implementation KeyboardViewController
{
    NSArray *images;
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
    
    // Add custom view sizing constraints here
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.nextKeyboardButton addTarget:self action:@selector(advanceToNextInputMode) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadImages];
}

- (void)loadImages {
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.sDraw"];
    id im = [defaults objectForKey:@"images"];
    if (im) {
        images = im;
    }
    else {
        images = @[];
    }
    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated
}

- (void)textWillChange:(id<UITextInput>)textInput {
    // The app is about to change the document's contents. Perform any preparation here.
}

- (void)textDidChange:(id<UITextInput>)textInput {
    // The app has just changed the document's contents, the document context has been updated.
    
    UIColor *textColor = nil;
    if (self.textDocumentProxy.keyboardAppearance == UIKeyboardAppearanceDark) {
        textColor = [UIColor whiteColor];
    } else {
        textColor = [UIColor blackColor];
    }
    [self.nextKeyboardButton setTitleColor:textColor forState:UIControlStateNormal];
}

#pragma mark - Collection View Delegate/DataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return  1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    return [images count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"Cell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier
                                                                           forIndexPath:indexPath];
    
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0, cell.frame.size.width, cell.frame.size.height)];
    
    NSData *imageData = [images objectAtIndex:indexPath.row];
    UIImage *image = [UIImage imageWithData:imageData];
    [imageView setImage:image];
    [imageView setBackgroundColor:[UIColor whiteColor]];
    
    [cell.layer setCornerRadius:4];
    
    [cell addSubview:imageView];

    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath  {
    
    UICollectionViewCell *cell =[collectionView cellForItemAtIndexPath:indexPath];
    
    NSData *imageData = [images objectAtIndex:indexPath.row];

    NSMutableDictionary *item = [NSMutableDictionary dictionary];
    [item setValue:imageData forKey:(NSString*)kUTTypePNG];
    [[UIPasteboard generalPasteboard] setItems:@[item]];
    
    UILabel *copiedLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, (cell.frame.size.height/2)-10, cell.frame.size.width, 20)];
    copiedLabel.text = @"Copied!";
    
    copiedLabel.numberOfLines = 1;
    copiedLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
    copiedLabel.adjustsFontSizeToFitWidth = YES;
    copiedLabel.backgroundColor = [UIColor grayColor];
    
    copiedLabel.minimumScaleFactor = 10.0f/12.0f;
    copiedLabel.clipsToBounds = YES;
    copiedLabel.backgroundColor = [UIColor whiteColor];
    copiedLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-Bold" size:14.0];
    copiedLabel.textColor = [UIColor blackColor];
    copiedLabel.textAlignment = NSTextAlignmentCenter;
    [cell addSubview:copiedLabel];
    [UIView animateWithDuration:3 animations:^(void) {
        copiedLabel.alpha = 0;
        
    }];
}

@end
