//
//  ZRYViewController.m
//  SampleProject
//
//  Created by Mariano Abdala on 10/29/13.
//  Copyright (c) 2013 Zerously.com. All rights reserved.
//

#import "ZRYViewController.h"
#import "ZRYWordPicker.h"

@interface ZRYViewController () <
ZRYWordPickerDataSource,
ZRYWordPickerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (strong, nonatomic) NSArray *words;
@property (strong, nonatomic) NSArray *initialWords;
@property (strong, nonatomic) NSArray *moneyWords;

@end

@implementation ZRYViewController

#pragma mark - Hierarchy
#pragma mark UIViewController
- (void)viewDidLoad {
    
    [super viewDidLoad];
	
    self.words =
    self.initialWords;
    
    ZRYWordPicker *wordPicker =
    [[ZRYWordPicker alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    
    wordPicker.dataSource = self;
    wordPicker.delegate = self;
    
    self.textField.inputAccessoryView = wordPicker;
}

#pragma mark - Self
#pragma mark ZRYViewController ()
- (NSArray *)initialWords {
    
    if (_initialWords == nil) {
        
        self.initialWords = @[
                              
                              @"Money",
                              @"Coffee",
                              @"Beer",
                              @"Lunch",
                              @"Dinner",
                              @"Book",
                              @"Cab ride",
                              @"Concert",
                              @"Ice cream",
                              @"Chai latte",
                              @"Walk the dog",
                              @"Do the dishes",
                              @"10 $",
                              @"20 $",
                              @"50 $"
                              ];
    }
    
    return _initialWords;
}

- (NSArray *)moneyWords {
    
    if (_moneyWords == nil) {
        
        self.moneyWords = @[
                            
                            @"Money",
                            @"$",
                            @"€",
                            @"£",
                            @"¥"
                            ];
    }
    
    return _moneyWords;
}

#pragma mark - Protocol
#pragma mark ZRYWordPickerDataSource
- (NSUInteger)numberOfWordsInWordPicker:(ZRYWordPicker *)wordPicker {
    
    return self.words.count;
}

- (NSString *)wordPicker:(ZRYWordPicker *)wordPicker wordAtIndex:(NSUInteger)index {
    
    return self.words[index];
}

#pragma mark ZRYWordPickerDelegate
- (void)wordPicker:(ZRYWordPicker *)wordPicker didSelectWordAtIndex:(NSUInteger)index {
    
    NSString *selectedWord =
    self.words[index];
    
    if ([selectedWord isEqualToString:@"Money"] == YES) {
        
        if (self.words == self.initialWords) {
            
            self.words =
            self.moneyWords;
            
            [wordPicker reload];
            [wordPicker selectWordAtIndex:0];
            
            self.textField.keyboardType =
            UIKeyboardTypeDecimalPad;
            
            self.textField.keyboardAppearance =
            UIKeyboardAppearanceDark;
            
        } else {
            
            self.words =
            self.initialWords;
            
            [wordPicker reload];
            
            self.textField.keyboardType =
            UIKeyboardTypeDefault;
            
            self.textField.keyboardAppearance =
            UIKeyboardAppearanceLight;
        }
        
        //Force new keyboard type to appear.
        [self.textField resignFirstResponder];
        [self.textField becomeFirstResponder];
        
    } else {
        
        self.textField.text =
        [self.textField.text stringByAppendingString:selectedWord];
    }
}

@end