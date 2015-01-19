//
//  XYZselectTableViewCell.h
//  wellness survey app
//
//  Created by Cindy Wang on 1/16/15.
//  Copyright (c) 2015 xinyi wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XYZselectTableViewCell : UITableViewCell<UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic)IBOutlet UIPickerView* myPicker;
@property (strong, nonatomic) NSArray *pickerData;
@property ( nonatomic) NSInteger selectedIndex;

@end
