//
//  DXMessageToolBar.m
//  Share
//
//  Created by dhcdht on 14-5-22.
//  Copyright (c) 2014年 Share. All rights reserved.
//

#import "DXMessageToolBar.h"
#import "RegexKitLite.h"

#define kInputTextViewMinHeight 30
#define kInputTextViewMaxHeight 50

#define kHorizontalPadding 10
#define kVerticalPadding 7.5

#define kButtonHeight 31
#define kButtonPadding 7

#define kTouchToRecord @"按住说话"
#define kTouchToFinish @"松开发送"

#define kRegex_face_all @".*(\\[[\\u4e00-\\u9fa5]+\\]$)"   //表情删除匹配
#define kRegex_emoji_all @"([\\ud83c\\udc00-\\ud83c\\udfff]|[\\ud83d\\udc00-\\ud83d\\udfff]|[\\u2600-\\u27ff])"// emoji表情删除匹配
#define kRegex_face     @"(\\[[\\u4e00-\\u9fa5]+\\])"      //表情匹配


@interface DXMessageToolBar()<UITextViewDelegate, ChatFaciaViewDelegate>
{
    CGFloat _version;
    CGFloat _previousTextViewContentHeight; //上一次inputTextView的contentSize.height
    CGRect _keyboardFrame;
    BOOL _isKeyboardAnimate;
    BOOL _isShowButtomView;
    NSString *_tempContent;
    KeyboardStyle _keyboardStyle;
    UIView *_activityButtomView;            //当前活跃的底部扩展页面
    NSRange _inputSelectRange;                  //光标的位置
    
    BOOL _isOtherInputSource;//是否是第三方输入法 默认为YES
}
@end

@implementation DXMessageToolBar
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _delegate = nil;
    self.inputTextView.delegate = nil;
    self.inputTextView = nil;
}

- (instancetype)initWithFrame:(CGRect)frame style:(KeyboardStyle)style {
    if (frame.size.height < (kVerticalPadding * 2 + kInputTextViewMinHeight)) {
        frame.size.height = kVerticalPadding * 2 + kInputTextViewMinHeight;
    }
    _keyboardStyle = style;
    if (_keyboardStyle != KeyboardStyleChat) {
        frame = CGRectMake(0, kScreenHeight, kScreenWidth, [[self class] defaultHeight]);
    }
    self = [super initWithFrame:frame];
    if (self) {
        [self setUI];
    }
    return self;
}

- (void)setUI {
    // 键盘弹出或隐藏监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    self.backgroundColor = UIColorHex(0xfafafa);
    _isKeyboardAnimate = YES;
    _isShowButtomView = NO;
    _version = [[[UIDevice currentDevice] systemVersion] floatValue];
    _activityButtomView = nil;
    
    self.toolbarView = [[UIView alloc] initWithFrame:AutoWHCGRectMake(0, 0, self.frame.size.width, kInputTextViewMinHeight, NO, YES)];
    self.toolbarView.height += kVerticalPadding*2;
    self.toolbarView.backgroundColor = [UIColor clearColor];
    self.toolbarView.layer.borderWidth = 0.5f;
    self.toolbarView.layer.borderColor = UIColorHex(0xdcdcdc).CGColor;
    [self addSubview:self.toolbarView];
    
    NSArray *normalImages, *highlightImages;
    if (_keyboardStyle == KeyboardStyleChat) {
        normalImages = @[@"chat_speak", @"chat_emoticon", @"chat_more"];
        highlightImages = @[@"chat_speak_s", @"chat_emoticon_s", @"chat_more_s"];
    } else {
        normalImages = @[@"chat_emoticon"];
        highlightImages = @[@"chat_emoticon_s"];
    }
    NSMutableArray *buttonArray = [[NSMutableArray alloc]initWithCapacity:0];
    for (int i = 0; i < normalImages.count; i++) {
        UIButton *button = [[UIButton alloc] init];
        button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
        [button setImage:[UIImage imageNamed:normalImages[i]] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:highlightImages[i]] forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = 2800+i;
        [button setTouchAreaInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
        [self.toolbarView addSubview:button];
        [buttonArray addObject:button];
    }
    // 发布的键盘只要表情View
    if (_keyboardStyle != KeyboardStylePublish) {
        // 初始化输入框
        self.inputTextView = [[DXMessageTextView  alloc] init];
        self.inputTextView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        self.inputTextView.returnKeyType = UIReturnKeySend;
        self.inputTextView.enablesReturnKeyAutomatically = YES; // UITextView内部判断send按钮是否可以用
        self.inputTextView.delegate = self;
        self.inputTextView.font = [UIFont systemFontOfSize:13.0f];
        self.inputTextView.layer.borderColor = kColorBlack.CGColor;
        self.inputTextView.backgroundColor = kColorNavBground;
        self.inputTextView.layer.borderWidth = 1.0f;
        self.inputTextView.layer.cornerRadius = 10;
        if ([self.inputTextView respondsToSelector:@selector(setTextContainerInset:)]) {
            UIEdgeInsets inset = self.inputTextView.textContainerInset;
            inset.left = 10;
            inset.right = 10;
            self.inputTextView.textContainerInset = inset;
        }
        self.inputTextView.layoutManager.allowsNonContiguousLayout = NO;
        _previousTextViewContentHeight = [self getTextViewContentH:self.inputTextView];
        [self.toolbarView addSubview:self.inputTextView];
    }
    
    if (_keyboardStyle == KeyboardStyleChat) {
        // 聊天键盘样式
        // 转变输入样式
        self.styleChangeButton = buttonArray[0];
        self.styleChangeButton.frame = AutoWHCGRectMake(10, kButtonPadding, kButtonHeight, kButtonHeight, YES, YES);
        
        // 输入栏frame设置
        self.inputTextView.frame = AutoWHCGRectMake(self.styleChangeButton.right + 10, kVerticalPadding, kScreenWidth-self.styleChangeButton.width*3-10*5, kInputTextViewMinHeight, NO, YES);
        
        //录音按钮(与输入栏重叠，但刚开始隐藏)
        self.recordButton = [[UIButton alloc] initWithFrame:self.inputTextView.frame];
        self.recordButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
        [self.recordButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        self.recordButton.layer.cornerRadius = 5;
        self.recordButton.layer.masksToBounds = YES;
        self.recordButton.layer.borderWidth = 0.5f;
        self.recordButton.layer.borderColor = UIColorHex(0xdcdcdc).CGColor;
        [self.recordButton setBackgroundImage:[UIImage imageWithColor:kColorNavBground] forState:UIControlStateHighlighted];
        [self.recordButton setTitle:kTouchToRecord forState:UIControlStateNormal];
        [self.recordButton setTitle:kTouchToFinish forState:UIControlStateHighlighted];
        self.recordButton.hidden = YES;
        [self.recordButton addTarget:self action:@selector(recordButtonTouchDown) forControlEvents:UIControlEventTouchDown];
        [self.recordButton addTarget:self action:@selector(recordButtonTouchUpOutside) forControlEvents:UIControlEventTouchUpOutside];
        [self.recordButton addTarget:self action:@selector(recordButtonTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
        [self.recordButton addTarget:self action:@selector(recordDragOutside) forControlEvents:UIControlEventTouchDragExit];
        [self.recordButton addTarget:self action:@selector(recordDragInside) forControlEvents:UIControlEventTouchDragEnter];
        [self.toolbarView addSubview:self.recordButton];
        
        // 表情按钮
        self.faceButton = buttonArray[1];
        self.faceButton.frame = AutoWHCGRectMake(self.inputTextView.right + 10, kButtonPadding, kButtonHeight, kButtonHeight, YES, YES);
        
        // 更多按钮
        self.moreButton = buttonArray[2];
        self.moreButton.frame = AutoWHCGRectMake(self.faceButton.right + 10, kButtonPadding, kButtonHeight, kButtonHeight, YES, YES);
        
        // 语音操作提示view
        self.recordView = [[DXRecordView alloc] init];
    } else if (_keyboardStyle == KeyboardStyleComment) {
        // 评论键盘样式
        // 输入栏frame设置
        self.inputTextView.frame = AutoWHCGRectMake(kHorizontalPadding, kVerticalPadding, kScreenWidth - kButtonHeight - kHorizontalPadding - 15 * 2, kInputTextViewMinHeight, NO, YES);
        // 表情按钮
        self.faceButton = buttonArray[0];
        self.faceButton.tag = 2801;
        self.faceButton.frame = AutoWHCGRectMake(self.inputTextView.right + 15, AutoWHGetHeight(kButtonPadding), kButtonHeight, kButtonHeight, NO, NO);
    } else if (_keyboardStyle == KeyboardStylePublish) {
        // 表情按钮
        self.faceButton = buttonArray[0];
        self.faceButton.tag = 2801;
        self.faceButton.frame = AutoWHCGRectMake(kHorizontalPadding, kButtonPadding, kButtonHeight, kButtonHeight, YES, YES);
    }
    _isOtherInputSource = YES;
}

#pragma mark - UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if ([self.delegate respondsToSelector:@selector(inputTextViewWillBeginEditing:)]) {
        [self.delegate inputTextViewWillBeginEditing:self.inputTextView];
    }
    self.faceButton.selected = NO;
    self.styleChangeButton.selected = NO;
    self.moreButton.selected = NO;
    //还原按钮图标
    [self reSetButtonImage];
    return YES;
}

-(BOOL)textViewShouldEndEditing:(UITextView *)textView{
    if ([self.delegate respondsToSelector:@selector(textViewWillHide)] && _isOtherInputSource) {
        [self.delegate textViewWillHide];
    }
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [textView resignFirstResponder];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        _inputSelectRange = NSMakeRange(0, 0);
        if ([self.delegate respondsToSelector:@selector(didSendText:)]) {
            if ([self.delegate didSendText:textView.text]) {
                self.inputTextView.text = @"";
                [self willShowInputTextViewToHeight:[self getTextViewContentH:self.inputTextView]];
            }
        }
        return NO;
    }
    
    if ([self.delegate respondsToSelector:@selector(inputTextView:shouldChangeTextInRange:replacementText:)]) {
        BOOL result = [self.delegate inputTextView:textView shouldChangeTextInRange:range replacementText:text];
        [self willShowInputTextViewToHeight:[self getTextViewContentH:self.inputTextView]];
        return  result;
    }
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    [self willShowInputTextViewToHeight:[self getTextViewContentH:textView]];
    if ([self.delegate respondsToSelector:@selector(textViewDidChange:)]) {
        [self.delegate textViewDidChange:textView];
    }
}

- (void)setInputText:(NSString*)text {
    self.inputTextView.text = text;
    [self textViewDidChange:self.inputTextView];
}

#pragma mark - ChatFaciaViewDelegate
- (void)chatFaciaView:(ChatFacialView *)chatFaciaView selectedEmoticonView:(EmoticonView *)view {
	NSString *textStr = self.inputTextView.text;
	if ([view.emoticonName isEqualToString:@"删除"]) {
		if (textStr.length > 0) {
			if ([textStr isMatchedByRegex:kRegex_face_all]) {
                [self.inputTextView selectedTextRange];
				//取到最后一个删除掉
				NSString *strToDelete = [[textStr componentsMatchedByRegex:kRegex_face] lastObject];
				//在文本框中删除faceName
				self.inputTextView.text = [textStr substringToIndex:textStr.length - strToDelete.length];
			} else {
				//删除一个文字
				self.inputTextView.text = [textStr substringToIndex:textStr.length - 1];
			}
		}
	} else {
		//添加表情到文本框
		if (!view.emoticonName) {
			return;
		}
        NSMutableString *tempStr = [NSMutableString stringWithString:self.inputTextView.text];
        
        if (_inputSelectRange.length+_inputSelectRange.location>self.inputTextView.text.length) {
            _inputSelectRange.length = 0;
            _inputSelectRange.location = self.inputTextView.text.length;
        }
        [self.inputTextView.text stringByReplacingCharactersInRange:_inputSelectRange withString:view.emoticonName];
        [tempStr insertString:view.emoticonName atIndex:_inputSelectRange.location];
        _inputSelectRange.location += view.emoticonName.length;
        self.inputTextView.text = tempStr;
	}
	// 若是发布键盘样式，不需要对输入栏高度和滚动等进行调整
	if (_keyboardStyle != KeyboardStylePublish) {
		//更新键盘高度
		[self willShowInputTextViewToHeight:[self getTextViewContentH:self.inputTextView]];
	}
	if ([self.delegate respondsToSelector:@selector(textViewDidChange:)]) {
		[self.delegate textViewDidChange:self.inputTextView];
	}
}

- (void)chatFaciaViewDidSendButtonClicked:(ChatFacialView *)chatFaciaVie {
    if (_keyboardStyle == KeyboardStylePublish) {
        //发布类型时点击完成收回表情键盘
        [self willShowBottomView:nil];
    } else {
        NSString *chatText = self.inputTextView.text;
        if (chatText.length > 0) {
            _inputSelectRange = NSMakeRange(0, 0);
            if ([self.delegate respondsToSelector:@selector(didSendText:)]) {
                if ([self.delegate didSendText:chatText]) {
                    self.inputTextView.text = @"";
                    [self willShowInputTextViewToHeight:[self getTextViewContentH:self.inputTextView]];
                }
            }
        }
    }
}

// emoji表情删除或者添加
- (void)chatFaciaView:(ChatFacialView *)chatFaciaView emojiStr:(NSString *)emojiStr {
    NSMutableString *tempStr = [NSMutableString stringWithString:self.inputTextView.text];
    if (emojiStr.length) {
        // 若回传字符串有值就是添加emoji
        if (_inputSelectRange.length + _inputSelectRange.location > self.inputTextView.text.length) {
            _inputSelectRange.length = 0;
            _inputSelectRange.location = self.inputTextView.text.length;
        }
        [self.inputTextView.text stringByReplacingCharactersInRange:_inputSelectRange withString:emojiStr];
        [tempStr insertString:emojiStr atIndex:_inputSelectRange.location];
        _inputSelectRange.location += emojiStr.length;
    } else {
        // 回传字符串为空则表示删除
        if (tempStr.length > 0) {
            //取到最后一个emoji并判断末尾是不是emoji，是就删除掉否则只删除一个字符
            NSString *strToDelete = [[tempStr componentsMatchedByRegex:kRegex_emoji_all] lastObject];
            NSString *lastStr = [tempStr substringWithRange:NSMakeRange(tempStr.length - strToDelete.length, strToDelete.length)];
            if ([strToDelete isEqual:lastStr]) {
                [tempStr deleteCharactersInRange:NSMakeRange(tempStr.length - strToDelete.length, strToDelete.length)];
            } else {
                [tempStr deleteCharactersInRange:NSMakeRange(tempStr.length - 1, 1)];
            }
            
        }
    }
    self.inputTextView.text = tempStr;
    //更新键盘高度
    [self willShowInputTextViewToHeight:[self getTextViewContentH:self.inputTextView]];
    if (self.inputTextView.contentHeight >= kInputTextViewMaxHeight) {
        [self.inputTextView scrollToBottomAnimated:YES];
    }
}

#pragma mark - UIKeyboardNotification
// 键盘弹出
- (void)keyboardWillShow:(NSNotification *)notification {
    // 不在当前controller不响应键盘弹出事件
    if ([self.viewController.navigationController.topViewController isEqual:self.viewController]) {
        _inputSelectRange = [self selectedRange:self.inputTextView];
        if (_keyboardStyle == KeyboardStylePublish) {
            [self reSetButtonImage];
            self.faceButton.selected = NO;
        }
        [self keyboardAction:notification];
    }
}

// 键盘隐藏
- (void)keyboardWillHide:(NSNotification *)notification {
    if (_isKeyboardAnimate) {
        [self keyboardAction:notification];
    }
    _inputSelectRange = [self selectedRange:self.inputTextView];
}

// 记录键盘光标的位置
- (NSRange)selectedRange:(UITextView *)textView {
    // 根据NSTextRange转换成NSRange
    UITextPosition *beginning = self.inputTextView.beginningOfDocument;
    UITextRange *selectedRange = self.inputTextView.selectedTextRange;
    UITextPosition *selectionStart = selectedRange.start;
    UITextPosition *selectionEnd = selectedRange.end;
    NSInteger location = [self.inputTextView offsetFromPosition:beginning toPosition:selectionStart];
    NSInteger length = [self.inputTextView offsetFromPosition:selectionStart toPosition:selectionEnd];
    return NSMakeRange(location, length);
}

// 键盘弹出或者隐藏时调整输入栏的位置和高度
- (void)keyboardAction:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    CGRect endFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect beginFrame = [userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGFloat duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    _keyboardFrame = endFrame.origin.y < beginFrame.origin.y ? endFrame : beginFrame;
    void(^animations)() = ^{
        [self willShowKeyboardFromFrame:beginFrame toFrame:endFrame];
    };
    void(^completion)(BOOL) = ^(BOOL finished){
    };
    [UIView animateWithDuration:duration delay:0.0f options:(curve << 16 | UIViewAnimationOptionBeginFromCurrentState) animations:animations completion:completion];
}

#pragma mark - change frame
- (void)willShowBottomHeight:(CGFloat)bottomHeight
{
    CGRect fromFrame = self.frame;
    CGFloat toHeight = self.toolbarView.frame.size.height + bottomHeight;
    CGRect toFrame = CGRectMake(fromFrame.origin.x, fromFrame.origin.y + (fromFrame.size.height - toHeight), fromFrame.size.width, toHeight);
    
    //如果需要将所有扩展页面都隐藏，而此时已经隐藏了所有扩展页面，则不进行任何操作
    if(bottomHeight == 0 && self.frame.size.height == self.toolbarView.frame.size.height) {
        return;
    }
    
    if (bottomHeight == 0) {
        _isShowButtomView = NO;
        if (_keyboardStyle != KeyboardStyleChat) {
            toFrame.origin.y = kBodyHeight;
        }
    } else {
        _isShowButtomView = YES;
        if (_keyboardStyle != KeyboardStyleChat) {
            if (bottomHeight == self.faceView.height) {
                toFrame.origin.y = kBodyHeight - self.toolbarView.frame.size.height - self.faceView.height;
            } else {
                toFrame.origin.y = _keyboardFrame.origin.y - self.toolbarView.frame.size.height - 60;
            }
        }
    }
    self.frame = toFrame;
    
    if (_delegate && [_delegate respondsToSelector:@selector(didChangeFrameToHeight:)]) {
        [_delegate didChangeFrameToHeight:toHeight];
    }
}

- (void)willShowBottomView:(UIView *)bottomView
{
    CGFloat bottomHeight = bottomView ? bottomView.frame.size.height : 0;
    [self willShowBottomHeight:bottomHeight];
    if (bottomView) {
        CGRect rect = bottomView.frame;
        rect.origin.y = CGRectGetMaxY(self.toolbarView.frame);
        bottomView.frame = rect;
        [self addSubview:bottomView];
    }
    if (![_activityButtomView isEqual:bottomView]) {
        if (_activityButtomView) {
            [_activityButtomView removeFromSuperview];
        }
        _activityButtomView = bottomView;
    }
}

- (void)willShowKeyboardFromFrame:(CGRect)beginFrame toFrame:(CGRect)toFrame
{
    if (beginFrame.origin.y == [[UIScreen mainScreen] bounds].size.height) {
        //一定要把_activityButtomView置为空
        [self willShowBottomHeight:toFrame.size.height];
        if (_activityButtomView) {
            [_activityButtomView removeFromSuperview];
        }
    } else if (toFrame.origin.y == [[UIScreen mainScreen] bounds].size.height) {
        [self willShowBottomHeight:0];
    } else {
        [self willShowBottomHeight:toFrame.size.height];
    }
}

- (void)willShowInputTextViewToHeight:(CGFloat)toHeight {
    if (toHeight < kInputTextViewMinHeight) {
        toHeight = kInputTextViewMinHeight;
    } else if (toHeight > kInputTextViewMaxHeight) {
        toHeight = kInputTextViewMaxHeight;
    }
    if (toHeight != _previousTextViewContentHeight) {
        CGFloat changeHeight = toHeight - _previousTextViewContentHeight;
        
        CGRect rect = self.frame;
        rect.size.height += changeHeight;
        rect.origin.y -= changeHeight;
        self.frame = rect;
        
        rect = self.toolbarView.frame;
        rect.size.height += changeHeight;
        self.toolbarView.frame = rect;
        self.faceButton.centerY = self.toolbarView.center.y;
        _previousTextViewContentHeight = toHeight;
        
        if (_delegate && [_delegate respondsToSelector:@selector(didChangeFrameToHeight:)]) {
            [_delegate didChangeFrameToHeight:self.frame.size.height];
        }
    }
}

- (CGFloat)getTextViewContentH:(UITextView *)textView {
    CGFloat textHeight = 0;
    if (_version >= 7.0) {
        textHeight = ceilf([textView sizeThatFits:textView.frame.size].height);
    } else {
        textHeight = textView.contentSize.height;
    }
    return textHeight;
}

#pragma mark - action
- (void)buttonAction:(UIButton *)button {
    // 还原按钮图标
    [self reSetButtonImage];
    _isOtherInputSource=!_isOtherInputSource;
    button.selected = !button.selected;
    if (button.selected) {
        [button setImage:[UIImage imageNamed:@"chat_character"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"chat_character_s"] forState:UIControlStateHighlighted];
    }
    NSInteger tag = button.tag;
    switch (tag) {
        case 2800://切换状态
        {
            if (button.selected) {
                self.faceButton.selected = NO;
                self.moreButton.selected = NO;
                //录音状态下，不显示底部扩展页面
                [self willShowBottomView:nil];
                
                //将inputTextView内容置空，以使toolbarView回到最小高度
                _tempContent = self.inputTextView.text;
                self.inputTextView.text = @"";
                [self textViewDidChange:self.inputTextView];
                [self.inputTextView resignFirstResponder];
            }
            else{
                self.inputTextView.text = _tempContent;
                [self textViewDidChange:self.inputTextView];
                //键盘也算一种底部扩展页面
                [self.inputTextView becomeFirstResponder];
            }
            
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.recordButton.hidden = !button.selected;
                self.inputTextView.hidden = button.selected;
            } completion:^(BOOL finished) {
            }];
        }
            break;
        case 2801://表情
        {
            if (button.selected) {
                if (!self.faceView) {
                    // 表情图片view(用到了再创建)
                    self.faceView = [[ChatFacialView alloc] initWithFrame:CGRectMake(0, (kVerticalPadding * 2 + kInputTextViewMinHeight), self.frame.size.width, _keyboardFrame.size.height)];
                    self.faceView.isEmoji = YES;
                    [self.faceView setDelegate:self];
                    self.faceView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
                }
                
                if (_keyboardStyle != KeyboardStyleChat) {
                    // 属于发布键盘样式时，把"发送"按钮改成"完成"
                    self.faceView.returnKeyType = FaceReturnKeyTypeDone;
                    _isKeyboardAnimate = NO;
                    [self.inputTextView resignFirstResponder];
                    _isKeyboardAnimate = YES;
                    [self willShowBottomView:self.faceView];
                    return;
                }
                self.moreButton.selected = NO;
                //如果选择表情并且处于录音状态，切换成文字输入状态，但是不显示键盘
                if (self.styleChangeButton.selected) {
                    self.styleChangeButton.selected = NO;
                    self.inputTextView.text = _tempContent;
                    [self textViewDidChange:self.inputTextView];
                } else{//如果处于文字输入状态，使文字输入框失去焦点
                    _isKeyboardAnimate = NO;
                    [self.inputTextView resignFirstResponder];
                    _isKeyboardAnimate = YES;
                }
                
                [self willShowBottomView:self.faceView];
                [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    self.recordButton.hidden = button.selected;
                    self.inputTextView.hidden = !button.selected;
                } completion:^(BOOL finished) {
                    
                }];
            } else {
                if (_keyboardStyle != KeyboardStyleChat) {
                    [self.inputTextView becomeFirstResponder];
                } else {
                    if (!self.styleChangeButton.selected) {
                        [self.inputTextView becomeFirstResponder];
                    } else {
                        [self willShowBottomView:nil];
                    }
                }
            }
        }
            break;
        case 2802://更多
        {
            if (button.selected) {
                self.faceButton.selected = NO;
                //如果选择表情并且处于录音状态，切换成文字输入状态，但是不显示键盘
                if (self.styleChangeButton.selected) {
                    self.styleChangeButton.selected = NO;
                    self.inputTextView.text = _tempContent;
                    [self textViewDidChange:self.inputTextView];
                }
                else{//如果处于文字输入状态，使文字输入框失去焦点
                    _isKeyboardAnimate = NO;
                    [self.inputTextView resignFirstResponder];
                    _isKeyboardAnimate = YES;
                }
                if (!self.moreView) {
                    // 更多菜单按钮入口(用到了再创建)
                    self.moreView = [[DXChatBarMoreView alloc] initWithFrame:CGRectMake(0, (kVerticalPadding * 2 + kInputTextViewMinHeight), kScreenWidth, 215)];
                    self.moreView.backgroundColor = self.backgroundColor;
                    self.moreView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
                    if ([self.delegate respondsToSelector:@selector(setMoreViewDelegate)]) {
                        [self.delegate setMoreViewDelegate];
                    }
                }
                
                [self willShowBottomView:self.moreView];
                [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    self.recordButton.hidden = button.selected;
                    self.inputTextView.hidden = !button.selected;
                } completion:^(BOOL finished) {
                    
                }];
            }else{
                self.styleChangeButton.selected = NO;
                [self.inputTextView becomeFirstResponder];
            }
        }
            break;
    }
}

#pragma mark - 语音通讯相关
- (void)recordButtonTouchDown
{
    if (_delegate && [_delegate respondsToSelector:@selector(didStartRecordingVoiceAction:)]) {
        [_delegate didStartRecordingVoiceAction:self.recordView];
    }
    
    if ([self.recordView isKindOfClass:[DXRecordView class]]) {
        [(DXRecordView *)self.recordView recordButtonTouchDown];
    }
}

- (void)recordButtonTouchUpOutside
{
    if (_delegate && [_delegate respondsToSelector:@selector(didCancelRecordingVoiceAction:)])
    {
        [_delegate didCancelRecordingVoiceAction:self.recordView];
    }
    
    if ([self.recordView isKindOfClass:[DXRecordView class]]) {
        [(DXRecordView *)self.recordView recordButtonTouchUpOutside];
    }
}

- (void)recordButtonTouchUpInside
{
    if ([self.delegate respondsToSelector:@selector(didFinishRecoingVoiceAction:)])
    {
        [self.delegate didFinishRecoingVoiceAction:self.recordView];
    }
    
    if ([self.recordView isKindOfClass:[DXRecordView class]]) {
        [(DXRecordView *)self.recordView recordButtonTouchUpInside];
    }
}

- (void)recordDragOutside
{
    if ([self.delegate respondsToSelector:@selector(didDragOutsideAction:)])
    {
        [self.delegate didDragOutsideAction:self.recordView];
    }
    
    if ([self.recordView isKindOfClass:[DXRecordView class]]) {
        [(DXRecordView *)self.recordView recordButtonDragOutside];
    }
}

- (void)recordDragInside
{
    if ([self.delegate respondsToSelector:@selector(didDragInsideAction:)])
    {
        [self.delegate didDragInsideAction:self.recordView];
    }
    
    if ([self.recordView isKindOfClass:[DXRecordView class]]) {
        [(DXRecordView *)self.recordView recordButtonDragInside];
    }
}

#pragma mark - public
/// 还原按钮图标
- (void)reSetButtonImage {
    [self.styleChangeButton setImage:[UIImage imageNamed:@"chat_speak"] forState:UIControlStateNormal];
    [self.styleChangeButton setImage:[UIImage imageNamed:@"chat_speak_s"] forState:UIControlStateHighlighted];
    [self.faceButton setImage:[UIImage imageNamed:@"chat_emoticon"] forState:UIControlStateNormal];
    [self.faceButton setImage:[UIImage imageNamed:@"chat_emoticon_s"] forState:UIControlStateHighlighted];
    [self.moreButton setImage:[UIImage imageNamed:@"chat_more"] forState:UIControlStateNormal];
    [self.moreButton setImage:[UIImage imageNamed:@"chat_more_s"] forState:UIControlStateHighlighted];
}

/// 停止编辑
- (BOOL)endEditing:(BOOL)force {
    BOOL result = [super endEditing:force];
    if (_activityButtomView) {
        self.styleChangeButton.selected = NO;
        self.faceButton.selected = NO;
        self.moreButton.selected = NO;
        [self reSetButtonImage];
        [self willShowBottomView:nil];
    }
    
    return result;
}

/// 获取默认高度
+ (CGFloat)defaultHeight {
    return AutoWHGetHeight(kInputTextViewMinHeight) + kVerticalPadding * 2;
}

@end
