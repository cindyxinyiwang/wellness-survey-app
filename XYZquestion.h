//
//  XYZquestion.h
//  wellness survey app
//
//  Created by Cindy Wang on 9/19/14.
//  Copyright (c) 2014 xinyi wang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XYZquestion : NSObject

@property (nonatomic) NSInteger questionNumber;
@property (copy, nonatomic) NSString *questionCategory;
- (id)initWithNumber: (NSInteger)questionNumber
category: (NSString *)questinoCategory;

@end

