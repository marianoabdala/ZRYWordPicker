//
//  ZRYWordPicker.m
//  ZRYWordPicker
//
//  Created by Mariano Abdala on 10/19/13.
//  Copyright (c) 2013 Zerously.com. All rights reserved.
//
//  https://github.com/marianoabdala/ZRYWordPicker
//

#import "ZRYWordPicker.h"

#define WORD_PICKER_SIZE    CGSizeMake(320, 44)

#define WORD_BUTTON_MINIMUM_SIZE        CGSizeMake(44, 44)
#define WORD_BUTTON_TITLE_MARGIN        11.0f
#define WORD_BUTTON_HORIZONTAL_PADDING  8.0f
#define WORD_BUTTON_VERTICAL_PADDING    7.0f

#define WORD_BUTTON_TITLE_COLOR                 [UIColor colorWithRed:0.0f green:0.478431f blue:1.0f alpha:1.0]
#define WORD_BUTTON_BACKGROUND_COLOR            [UIColor colorWithRed:0.4f green:0.8f blue:1.0f alpha:0.2f]
#define WORD_BUTTON_SELECTED_TITLE_COLOR        [UIColor colorWithRed:1.0f green:0.521569f blue:0.0f alpha:1.0]
#define WORD_BUTTON_SELECTED_BACKGROUND_COLOR   [UIColor colorWithRed:0.6f green:0.2f blue:0.0f alpha:0.2f]

@implementation UIView (Additions)

- (void)setOriginX:(CGFloat)x toView:(UIView *)view {
    
    CGRect viewFrame = view.frame;
    viewFrame.origin.x = x;
    view.frame = viewFrame;
}

@end

@interface ZRYWordPicker () <
    UIScrollViewDelegate>

@property (assign, nonatomic, getter = areWordsLoaded) BOOL wordsLoaded;
@property (strong, nonatomic) UIToolbar *toolbar;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) NSMutableArray *wordsButtons;
@property (strong, nonatomic) NSMutableArray *pagesBoundries;
@property (assign, nonatomic) CGPoint lastTargetContentOffset;

- (void)initialize;
- (void)loadWords;
- (UIButton *)wordButtonWithWord:(NSString *)word;
- (void)wordButtonTapped:(id)sender;
- (void)scrollForPagingToPoint:(CGPoint)contentOffset;
- (void)scrollForBounceToPoint:(CGPoint)contentOffset;

@end

@implementation ZRYWordPicker

#pragma mark - Hierarchy
#pragma mark UIView
- (id)initWithFrame:(CGRect)frame {
    
    self =
    [super initWithFrame:frame];
    
    if (self != nil) {
        
        [self initialize];
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect {
    
    [super drawRect:rect];

    @synchronized(self) {
        
        if (self.areWordsLoaded == NO) {

            [self loadWords];
            self.wordsLoaded = YES;
        }
    }
}

#pragma mark UIView<NSCoding>
- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self =
    [super initWithCoder:aDecoder];
    
    if (self != nil) {
        
        [self initialize];
    }
    
    return self;
}

#pragma mark - Self
#pragma mark ZRYWordPicker
- (void)reload {
    
    [self loadWords];
}

- (void)selectWordAtIndex:(NSUInteger)index {
    
    UIButton *wordButton =
    [self.wordsButtons objectAtIndex:index];
    
    wordButton.backgroundColor =
    WORD_BUTTON_SELECTED_BACKGROUND_COLOR;
    
    [wordButton setTitleColor:WORD_BUTTON_SELECTED_TITLE_COLOR
                     forState:UIControlStateNormal];
}

- (void)deselectWordAtIndex:(NSUInteger)index {
    
    UIButton *wordButton =
    [self.wordsButtons objectAtIndex:index];
    
    wordButton.backgroundColor =
    WORD_BUTTON_BACKGROUND_COLOR;
    
    [wordButton setTitleColor:WORD_BUTTON_TITLE_COLOR
                     forState:UIControlStateNormal];
}

#pragma mark ZRYWordPicker ()
- (UIToolbar *)toolbar {
    
    if (_toolbar == nil) {
        
        self.toolbar =
        [[UIToolbar alloc] initWithFrame:self.bounds];
    }
    
    return _toolbar;
}

- (UIScrollView *)scrollView {
    
    if (_scrollView == nil) {
        
        self.scrollView =
        [[UIScrollView alloc] initWithFrame:self.bounds];
        
        self.scrollView.delegate = self;
    }
    
    return _scrollView;
}

- (void)initialize {
    
    self.frame =
    CGRectMake(self.frame.origin.x,
               self.frame.origin.y,
               WORD_PICKER_SIZE.width,
               WORD_PICKER_SIZE.height);
    
    self.backgroundColor = [UIColor whiteColor];
    
    [self addSubview:self.toolbar];
    [self addSubview:self.scrollView];
}

- (void)loadWords {
    
    for (UIButton *wordButton in self.wordsButtons) {
        
        [wordButton removeFromSuperview];
    }
    
    self.wordsButtons = nil;
    
    if (self.dataSource == nil) {
        
        return;
    }
    
    self.wordsButtons =
    [NSMutableArray array];

    self.pagesBoundries =
    [NSMutableArray array];
    
    [self.pagesBoundries addObject:[NSValue valueWithCGPoint:CGPointMake(0, 0)]];

    NSUInteger numberOfWords =
    [self.dataSource numberOfWordsInWordPicker:self];

    CGFloat nextWordButtonX = WORD_BUTTON_HORIZONTAL_PADDING;
    CGFloat nextPageX = self.bounds.size.width;
    
    for (NSUInteger wordIndex = 0; wordIndex < numberOfWords; wordIndex++) {
        
        NSString *word =
        [self.dataSource wordPicker:self
                        wordAtIndex:wordIndex];
        
        UIButton *wordButton =
        [self wordButtonWithWord:word];
        
        [self.wordsButtons addObject:wordButton];
        [self.scrollView addSubview:wordButton];
        
        [self setOriginX:nextWordButtonX
                  toView:wordButton];

        nextWordButtonX =
        (wordButton.frame.origin.x + wordButton.frame.size.width + WORD_BUTTON_HORIZONTAL_PADDING);
        
        if (nextWordButtonX - WORD_BUTTON_HORIZONTAL_PADDING >= nextPageX) {

            CGFloat wordButtonBeginX =
            wordButton.frame.origin.x - WORD_BUTTON_HORIZONTAL_PADDING;

            nextPageX =
            wordButtonBeginX + self.bounds.size.width;

            NSValue *nextPageValue =
            [NSValue valueWithCGPoint:CGPointMake(wordButtonBeginX, 0)];

            [self.pagesBoundries addObject:nextPageValue];
        }
    }

    self.scrollView.contentSize =
    CGSizeMake(nextPageX, WORD_PICKER_SIZE.height);
}

- (UIButton *)wordButtonWithWord:(NSString *)word {
    
    UIButton *wordButton =
    [UIButton buttonWithType:UIButtonTypeSystem];
    
    [wordButton addTarget:self
                   action:@selector(wordButtonTapped:)
         forControlEvents:UIControlEventTouchUpInside];

    wordButton.backgroundColor =
    WORD_BUTTON_BACKGROUND_COLOR;
    
    [wordButton setTitleColor:WORD_BUTTON_TITLE_COLOR
                     forState:UIControlStateNormal];
    
    [wordButton setTitle:word
                forState:UIControlStateNormal];
    
    NSDictionary *titleLabelAttributes =
    [wordButton.titleLabel.attributedText attributesAtIndex:0
                                             effectiveRange:NULL];
    
    CGSize wordSize =
    [word sizeWithAttributes:titleLabelAttributes];
    
    CGFloat wordButtonWidth =
    WORD_BUTTON_TITLE_MARGIN + wordSize.width + WORD_BUTTON_TITLE_MARGIN;
    
    if (wordButtonWidth < WORD_BUTTON_MINIMUM_SIZE.width) {
        
        wordButtonWidth = WORD_BUTTON_MINIMUM_SIZE.width;
    }
    
    wordButton.frame =
    CGRectMake(0, WORD_BUTTON_VERTICAL_PADDING, wordButtonWidth, WORD_BUTTON_MINIMUM_SIZE.height - (WORD_BUTTON_VERTICAL_PADDING * 2));
    
    return wordButton;
}

- (void)wordButtonTapped:(id)sender {

    if (self.delegate == nil) {
        
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(wordPicker:didSelectWordAtIndex:)] == NO) {
        
        return;
    }
    
    NSUInteger index =
    [self.wordsButtons indexOfObject:sender];

    [self.delegate wordPicker:self
         didSelectWordAtIndex:index];
}

- (void)scrollForPagingToPoint:(CGPoint)contentOffset {

    //Animating to the exact expected contentOffset will not
    //animate correctly the dissapearance of the scroll indicators.
    //Instead, we animate to almost there and then call
    //setContentOffset:animated:.
    CGFloat almostThereX =
    contentOffset.x;
    
    if (almostThereX > self.lastTargetContentOffset.x) {
    
        //Scrolling to the left. Almost there 1px to the right.
        almostThereX++;
        
    } else {
        
        //Scrolling to the right. Almost there 1px to the left.
        almostThereX--;
    }
    
    [UIView animateWithDuration:0.25f
                          delay:0.0f
                        options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveEaseInOut
                     animations:^{

        self.scrollView.contentOffset =
                         CGPointMake(almostThereX, contentOffset.y);
                         
    } completion:^(BOOL finished) {

        [self.scrollView setContentOffset:contentOffset
                                 animated:YES];
    }];
}

- (void)scrollForBounceToPoint:(CGPoint)contentOffset {
    
    [self.scrollView setContentOffset:contentOffset
                             animated:YES];
}

#pragma mark - Protocols
#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (scrollView.isDragging == NO) {
        
        [self.scrollView flashScrollIndicators];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {

    self.lastTargetContentOffset =
    *targetContentOffset;
    
    *targetContentOffset =
    scrollView.contentOffset;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    if (self.pagesBoundries == nil) {
        
        [self scrollForPagingToPoint:self.lastTargetContentOffset];
    }
    
    CGPoint leftMostBoundry =
    [[self.pagesBoundries firstObject] CGPointValue];
    
    CGPoint rightMostBoundry =
    [[self.pagesBoundries lastObject] CGPointValue];

    if (scrollView.contentOffset.x <= leftMostBoundry.x) {
        
        [self scrollForBounceToPoint:leftMostBoundry];
        
        return;
    }
    
    if (scrollView.contentOffset.x >= rightMostBoundry.x) {
        
        [self scrollForBounceToPoint:rightMostBoundry];
        
        return;
    }
    
    for (int leftBoundryIndex = 0, rightBoundryIndex = 1;
         rightBoundryIndex < self.pagesBoundries.count;
         leftBoundryIndex++, rightBoundryIndex++) {
        
        CGPoint leftBoundry =
        [self.pagesBoundries[leftBoundryIndex] CGPointValue];
        
        CGPoint rightBoundry =
        [self.pagesBoundries[rightBoundryIndex] CGPointValue];
        
        if (scrollView.contentOffset.x >= leftBoundry.x &&
            scrollView.contentOffset.x <= rightBoundry.x) {
            
            if (self.lastTargetContentOffset.x > scrollView.contentOffset.x) {
                
                [self scrollForPagingToPoint:rightBoundry];
                
                return;
                
            } else {
                
                [self scrollForPagingToPoint:leftBoundry];
                
                return;
            }
        }
    }
}

@end
