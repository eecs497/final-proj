//
//  KeyboardViewController.h
//  Keyboard
//
//  Created by Kurt Jensen on 4/12/15.
//  Copyright (c) 2015 EECS 497. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KeyboardViewController : UIInputViewController <UICollectionViewDelegate, UICollectionViewDataSource>
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) IBOutlet UIButton *nextKeyboardButton;

@end
