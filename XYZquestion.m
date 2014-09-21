//
//  XYZquestion.m
//  wellness survey app
//
//  Created by Cindy Wang on 9/19/14.
//  Copyright (c) 2014 xinyi wang. All rights reserved.
//

#import "XYZquestion.h"

@implementation XYZquestion
- (id)initWithNumber: (NSInteger)questionNumber
            category: (NSString *)questinoCategory{
    self = [super init];
    if (self) {
        _questionCategory = questinoCategory;
        _questionNumber = questionNumber;
    }
    return self;
}

-(id)init {
    return [self initWithNumber:0 category:nil];
}
@end
