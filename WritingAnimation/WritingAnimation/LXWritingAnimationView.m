//
//  WritingAnimationView.m
//  WritingAnimation
//
//  Created by 从今以后 on 15/12/11.
//  Copyright © 2015年 从今以后. All rights reserved.
//

@import CoreText;
#import "LXWritingAnimationView.h"

NS_ASSUME_NONNULL_BEGIN

static inline void PerformWithoutAnimation(void (^actionsWithoutAnimation)())
{
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    actionsWithoutAnimation();
    [CATransaction commit];
}

@implementation LXWritingAnimationView
{
    CALayer *_penLayer;
    CAShapeLayer *_textLayer;

    CABasicAnimation *_textLayerAnimation;
    CAKeyframeAnimation *_penLayerAnimation;

    BOOL _animating;
}

#pragma mark 初始化

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _commonInit];
    }
    return self;
}

- (nullable instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self _commonInit];
    }
    return self;
}

- (void)_commonInit
{
    _text = @"";
    _lineWidth = 1.0;
    _fillColor = nil;
    _strokeColor = [UIColor blackColor];
    _font = [UIFont systemFontOfSize:72.0];

    [self _setupTextLayer];
    [self _setupPenLayer];
    [self _setupTextLayerAnimation];
    [self _setupPenPathAnimation];
}

#pragma mark 布局方法

- (void)layoutSubviews
{
    [super layoutSubviews];

    [self _alignTextLayerToCenter];
}

- (CGSize)intrinsicContentSize
{
    return _textLayer.bounds.size;
}

- (CGSize)sizeThatFits:(CGSize)size
{
    return _textLayer.bounds.size;
}

#pragma mark setter

- (void)setFont:(UIFont *)font
{
    _font = font;
    [self _configureTextPath];
}

- (void)setText:(NSString *)text
{
    _text = text;
    [self _configureTextPath];
}

#pragma mark 文字图层

- (void)_setupTextLayer
{
    _textLayer = [CAShapeLayer layer];

    _textLayer.strokeEnd = 0;
    _textLayer.geometryFlipped = YES;
    _textLayer.fillColor = _fillColor.CGColor;
    _textLayer.strokeColor = _strokeColor.CGColor;

    [self.layer addSublayer:_textLayer];
}

- (void)_alignTextLayerToCenter
{
    _textLayer.position = (CGPoint){ CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds) };
}

- (void)_configureTextPath
{
    // Create path from text
    // See: http://www.codeproject.com/KB/iPhone/Glyph.aspx
    // License: The Code Project Open License (CPOL) 1.02 http://www.codeproject.com/info/cpol10.aspx

    CGMutablePathRef textPath = CGPathCreateMutable();

    NSDictionary *attributes = @{ NSFontAttributeName : _font };
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:_text
                                                                     attributes:attributes];

    CTLineRef line = CTLineCreateWithAttributedString((CFAttributedStringRef)attrString);
    CFArrayRef runArray = CTLineGetGlyphRuns(line);
    // for each RUN
    CFIndex count = CFArrayGetCount(runArray);
    for (CFIndex runIndex = 0; runIndex < count; ++runIndex)
    {
        // Get FONT for this run
        CTRunRef run = (CTRunRef)CFArrayGetValueAtIndex(runArray, runIndex);
        CTFontRef runFont = CFDictionaryGetValue(CTRunGetAttributes(run), kCTFontAttributeName);

        // for each GLYPH in run
        CFIndex count = CTRunGetGlyphCount(run);
        for (CFIndex runGlyphIndex = 0; runGlyphIndex < count; ++runGlyphIndex)
        {
            // get Glyph & Glyph-data
            CFRange thisGlyphRange = CFRangeMake(runGlyphIndex, 1);
            CGGlyph glyph;
            CGPoint position;
            CTRunGetGlyphs(run, thisGlyphRange, &glyph);
            CTRunGetPositions(run, thisGlyphRange, &position);

            // Get PATH of outline
            {
                CGPathRef letter = CTFontCreatePathForGlyph(runFont, glyph, NULL);
                CGAffineTransform t = CGAffineTransformMakeTranslation(position.x, position.y);
                CGPathAddPath(textPath, &t, letter);
                CGPathRelease(letter);
            }
        }
    }
    CFRelease(line);

    PerformWithoutAnimation(^{
        _textLayer.path = textPath;
        _penLayerAnimation.path = _textLayer.path;
        _textLayer.bounds = CGPathGetBoundingBox(textPath);
    });

    CGPathRelease(textPath);
}

#pragma mark 画笔

- (void)_setupPenLayer
{
    NSAssert(_textLayer != nil, @"_textLayer 为 nil。");

    UIImage *penImage = [UIImage imageNamed:@"pen"];

    _penLayer = [CALayer layer];
    _penLayer.contents = (id)penImage.CGImage;
    _penLayer.contentsScale = UIScreen.mainScreen.scale;

    /*  pathLayer.geometryFlipped = YES;
     penLayer 会用 pathLayer.path 作为自己的 path，所以锚点需翻转。 */
    _penLayer.anchorPoint = CGPointZero;
    _penLayer.bounds = (CGRect){ .size = penImage.size };

    [_textLayer addSublayer:_penLayer];
}

#pragma mark 动画

- (void)_setupTextLayerAnimation
{
    _textLayerAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    _textLayerAnimation.delegate = self;
    _textLayerAnimation.fromValue = @0;
    _textLayerAnimation.toValue = @1;
}

- (void)_setupPenPathAnimation
{
    _penLayerAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    _penLayerAnimation.calculationMode = kCAAnimationPaced;
}

- (void)_prepareForAnimation
{
    _textLayer.lineWidth   = _lineWidth;
    _textLayer.fillColor   = _fillColor.CGColor;
    _textLayer.strokeColor = _strokeColor.CGColor;

    _penLayerAnimation.duration = _duration;
    _textLayerAnimation.duration = _duration;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (flag) {
        PerformWithoutAnimation(^{
            _penLayer.hidden = YES;
            _textLayer.strokeEnd = 1.0;
        });
    }
}

#pragma mark 公共方法

- (void)startAnimation
{
    [self _prepareForAnimation];

    _penLayer.hidden = NO;

    [_penLayer addAnimation:_penLayerAnimation forKey:nil];
    [_textLayer addAnimation:_textLayerAnimation forKey:nil];
}

- (void)endAnimation
{
    [_penLayer removeAllAnimations];
    [_textLayer removeAllAnimations];
}

@end

NS_ASSUME_NONNULL_END
