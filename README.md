**ZRYWordPicker** is a really simple horizontal word picker specially crafted for the top of the keyboard of any iOS 7 app. If your app has predefined words that your user can pick, instead of type, then this will likely save him some seconds for each word.

**As seen in**
* [IOU - I owe you](https://itunes.apple.com/us/app/i.o.u.-i-owe-you/id689637570?ls=1&mt=8) (_Featured on the AppStore as Designed for iOS 7_)

**Sample screenshots**

<img src="https://raw.github.com/marianoabdala/ZRYWordPicker/master/Resources/Words.png" width="200" />&nbsp;<img src="https://raw.github.com/marianoabdala/ZRYWordPicker/master/Resources/Money.png" width="200" />

**Usage sample**

```
-  (void)initializeWordPicker {

    ZRYWordPicker *wordPicker =
    [[ZRYWordPicker alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    
    wordPicker.dataSource = self;
    wordPicker.delegate = self;
    
    self.textField.inputAccessoryView = wordPicker;
}

- (NSUInteger)numberOfWordsInWordPicker:(ZRYWordPicker *)wordPicker {
    
    return self.words.count;
}

- (NSString *)wordPicker:(ZRYWordPicker *)wordPicker wordAtIndex:(NSUInteger)index {
    
    return self.words[index];
}

- (void)wordPicker:(ZRYWordPicker *)wordPicker didSelectWordAtIndex:(NSUInteger)index {

    ...
}
```