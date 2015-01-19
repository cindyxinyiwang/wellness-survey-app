//
//  XYZselectTableViewCell.m
//  wellness survey app
//
//  Created by Cindy Wang on 1/16/15.
//  Copyright (c) 2015 xinyi wang. All rights reserved.
//

#import "XYZselectTableViewCell.h"

@implementation XYZselectTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.myPicker.dataSource = self;
    self.myPicker.delegate = self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Configure picker

- (NSInteger)numberOfComponentsInPickerView: (UIPickerView *)pickerView
{
    return 1;
}

// The number of rows of data
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    //NSLog(@"The first value is %@", _pickerData);
    //NSArray *data = [_pickerData objectForKey:@"config"];
    //NSLog(@"The second value is %@", data);
    return (int)[self.pickerData count];
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    //NSArray *data = [_pickerData objectForKey:@"config"];
    
    return self.pickerData[row];
}

// Catpure the picker view selection
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    // This method is triggered whenever the user makes a change to the picker selection.
    // The parameter named row and component represents what was selected.
    self.selectedIndex = row;
    
    NSString *message = [self.pickerData objectAtIndex:row];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NotificationMessageEvent" object:message];

}


@end
