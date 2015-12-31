//
//  ViewController.m
//  ImageReducer
//
//  Created by Jonas Gessner on 21.10.14.
//  Copyright (c) 2014 Jonas Gessner. All rights reserved.
//

#import "ViewController.h"
#import "ImageDropView.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.creditsTextField setStringValue:[NSString stringWithFormat:@"© 2014-%lu, Jonas Gessner", [[[[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian] components:NSCalendarUnitYear fromDate:[NSDate date]] year]]];
}

@end
