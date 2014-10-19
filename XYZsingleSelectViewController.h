//
//  XYZsingleSelectViewController.h
//  wellness survey app
//
//  Created by Cindy Wang on 10/11/14.
//  Copyright (c) 2014 xinyi wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XYZsingleSelectViewController : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UIPickerView *picker;
@property (weak, nonatomic) NSArray *pickerData;
@property (strong, nonatomic) NSString *questionIndex;
@property (strong, nonatomic) NSString *question;
@property (strong, nonatomic) NSString *questionId;

@property (strong, nonatomic) NSString *prevAnswer;

@end
