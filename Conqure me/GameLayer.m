//
//  GameLayer.m
//  Conqure me
//
//  Created by 1 on 1/10/14.
//  Copyright 2014 individual. All rights reserved.
//  This is Two Play

#import "GameLayer.h"
#import "Constant.h"

@implementation GameLayer


+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GameLayer *layer = [GameLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}


-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
    self = [super init];
    if(self == nil)
        return nil;

    size = [[CCDirector sharedDirector] winSize];
    m_NormalIPhone = NO;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && [[UIScreen mainScreen] scale] == 1.0) {
        m_NormalIPhone = YES;
    }
    m_isRed = YES;
    m_Branch = NO;
    m_touchCount = 0;
    m_redPolygonCount = 0;
    m_bluePolygonCount = 0;

    
    m_scoreBlue = 0;
    m_scoreRed = 0;
    
    m_blueSpriteArray = [[NSMutableArray alloc] initWithCapacity:0];
    m_redSpriteArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    
    lblBlue = [CCLabelTTF labelWithString:@"BLUE:0" fontName:@"Thonburi" fontSize:20];
    lblBlue.color = ccBLUE;
    lblBlue.anchorPoint = ccp(0, 1);
    lblBlue.position = ccp(0, size.height);
    
    lblRed = [CCLabelTTF labelWithString:@"RED:0" fontName:@"Thonburi" fontSize:20];
    lblRed.color = ccRED;
    lblRed.anchorPoint = ccp(1,1);
    lblRed.position = ccp(size.width, size.height);
    
    lblWhichTeam = [CCLabelTTF labelWithString:@"Red Team" fontName:@"Thonburi" fontSize:20];
    lblWhichTeam.position = ccp(size.width / 2, size.height * 6 / 7);
    [self addChild:lblWhichTeam];
    
    for (int i = 0; i < 50; i ++) {
        m_drawBluePolygon[i] = NO;
        m_drawRedPolygon[i] = NO;
    }
    
    
    [self addChild:lblBlue];
    [self addChild:lblRed];
    
    [self setTouchEnabled:YES];
   	return self;
}

- (void) draw
{
    [super draw];
    [self drawBoards];
    [self drawPolygon];
}

- (void) drawPolygon
{
    // draw Red Polygon
    for (int i = 0; i < m_redPolygonCount; i++) {
        if (m_drawRedPolygon[i] == NO) {
            continue;
        }
        for (int j = 0; j < m_rPolygonLineCount[i] - 1; j++) {
            int startId = m_redDrawPoints[i][j];
            int endId = m_redDrawPoints[i][j + 1];
            [self drawLineWithFirstPoint:startId SeconPoint:endId LineColor:YES];
        }
        [self drawLineWithFirstPoint:m_redDrawPoints[i][0] SeconPoint:m_redDrawPoints[i][m_rPolygonLineCount[i] - 1] LineColor:YES];
    }
    
    //draw Blue Polygon
    for (int i = 0; i < m_bluePolygonCount; i++) {
        if (m_drawBluePolygon[i] == NO) {
            continue;
        }
        for (int j = 0; j < m_bPolygonLineCount[i] - 1; j++) {
            int startId = m_blueDrawPoints[i][j];
            int endId = m_blueDrawPoints[i][j + 1];
            [self drawLineWithFirstPoint:startId SeconPoint:endId LineColor:NO];
        }
        [self drawLineWithFirstPoint:m_blueDrawPoints[i][0] SeconPoint:m_blueDrawPoints[i][m_bPolygonLineCount[i] - 1] LineColor:NO];
    }
}

- (void) updateScoreLabel
{
    NSString* str;
    str = [NSString stringWithFormat:@"Blue:%d", m_scoreBlue];
    lblBlue.string = str;
    
    str = [NSString stringWithFormat:@"RED:%d", m_scoreRed];
    lblRed.string = str;
}
- (void) drawBoards
{
    //draw Grid Borad.
    ccGLEnable(GL_LINES);
    for(int i = 0 ; i <  COL; i++)
    {
        float startX = XSTART + XSEGMENT * i;
        float endX   = XSTART + XSEGMENT * i;
        float startY = YSTART;
        float endY   = YSTART  + YSEGMENT  * (ROW - 1);
        CGPoint startPoint = CGPointMake(startX, startY);
        CGPoint endPoint = CGPointMake(endX, endY);
        glLineWidth(5.0f);
        ccDrawColor4B(100, 100, 100, 200); //Color of the line RGBA
        ccDrawLine(startPoint, endPoint);
    }
    for (int i = 0 ; i < ROW; i++) {
        float startX = XSTART ;
        float endX   = XSTART + (COL - 1) * XSEGMENT;
        float startY = YSTART + YSEGMENT * i;
        float endY   = YSTART + YSEGMENT * i;
        CGPoint startPoint = CGPointMake(startX, startY);
        CGPoint endPoint = CGPointMake(endX, endY);
        glLineWidth(5.0f);
        ccDrawColor4B(100, 100, 100, 200); //Color of the line RGBA
        ccDrawLine(startPoint, endPoint);
    }
}

- (BOOL) checkOldPoint:(int) nTouchNumber
{
    //check  whether this point was tapped
    for (int i = 0; i < m_touchCount; i++) {
        if (nTouchNumber == m_touchArray[i]) {
            return NO;
        }
    }
    m_touchArray[m_touchCount] = nTouchNumber;
    m_touchCount ++;
    return YES;
}

- (void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    UITouch * pTouch = [touches anyObject];
	CGPoint location = [pTouch locationInView: [pTouch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    int x = (location.x - XSTART) / XSEGMENT;
    int y = (location.y - YSTART) / YSEGMENT;
    
    int xDelta = abs(location.x - XSTART - x * XSEGMENT);
    int yDelta = abs(location.y - YSTART - y * YSEGMENT);
    
    if (xDelta * 2 > XSEGMENT) {
        x ++;
    }
    if (yDelta * 2 > YSEGMENT) {
        y ++;
    }
    
    m_remainArray = [[NSMutableArray alloc] initWithCapacity:0];
    BOOL m_Outside = YES;
    m_SquareFour = NO;

    m_CntFirst = -1;
    m_CntSecond = -1;
    m_branchCount = 0;
    m_lastStackSearch = -1;
    m_CntStack = 0;
    m_UseStackFound = NO;
    m_CntUseStack = 0;

    
    if (x > -1 && x < COL && y > -1 && y < ROW) {
        m_Outside = NO;
    }
    
    if (m_Outside == YES) {
        return;
    }
    
    int xPos = XSTART + x * XSEGMENT;
    int yPos = YSTART + y * YSEGMENT;
    nTouchId = y * COL + x;
    
    if ([self checkOldPoint:nTouchId] == NO) {
        return;
    }
    
    

    CCSprite* spr;
    if (m_isRed == YES) {
        spr = [CCSprite spriteWithFile:@"1.png"];
        spr.position = ccp(xPos, yPos);
        [self addChild:spr];
        spr.tag = nTouchId;
        [m_redSpriteArray addObject:spr];
        m_isRed = NO;
        NSString* str = [NSString stringWithFormat:@"BlueTeam"];
        lblWhichTeam.string = str;
    }
    else
    {
        spr = [CCSprite spriteWithFile:@"2.png"];
        spr.position = ccp(xPos, yPos);
        [self addChild:spr];
        spr.tag = nTouchId;
        [m_blueSpriteArray addObject:spr];
        m_isRed = YES;
        NSString* str = [NSString stringWithFormat:@"RedTeam"];
        lblWhichTeam.string = str;
    }
    
    BOOL selfTurnInOtherPolygon = [self selfSuicideInPolygon:nTouchId];
    if (selfTurnInOtherPolygon == YES) {
        [self updateScoreLabel];
        CCSprite* sprite = (CCSprite*)[self getChildByTag:nTouchId];
        if (m_isRed == YES) {
            [m_blueSpriteArray removeObject:sprite];
        }
        else
            [m_redSpriteArray removeObject:sprite];
        return;
    }
    
    if (m_NormalIPhone == YES) {
        spr.scale = 0.5;
    }

    NSString* strNumber = [NSString stringWithFormat:@"%d", m_touchCount];
    
    CCLabelTTF* lblNumber = [CCLabelTTF labelWithString:strNumber fontName:@"Thonburi" fontSize:15];
    lblNumber.position = ccp(xPos, yPos);
    lblNumber.scale = 0.6;
    [self addChild:lblNumber];
    
    if ([self calcConnectionCount:nTouchId] == 1) {
        return;
    }
    
    if ([self isTriangleShape:nTouchId] == YES) {
        return;
    }
    m_checkCount = 0;
   
    [self searchPath:nTouchId];
    
    int resultPoint[70];
    int nResultCount = 0;
    if (m_CntUseStack != 0) {
        
        for (int i = 0; i < m_CntUseStack; i++) {
            resultPoint[i] = m_ArrayUseStack[i];
            nResultCount = i + 1;
        }
        BOOL foundStackNumber = NO;
        for (int i = 0; i < m_checkCount; i++) {
            if (m_checkPoints[i] != m_lastStackSearch && foundStackNumber == NO) {
                continue;
            }
            else
            {
                resultPoint[nResultCount] = m_checkPoints[i];
                nResultCount ++;
                foundStackNumber = YES;
            }
        }
        for (int i = 0; i < nResultCount; i++) {
            m_checkPoints[i] = resultPoint[i];
        }
        m_checkCount = nResultCount;
    }
    if (m_CntUseStack == 0) {
        //add other code
    }
    if(m_checkCount < 3)
        return;
    firstCount = 0;
    firstCount = [self removeDisConnectPointCount:m_checkCount numberArray:m_checkPoints];
    
    BOOL notConnect = NO;
    for (int i = 0; i < firstCount - 1; i++) {
        if ([self checkAdjancyPoint:m_checkPoints[i] LastPoint:m_checkPoints[i + 1]] == NO) {
            notConnect = YES;
            break;
        }
    }
    
    int nLastIndex = firstCount - 1;
    BOOL haveOnePolygon = NO;
    int onePolygonCount = -1;
    for (int i = 2; i < firstCount; i++) {
        if ([self checkAdjancyPoint:nTouchId LastPoint:m_checkPoints[i]] == YES) {
            if (i < 4) {
                continue;
            }
            else
            {
                haveOnePolygon = YES;
                onePolygonCount = i;
                nLastIndex = i;
                break;
            }
        }
    }
    
    BOOL makePolygon = NO;
    
    
    if ([self checkAdjancyPoint:nTouchId LastPoint:m_checkPoints[nLastIndex]] == YES && firstCount > 2 && (notConnect == NO || haveOnePolygon == YES)) {
        
        int polygonCount;
        if (haveOnePolygon == YES) {
            polygonCount = onePolygonCount + 1;
            if (m_isRed == NO) {
                m_rPolygonLineCount[m_redPolygonCount] = polygonCount;
            }
            else
                m_bPolygonLineCount[m_bluePolygonCount] = polygonCount;
        }
        if (notConnect == NO && haveOnePolygon == NO) {
            polygonCount = firstCount;
            if (m_isRed == NO) {
                m_rPolygonLineCount[m_redPolygonCount] = firstCount;
            }
            else
                m_bPolygonLineCount[m_bluePolygonCount] = firstCount;
        }
        
        
        for (int i = 0; i < polygonCount; i ++) {
            if (m_isRed == NO) {
                m_redDrawPoints[m_redPolygonCount][i] = m_checkPoints[i];
            }
            else
                m_blueDrawPoints[m_bluePolygonCount][i] = m_checkPoints[i];
        }
        
        for (int i = 0; i < polygonCount; i++) {
            m_ArrayFirst[i] = m_checkPoints[i];
        }
        for (int i = 0; i < polygonCount - 1; i++) {
            if ([self checkAdjancyPoint:m_ArrayFirst[i] LastPoint:m_ArrayFirst[i + 1]] == NO) {
                NSLog(@"firstPoint = %d, secondPoint = %d", m_ArrayFirst[i], m_ArrayFirst[i + 1]);
                [m_remainArray removeAllObjects];
                [self checkFirstSquarePolygon:nTouchId];
                [self checkSecondSquarePolygon:nTouchId];
                [self checkThirdSquare:nTouchId];
                [self checkFourthSquare:nTouchId];
                
                return;
            }
        }
        if ([self checkAdjancyPoint:nTouchId LastPoint:m_ArrayFirst[polygonCount - 1]] == NO) {
            return;
        }
        if (polygonCount < 4) {
            return;
        }

        if (m_isRed == NO) {
            m_redPolygonCount ++;
        }
        else
            m_bluePolygonCount ++;
        
        makePolygon = YES;
        m_CntFirst = polygonCount;
        
        
        int count = 0;
        remainPoints[0] = nTouchId;
        count ++;
        for (int i = 1; i < firstCount; i++) {
            int nId = m_checkPoints[i];
            if ([self checkAdjancyPoint:nTouchId LastPoint:nId] == YES && [self isInFirstConnection:nId] == YES) {
                remainPoints[count] = nId;
                count ++;
            }
            else if ([self calcConnectionCount:nId] > 2 && [self isInFirstConnection:nId] == YES) {
                remainPoints[count] = nId;
                count++;
            }
        }
        
        if (m_isRed == NO) {
            for (int i = 0; i < [m_redSpriteArray count]; i++) {
                CCSprite* sprite = (CCSprite*)[m_redSpriteArray objectAtIndex:i];
                m_checkPoints[i] = sprite.tag;
            }
            firstCount = [m_redSpriteArray count];
        }
        else
        {
            for (int i = 0; i < [m_blueSpriteArray count]; i++) {
                CCSprite* sprite = (CCSprite*)[m_blueSpriteArray objectAtIndex:i];
                m_checkPoints[i] = sprite.tag;
            }
            firstCount = [m_blueSpriteArray count];
        }
        if (m_isRed == NO) {
            int delPoint[30];
            int nDelCount = 0;
            
            for (int i = 0; i < [m_blueSpriteArray count]; i++) {
                CCSprite* sprite = (CCSprite*)[m_blueSpriteArray objectAtIndex:i];
                int nId = sprite.tag;
                BOOL pointInPolygon;
                pointInPolygon = [self checkPointInPolygon:nId];
                if (pointInPolygon == YES)
                {
                    m_scoreRed ++;
                    delPoint[nDelCount] = nId;
                    nDelCount ++;
                }
            }
            for (int i = 0; i < nDelCount; i++) {
                int nId = delPoint[i];
                CCSprite* sprite = (CCSprite*)[self getChildByTag:nId];
                [m_blueSpriteArray removeObject:sprite];
            }
        }
        else
        {
            int delPoint[30];
            int nDelCount = 0;
            
            for (int i = 0; i < [m_redSpriteArray count]; i++) {
                CCSprite* sprite = (CCSprite*)[m_redSpriteArray objectAtIndex:i];
                int nId = sprite.tag;
                BOOL pointInPolygon;
                pointInPolygon = [self checkPointInPolygon:nId];
                if (pointInPolygon == YES) {
                    m_scoreBlue ++;
                    delPoint[nDelCount] = nId;
                    nDelCount ++;
                }
            }
            for (int i = 0; i < nDelCount; i++) {
                int nId = delPoint[i];
                CCSprite* sprite = (CCSprite*)[self getChildByTag:nId];
                [m_redSpriteArray removeObject:sprite];
            }
        }
        [self updateScoreLabel];
        
        for (int i = 0; i < firstCount; i++){
            int nId = m_checkPoints[i];
            if ([self isInFirstConnection:nId] == NO) {
                remainPoints[count] = nId;
                count ++;
            }
        }
        
        
        for (int j = 0; j < count; j++) {
            CCSprite* spr = (CCSprite*)[self getChildByTag:remainPoints[j]];
            [m_remainArray addObject:spr];
        }
        if (count < 4) {
            return;
        }
        
        
        m_UseStackFound = NO;
        m_CntFirst = -1;
        m_CntSecond = -1;
        m_CntStack = 0;
        m_branchCount = 0;
        
        m_lastStackSearch = -1;
        m_CntUseStack = 0;
        m_checkCount = 0;
        
        for (int i = 0; i < 100; i ++ ) {
            m_checkPoints[i] = -1;
        }
        NSLog(@"%d", remainPoints[0]);
        [self searchPath:nTouchId];
        
        firstCount = 0;
        firstCount = [self removeDisConnectPointCount:m_checkCount numberArray:m_checkPoints];
        
        BOOL notConnect = NO;
        for (int i = 0; i < firstCount - 1; i++) {
            if ([self checkAdjancyPoint:m_checkPoints[i] LastPoint:m_checkPoints[i + 1]] == NO) {
                notConnect = YES;
                break;
            }
        }
        
        if ([self checkAdjancyPoint:nTouchId LastPoint:m_checkPoints[firstCount - 1]] == YES && firstCount > 2 && notConnect == NO )
        {
            m_CntSecond = firstCount;
            for (int i = 0; i < firstCount; i ++) {
                if (m_isRed == NO) {
                    m_redDrawPoints[m_redPolygonCount][i] = m_checkPoints[i];
                }
                else
                {
                    m_blueDrawPoints[m_bluePolygonCount][i] = m_checkPoints[i];
                }
            }
            if (m_isRed == NO) {
                m_rPolygonLineCount[m_redPolygonCount] = firstCount;
                m_redPolygonCount ++;
            }
            else
            {
                m_bPolygonLineCount[m_bluePolygonCount] = firstCount;
                m_bluePolygonCount ++;
            }
        }
    }
    
    if (makePolygon == NO) {
        [m_remainArray removeAllObjects];
        [self checkFirstSquarePolygon:nTouchId];
        [self checkSecondSquarePolygon:nTouchId];
        [self checkThirdSquare:nTouchId];
        [self checkFourthSquare:nTouchId];
    }
    if (m_SquareFour == NO) {
        NSMutableArray* remainArray = [[NSMutableArray alloc] initWithCapacity:0];
        if (m_isRed == NO) {
            for (int i = 0; i < [m_redSpriteArray count]; i++) {
                CCSprite* sprite = [m_redSpriteArray objectAtIndex:i];
                if ([self isInPointAnyPolygon:sprite.tag] == NO) {
                    [remainArray addObject:sprite];
                }
            }
        }
        else
        {
            for (int i = 0; i < [m_blueSpriteArray count]; i++) {
                CCSprite* sprite = [m_blueSpriteArray objectAtIndex:i];
                if ([self isInPointAnyPolygon:sprite.tag] == NO) {
                    [remainArray addObject:sprite];
                }
            }
        }
        for (int i = 0; i < [remainArray count]; i++) {
            CCSprite* sprite = [remainArray objectAtIndex:i];
            
            NSLog(@"These point can compose polygon  %d", (int)sprite.tag);
        }
    }
    
    int nSamePoint[10];
    for (int i = 0; i < 10; i++) {
        nSamePoint[i] = -1;
    }
}

- (BOOL) isInPointAnyPolygon:(int) nPos
{
    if (m_isRed == NO) {
        for (int i = 0; i < m_redPolygonCount; i++) {
            for (int j = 0; j < m_rPolygonLineCount[i]; j++) {
                if (m_redDrawPoints[i][j] == nPos) {
                    return YES;
                }
            }
        }
    }
    else
    {
        for (int i = 0; i < m_bluePolygonCount; i++) {
            for (int j = 0; j < m_bPolygonLineCount[i]; j++) {
                if (m_blueDrawPoints[i][j] == nPos) {
                    return YES;
                }
            }
        }
    }
    return NO;
}

- (void) checkFirstSquarePolygon:(int) nIdOne
{
    int nRow, nCol;
    nRow = nIdOne / COL; // Position Y
    nCol = nIdOne % COL; // Position X
    int nIdTwo = - 1;
    int nIdThree = -1;
    int nIdFour = -1;
    
    if (nCol - 1 > - 1 && nRow + 1 < ROW) {
        nIdTwo = (nRow + 1) * COL + nCol - 1;
    }
    else
        return;
    if (nRow + 2 < ROW ) {
        nIdThree = (nRow + 2) * COL + nCol;
    }
    else
        return;
    
    if (nCol + 1 < COL && nRow + 1 < ROW) {
        nIdFour = (nRow + 1) * COL + nCol + 1;
    }
    else
        return  ;
    
    
    if ([self checkSprite:nIdTwo] == YES && [self checkSprite:nIdThree] == YES && [self checkSprite:nIdFour] == YES) {
        if (m_isRed == NO) {
            m_redDrawPoints[m_redPolygonCount][0] = nIdOne;
            m_redDrawPoints[m_redPolygonCount][1] = nIdTwo;
            m_redDrawPoints[m_redPolygonCount][2] = nIdThree;
            m_redDrawPoints[m_redPolygonCount][3] = nIdFour;
            m_rPolygonLineCount[m_redPolygonCount] = 4;
            m_redPolygonCount ++;
            m_SquareFour = YES;
        }
        else
        {
            m_blueDrawPoints[m_bluePolygonCount][0] = nIdOne;
            m_blueDrawPoints[m_bluePolygonCount][1] = nIdTwo;
            m_blueDrawPoints[m_bluePolygonCount][2] = nIdThree;
            m_blueDrawPoints[m_bluePolygonCount][3] = nIdFour;
            m_bPolygonLineCount[m_bluePolygonCount] = 4;
            m_bluePolygonCount ++;
            m_SquareFour = YES;
        }
    }
    
}



- (void) checkSecondSquarePolygon:(int) nIdOne
{
    int nRow, nCol;
    nRow = nIdOne / COL; // Position Y
    nCol = nIdOne % COL; // Position X
    int nIdTwo = - 1;
    int nIdThree = -1;
    int nIdFour = -1;
    
    if (nCol - 1 > - 1 && nRow - 1 > - 1) {
        nIdTwo = (nRow - 1) * COL + nCol - 1;
    }
    else
        return;
    if (nCol - 2 > - 1) {
        nIdThree = nRow * COL + nCol - 2;
    }
    else
        return;
    if (nCol - 1 > - 1 && nRow + 1 < ROW) {
        nIdFour = (nRow + 1) * COL + nCol - 1;
    }
    else
        return;
    
    if ([self checkSprite:nIdTwo] == YES && [self checkSprite:nIdThree] == YES && [self checkSprite:nIdFour] == YES) {
        if (m_isRed == NO) {
            m_redDrawPoints[m_redPolygonCount][0] = nIdOne;
            m_redDrawPoints[m_redPolygonCount][1] = nIdTwo;
            m_redDrawPoints[m_redPolygonCount][2] = nIdThree;
            m_redDrawPoints[m_redPolygonCount][3] = nIdFour;
            m_rPolygonLineCount[m_redPolygonCount] = 4;
            m_redPolygonCount ++;
            m_SquareFour = YES;
        }
        else
        {
            m_blueDrawPoints[m_bluePolygonCount][0] = nIdOne;
            m_blueDrawPoints[m_bluePolygonCount][1] = nIdTwo;
            m_blueDrawPoints[m_bluePolygonCount][2] = nIdThree;
            m_blueDrawPoints[m_bluePolygonCount][3] = nIdFour;
            m_bPolygonLineCount[m_bluePolygonCount] = 4;
            m_bluePolygonCount ++;
            m_SquareFour = YES;
        }
    }
}

- (void) checkThirdSquare:(int) nIdOne
{
    int nRow, nCol;
    nRow = nIdOne / COL; // Position Y
    nCol = nIdOne % COL; // Position X
    int nIdTwo = - 1;
    int nIdThree = -1;
    int nIdFour = -1;
    
    if (nCol - 1 > - 1 && nRow - 1 > - 1) {
        nIdTwo = (nRow - 1) * COL + nCol - 1;
    }
    else
        return;
    if (nRow - 2 > - 1) {
        nIdThree = (nRow - 2) * COL + nCol;
    }
    else
        return;
    if (nCol + 1 < COL && nRow - 1 > - 1) {
        nIdFour = (nRow - 1) * COL + nCol + 1;
    }
    else
        return;

    if ([self checkSprite:nIdTwo] == YES && [self checkSprite:nIdThree] == YES && [self checkSprite:nIdFour] == YES) {
        if (m_isRed == NO) {
            m_redDrawPoints[m_redPolygonCount][0] = nIdOne;
            m_redDrawPoints[m_redPolygonCount][1] = nIdTwo;
            m_redDrawPoints[m_redPolygonCount][2] = nIdThree;
            m_redDrawPoints[m_redPolygonCount][3] = nIdFour;
            m_rPolygonLineCount[m_redPolygonCount] = 4;
            m_redPolygonCount ++;
            m_SquareFour = YES;
        }
        else
        {
            m_blueDrawPoints[m_bluePolygonCount][0] = nIdOne;
            m_blueDrawPoints[m_bluePolygonCount][1] = nIdTwo;
            m_blueDrawPoints[m_bluePolygonCount][2] = nIdThree;
            m_blueDrawPoints[m_bluePolygonCount][3] = nIdFour;
            m_bPolygonLineCount[m_bluePolygonCount] = 4;
            m_bluePolygonCount ++;
            m_SquareFour = YES;
        }
    }
}



- (void) checkFourthSquare:(int) nIdOne
{
    int nRow, nCol;
    nRow = nIdOne / COL; // Position Y
    nCol = nIdOne % COL; // Position X
    int nIdTwo = - 1;
    int nIdThree = -1;
    int nIdFour = -1;
    
    if (nCol + 1 < COL && nRow + 1 < ROW) {
        nIdTwo = (nRow + 1) * COL + nCol + 1;
    }
    else
        return;
    
    if (nCol + 2 < COL) {
        nIdThree = nRow * COL + nCol + 2;
    }
    else
        return;
    
    if (nCol + 1 < COL && nRow - 1 > - 1) {
        nIdFour = (nRow - 1) * COL + nCol + 1;
    }
    else
        return;

    if ([self checkSprite:nIdTwo] == YES && [self checkSprite:nIdThree] == YES && [self checkSprite:nIdFour] == YES) {
        if (m_isRed == NO) {
            m_redDrawPoints[m_redPolygonCount][0] = nIdOne;
            m_redDrawPoints[m_redPolygonCount][1] = nIdTwo;
            m_redDrawPoints[m_redPolygonCount][2] = nIdThree;
            m_redDrawPoints[m_redPolygonCount][3] = nIdFour;
            m_rPolygonLineCount[m_redPolygonCount] = 4;
            m_redPolygonCount ++;
            m_SquareFour = YES;
        }
        else
        {
            m_blueDrawPoints[m_bluePolygonCount][0] = nIdOne;
            m_blueDrawPoints[m_bluePolygonCount][1] = nIdTwo;
            m_blueDrawPoints[m_bluePolygonCount][2] = nIdThree;
            m_blueDrawPoints[m_bluePolygonCount][3] = nIdFour;
            m_bPolygonLineCount[m_bluePolygonCount] = 4;
            m_bluePolygonCount ++;
            m_SquareFour = YES;
        }
    }
}

- (int) removeDisConnectPointCount:(int) nCount numberArray:(int*) array
{
    int CntDel = 0;
    int CntReturn = 0;
    int arrayDel[20];
    int arrayReturn[70];
    for (int i = 0; i < nCount; i++) {
        int nId = array[i];
        if ([self calcConnectionCount:nId] < 2) {
            arrayDel[CntDel] = nId;
            CntDel ++;
        }
        else
        {
            arrayReturn[CntReturn] = nId;
            CntReturn ++;
        }
    }
    
    int arrayLastReturn[20];
    int CntLastReturn = 0;
    
    int arrayLastDel[20];
    int CntLastDel = 0;
    for (int i = 0; i < CntDel; i++) {
        int nId = arrayDel[i];
        int nConnectId;
        int nRow, nCol;
        nRow = nId / COL;
        nCol = nId % COL;
        if (nCol - 1 > - 1 && nRow + 1 < ROW) { // Condition 1
            nConnectId = (nRow + 1) * COL + nCol - 1;
            for (int j = 0; j < CntReturn; j++) {
                if (nConnectId == arrayReturn[j]) {
                    if ([self calcConnectionCount:nConnectId] == 2) {
                        arrayLastDel[CntLastDel] = nConnectId;
                        CntLastDel ++;
                    }
                }
            }
        }
        if (nCol - 1 > - 1) {                   //condition 2
            nConnectId = nRow * COL + nCol - 1;
            for (int j = 0; j < CntReturn; j++) {
                if (nConnectId == arrayReturn[j]) {
                    if ([self calcConnectionCount:nConnectId] == 2) {
                        arrayLastDel[CntLastDel] = nConnectId;
                        CntLastDel ++;
                    }
                }
            }
        }
        if (nCol - 1 > - 1 && nRow - 1 > -1) {  //Condition3
            nConnectId = (nRow - 1) * COL + nCol - 1;
            for (int j = 0; j < CntReturn; j++) {
                if (nConnectId == arrayReturn[j]) {
                    if ([self calcConnectionCount:nConnectId] == 2) {
                        arrayLastDel[CntLastDel] = nConnectId;
                        CntLastDel ++;
                    }
                }
            }
        }
        if (nRow - 1 > - 1) {                   //Condition4
            nConnectId = (nRow - 1) * COL + nCol;
            for (int j = 0; j < CntReturn; j++) {
                if (nConnectId == arrayReturn[j]) {
                    if ([self calcConnectionCount:nConnectId] == 2) {
                        arrayLastDel[CntLastDel] = nConnectId;
                        CntLastDel ++;
                    }
                }
            }
        }
        if (nCol + 1 < COL && nRow - 1 > -1) {  //Condition5
            nConnectId = (nRow - 1) * COL + nCol + 1;
            for (int j = 0; j < CntReturn; j++) {
                if (nConnectId == arrayReturn[j]) {
                    if ([self calcConnectionCount:nConnectId] == 2) {
                        arrayLastDel[CntLastDel] = nConnectId;
                        CntLastDel ++;
                    }
                }
            }
        }
        if (nCol + 1 < COL) {                   //Condition6
            nConnectId = nRow * COL + nCol + 1;
            for (int j = 0; j < CntReturn; j++) {
                if (nConnectId == arrayReturn[j]) {
                    if ([self calcConnectionCount:nConnectId] == 2) {
                        arrayLastDel[CntLastDel] = nConnectId;
                        CntLastDel ++;
                    }
                }
            }
        }
        if (nCol + 1 < COL && nRow + 1 < ROW) { //Condition7
            nConnectId = (nRow + 1) * COL + nCol + 1;
            for (int j = 0; j < CntReturn; j++) {
                if (nConnectId == arrayReturn[j]) {
                    if ([self calcConnectionCount:nConnectId] == 2) {
                        arrayLastDel[CntLastDel] = nConnectId;
                        CntLastDel ++;
                    }
                }
            }
        }
        if (nRow + 1 < ROW) {                   //Condition8
            nConnectId = (nRow + 1) * COL + nCol;
            for (int j = 0; j < CntReturn; j++) {
                if (nConnectId == arrayReturn[j]) {
                    if ([self calcConnectionCount:nConnectId] == 2) {
                        arrayLastDel[CntLastDel] = nConnectId;
                        CntLastDel ++;
                    }
                }
            }
        }
    }
    
    for (int i = 0; i < CntReturn; i++) {
        int nId = arrayReturn[i];
        BOOL delData = NO;
        for (int j = 0; j < CntLastDel; j++) {
            if (nId == arrayLastDel[j]) {
                delData = YES;
                break;
            }
        }
        if (delData == NO) {
            arrayLastReturn[CntLastReturn] = nId;
            CntLastReturn ++;
        }
    }
    
    for (int i = 0; i < CntLastReturn; i++) {
        array[i] = arrayLastReturn[i];
    }
    return CntLastReturn;
}


- (void) checkPoints
{
    if (m_isRed == NO) {
        int delPoint[30];
        int nDelCount = 0;
        
        for (int i = 0; i < [m_blueSpriteArray count]; i++) {
            CCSprite* sprite = (CCSprite*)[m_blueSpriteArray objectAtIndex:i];
            int nId = sprite.tag;
            BOOL pointInPolygon;
            pointInPolygon = [self checkPointInPolygon:nId];
            if (pointInPolygon == YES)
            {
                m_scoreRed ++;
                delPoint[nDelCount] = nId;
                nDelCount ++;
            }
        }
        for (int i = 0; i < nDelCount; i++) {
            int nId = delPoint[i];
            CCSprite* sprite = (CCSprite*)[self getChildByTag:nId];
            [m_blueSpriteArray removeObject:sprite];
        }
    }
    else
    {
        int delPoint[30];
        int nDelCount = 0;
        
        for (int i = 0; i < [m_redSpriteArray count]; i++) {
            CCSprite* sprite = (CCSprite*)[m_redSpriteArray objectAtIndex:i];
            int nId = sprite.tag;
            BOOL pointInPolygon;
            pointInPolygon = [self checkPointInPolygon:nId];
            if (pointInPolygon == YES) {
                m_scoreBlue ++;
                delPoint[nDelCount] = nId;
                nDelCount ++;
            }
        }
        for (int i = 0; i < nDelCount; i++) {
            int nId = delPoint[i];
            CCSprite* sprite = (CCSprite*)[self getChildByTag:nId];
            [m_redSpriteArray removeObject:sprite];
        }
    }
    [self updateScoreLabel];

}

- (BOOL) selfSuicideInPolygon:(int) nId
{
    BOOL returnValue = NO;
    if (m_isRed == YES) {
        for (int i = 0; i < m_redPolygonCount; i++) {
            int vertex[50];
            
            for (int nCount = 0; nCount < m_rPolygonLineCount[i]; nCount++) {
                vertex[nCount] = m_redDrawPoints[i][nCount];
            }
            
            for (int nCount = 0; nCount < m_rPolygonLineCount[i] ; nCount ++) {
                returnValue = [self pointInPolygonCount:m_rPolygonLineCount[i] posArray:vertex testPoint:nId];
                if (returnValue == YES) {
                    m_drawRedPolygon[i] = YES;
                    m_scoreRed ++;
                    return YES;
                }
            }
        }
    }
    else
    {
        for (int i = 0; i < m_bluePolygonCount; i++) {
            int vertex[50];
            
            for (int nCount = 0; nCount < m_bPolygonLineCount[i]; nCount++) {
                vertex[nCount] = m_blueDrawPoints[i][nCount];
            }
            
            for (int nCount = 0; nCount < m_bPolygonLineCount[i]; nCount ++) {
                returnValue = [self pointInPolygonCount:m_bPolygonLineCount[i] posArray:vertex testPoint:nId];
                if (returnValue == YES) {
                    m_drawBluePolygon[i] = YES;
                    m_scoreBlue ++;
                    return YES;
                }
            }
        }
    }
    
    return NO;
}

- (BOOL) checkPointInPolygon:(int) nId
{
    BOOL returnValue = NO;
    if (m_isRed == NO) {
        for (int i = 0; i < m_redPolygonCount; i++) {
            int vertex[50];
            
            for (int nCount = 0; nCount < m_rPolygonLineCount[i]; nCount++) {
                vertex[nCount] = m_redDrawPoints[i][nCount];
            }
            
            for (int nCount = 0; nCount < m_rPolygonLineCount[i] ; nCount ++) {
                returnValue = [self pointInPolygonCount:m_rPolygonLineCount[i] posArray:vertex testPoint:nId];
                if (returnValue == YES) {
                    m_drawRedPolygon[i] = YES;
                    return YES;
                }
            }
        }
    }
    else
    {
        for (int i = 0; i < m_bluePolygonCount; i++) {
            int vertex[50];
            
            for (int nCount = 0; nCount < m_bPolygonLineCount[i]; nCount++) {
                vertex[nCount] = m_blueDrawPoints[i][nCount];
            }
            
            for (int nCount = 0; nCount < m_bPolygonLineCount[i]; nCount ++) {
                returnValue = [self pointInPolygonCount:m_bPolygonLineCount[i] posArray:vertex testPoint:nId];
                if (returnValue == YES) {
                    m_drawBluePolygon[i] = YES;
                    return YES;
                }
            }
        }
    }
    
    return NO;
    
}

- (void) drawLineWithFirstPoint:(int) nFirst  SeconPoint:(int) nSecond   LineColor:(BOOL) currentColor
{
    // draw one segment of polygon with two points
    int xFirst = nFirst % COL;
    int yFirst = nFirst / COL;
    
    int xSecond = nSecond % COL;
    int ySecond = nSecond / COL;
    
    ccGLEnable(GL_LINES);
    CGPoint firstPoint = ccp(XSTART + XSEGMENT * xFirst, YSTART + YSEGMENT * yFirst);
    CGPoint secondPoint = ccp(XSTART + XSEGMENT * xSecond, YSTART + YSEGMENT * ySecond );
    glLineWidth(5.0f);
    if (currentColor == YES)
        ccDrawColor4B(255, 0, 0, 255);  // draw Red Line
    else
        ccDrawColor4B(0, 0, 255, 255);  // draw Blue Line
    ccDrawLine(firstPoint, secondPoint);
}

- (BOOL) isTriangleShape:(int) nTouchPoint
{
    int nRow, nCol;
    nRow = nTouchPoint / COL;
    nCol = nTouchPoint % COL;
    
    int nId;
    int m_ConnectionCount = 0;
    int arrayConnect[8];
    if (nCol - 1 > -1 && nRow + 1 < ROW) {// condition1
        nId = (nRow + 1) * COL + nCol - 1;
        if ([self checkSprite:nId] == YES) {
            arrayConnect[m_ConnectionCount] = nId;
            m_ConnectionCount ++;
        }
    }
    if (nCol - 1 > - 1) { // conditin2
        nId = nRow * COL + nCol - 1;
        if ([self checkSprite:nId] == YES) {
            arrayConnect[m_ConnectionCount] = nId;
            m_ConnectionCount ++;
        }
    }
    if (nCol - 1 > - 1 && nRow - 1 > -1) { // condition3
        nId = (nRow - 1) * COL + nCol - 1;
        if ([self checkSprite:nId] == YES){
            arrayConnect[m_ConnectionCount] = nId;
            m_ConnectionCount ++;
        }
    }
    if (nRow - 1 > - 1) {  //condition4
        nId = (nRow - 1) * COL + nCol;
        if ([self checkSprite:nId] == YES) {
            arrayConnect[m_ConnectionCount] = nId;
            m_ConnectionCount ++;
        }
    }
    if (nCol + 1 < COL && nRow - 1 > -1) { // condition5
        nId = (nRow - 1) * COL + nCol + 1;
        if ([self checkSprite:nId] == YES) {
            arrayConnect[m_ConnectionCount] = nId;
            m_ConnectionCount ++;
        }
    }
    if (nCol + 1 < COL) { // condition6
        nId = nRow * COL + nCol + 1;
        if ([self checkSprite:nId] == YES) {
            arrayConnect[m_ConnectionCount] = nId;
            m_ConnectionCount ++;
        }
    }
    if (nCol + 1 < COL && nRow + 1 < ROW) { // condition7
        nId = (nRow + 1) * COL + nCol + 1;
        if ([self checkSprite:nId] == YES) {
            arrayConnect[m_ConnectionCount] = nId;
            m_ConnectionCount ++;
        }
    }
    if (nRow + 1 < ROW) {  // condition8
        nId = (nRow + 1) * COL + nCol;
        if ([self checkSprite:nId] == YES) {
            arrayConnect[m_ConnectionCount] = nId;
            m_ConnectionCount ++;
        }
    }
    if (m_ConnectionCount == 2) {
        if ([self checkAdjancyPoint:arrayConnect[0] LastPoint:arrayConnect[1]] == YES) {
            return YES;
        }
    }
    return NO;
}


- (BOOL) isInFirstConnection:(int) nId
{
    for (int i = 0; i < firstCount + 1; i++) {
        if (nId == resultPoints[i]) {
            return YES;
        }
    }
    return NO;
}
- (int) calcConnectionCount:(int) i
{
    int nRow, nCol;
    nRow = i / COL;
    nCol = i % COL;
    
    int nId;
    int m_ConnectionCount = 0;
    if (nCol - 1 > -1 && nRow + 1 < ROW) {// condition1
        nId = (nRow + 1) * COL + nCol - 1;
        if ([self checkSprite:nId] == YES) {
            m_ConnectionCount ++;
        }
    }
    if (nCol - 1 > - 1) { // conditin2
        nId = nRow * COL + nCol - 1;
        if ([self checkSprite:nId] == YES) {
            m_ConnectionCount ++;
        }
    }
    if (nCol - 1 > - 1 && nRow - 1 > -1) { // condition3
        nId = (nRow - 1) * COL + nCol - 1;
        if ([self checkSprite:nId] == YES) {
            m_ConnectionCount ++;
        }
    }
    if (nRow - 1 > - 1) {  //condition4
        nId = (nRow - 1) * COL + nCol;
        if ([self checkSprite:nId] == YES) {
            m_ConnectionCount ++;
        }
    }
    if (nCol + 1 < COL && nRow - 1 > -1) { // condition5
        nId = (nRow - 1) * COL + nCol + 1;
        if ([self checkSprite:nId] == YES) {
            m_ConnectionCount ++;
        }
    }
    if (nCol + 1 < COL) { // condition6
        nId = nRow * COL + nCol + 1;
        if ([self checkSprite:nId] == YES) {
            m_ConnectionCount ++;
        }
    }
    if (nCol + 1 < COL && nRow + 1 < ROW) { // condition7
        nId = (nRow + 1) * COL + nCol + 1;
        if ([self checkSprite:nId] == YES) {
            m_ConnectionCount ++;
        }
    }
    if (nRow + 1 < ROW) {  // condition8
        nId = (nRow + 1) * COL + nCol;
        if ([self checkSprite:nId] == YES) {
            m_ConnectionCount ++;
        }
    }
    return m_ConnectionCount;

}
- (BOOL) checkSprite:(int) sprId    //Is there a connection point in m_redSpriteArray
{
    BOOL returnValue = NO;      //there is not this sprite
    
    if (m_isRed == NO) {
        if ([m_remainArray count] == 0) {
            for (int i = 0; i < [m_redSpriteArray count]; i++) {
                CCSprite* sprite = [m_redSpriteArray objectAtIndex:i];
                int tag = sprite.tag;
                if (sprId == tag) {
                    returnValue = YES;
                    break;
                }
            }
        }
        else
        {
            for (int i = 0; i < [m_remainArray count]; i++) {
                CCSprite* sprite = [m_remainArray objectAtIndex:i];
                int tag = sprite.tag;
                if (sprId == tag) {
                    returnValue = YES;
                    break;
                }
            }
        }
    }
    else
    {
        if ([m_remainArray count] == 0) {
            for (int i = 0; i < [m_blueSpriteArray count]; i++) {
                CCSprite* sprite = [m_blueSpriteArray objectAtIndex:i];
                int tag = sprite.tag;
                if (sprId == tag) {
                    returnValue = YES;
                    break;
                }
            }
        }
        else
        {
            for (int i = 0; i < [m_remainArray count]; i++) {
                CCSprite* sprite = [m_remainArray objectAtIndex:i];
                int tag = sprite.tag;
                if (sprId == tag) {
                    returnValue = YES;
                    break;
                }
            }
        }
    }
    return returnValue;
}

- (BOOL) searchPoint:(int) nId
{
    BOOL isCheck = NO;
    for(int i = 0; i < m_checkCount; i++)
    {
        if (nId == m_checkPoints[i]) {
            isCheck = YES;
            break;
        }
    }
    
    return isCheck;
}

- (BOOL) compareIsinStack:(int)nId
{
    for (int i = 0; i < m_CntStack; i++) {
        if (nId == m_arrayCheckStack[i]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL) allPointConnect:(int) nCount PointArray:(int*) array
{
    for (int i = 0; i < nCount; i++) {
        if ([self calcConnectionCount:array[i] == 1]) {
            return NO;
        }
    }
    return YES;
}

- (void) searchPath:(int) nSearchPos
{
    int nRow, nCol;
    nRow = nSearchPos / COL;
    nCol = nSearchPos % COL;
    NSLog(@"%d", m_CntStack);
    m_checkPoints[m_checkCount] = nSearchPos;
    m_checkCount ++;
    
    if ([self checkAdjancyPoint:nSearchPos LastPoint:nTouchId] == YES && m_checkCount > 2) {
        if ([self calcConnectionCount:nSearchPos] < 4) {
            m_UseStackFound = YES;
            return;
        }
    }
    if ([self compareIsinStack:nSearchPos] == YES && m_checkCount > 4 && [self checkAdjancyPoint:nSearchPos LastPoint:nTouchId] == YES && ([self haveOldPolygon:m_checkCount pathArray:m_checkPoints] == NO || [self allPointConnect:m_checkCount PointArray:m_checkPoints] == YES)) {
        if ([self calcConnectionCount:nSearchPos] < 4) {
            m_UseStackFound = YES;
            return;
        }
    }
    
    int nId;
    int m_ConnectionCount = 0;
    int m_PointsConnected[8];
    if (nCol - 1 > -1 && nRow + 1 < ROW) {// condition1
        nId = (nRow + 1) * COL + nCol - 1;
        if ([self checkSprite:nId] == YES && [self searchPoint:nId] == NO && ([self compareIsinStack:nId] == NO || [self checkAdjancyPoint:nTouchId LastPoint:nId] == YES)) {
            m_PointsConnected[m_ConnectionCount] = nId;
            m_ConnectionCount ++;
        }
    }
    if (nCol - 1 > - 1) { // conditin2
        nId = nRow * COL + nCol - 1;
        if ([self checkSprite:nId] == YES && [self searchPoint:nId] == NO && ([self compareIsinStack:nId] == NO || [self checkAdjancyPoint:nTouchId LastPoint:nId] == YES)) {
            m_PointsConnected[m_ConnectionCount] = nId;
            m_ConnectionCount ++;
        }
    }
    if (nCol - 1 > - 1 && nRow - 1 > -1) { // condition3
        nId = (nRow - 1) * COL + nCol - 1;
        if ([self checkSprite:nId] == YES && [self searchPoint:nId] == NO && ([self compareIsinStack:nId] == NO || [self checkAdjancyPoint:nTouchId LastPoint:nId] == YES)) {
            m_PointsConnected[m_ConnectionCount] = nId;
            m_ConnectionCount ++;
        }
    }
    if (nRow - 1 > - 1) {  //condition4
        nId = (nRow - 1) * COL + nCol;
        if ([self checkSprite:nId] == YES && [self searchPoint:nId] == NO && ([self compareIsinStack:nId] == NO || [self checkAdjancyPoint:nTouchId LastPoint:nId] == YES)) {
            m_PointsConnected[m_ConnectionCount] = nId;
            m_ConnectionCount ++;
        }
    }
    if (nCol + 1 < COL && nRow - 1 > -1) { // condition5
        nId = (nRow - 1) * COL + nCol + 1;
        if ([self checkSprite:nId] == YES && [self searchPoint:nId] == NO && ([self compareIsinStack:nId] == NO || [self checkAdjancyPoint:nTouchId LastPoint:nId] == YES)) {
            m_PointsConnected[m_ConnectionCount] = nId;
            m_ConnectionCount ++;
        }
    }
    if (nCol + 1 < COL) { // condition6
        nId = nRow * COL + nCol + 1;
        if ([self checkSprite:nId] == YES && [self searchPoint:nId] == NO && ([self compareIsinStack:nId] == NO || [self checkAdjancyPoint:nTouchId LastPoint:nId] == YES)) {
            m_PointsConnected[m_ConnectionCount] = nId;
            m_ConnectionCount ++;
        }
    }
    if (nCol + 1 < COL && nRow + 1 < ROW) { // condition7
        nId = (nRow + 1) * COL + nCol + 1;
        
        if ([self checkSprite:nId] == YES && [self searchPoint:nId] == NO && ([self compareIsinStack:nId] == NO || [self checkAdjancyPoint:nTouchId LastPoint:nId] == YES)) {
            m_PointsConnected[m_ConnectionCount] = nId;
            m_ConnectionCount ++;
        }
    }
    if (nRow + 1 < ROW) {  // condition8
        nId = (nRow + 1) * COL + nCol;
        if ([self checkSprite:nId] == YES && [self searchPoint:nId] == NO && ([self compareIsinStack:nId] == NO || [self checkAdjancyPoint:nTouchId LastPoint:nId] == YES)) {
            m_PointsConnected[m_ConnectionCount] = nId;
            m_ConnectionCount ++;
        }
    }
    
    if (m_ConnectionCount == 0) {
        if (m_CntStack > 0)
            m_CntStack --;
        
        if (m_CntStack < 1) {
            if ([self checkAdjancyPoint:nSearchPos LastPoint:nTouchId] == YES && [self compareIsinStack:nSearchPos] == NO)
            {
                if (m_checkCount > 4) {
                    m_UseStackFound = YES;
                }
            }
            m_branchCount --;
            if (m_CntUseStack != 0) {
                BOOL foundfirstNumber = NO;
                for (int i = 0; i < m_checkCount; i++) {
                    if (m_checkPoints[i] != m_arrayCheckStack[m_branchCount] && foundfirstNumber == NO) {
                        continue;
                    }
                    else
                    {
                        foundfirstNumber = YES;
                    }
                    if (foundfirstNumber == YES) {
                        if (m_checkPoints[i] != m_arrayBranchFirstPos[m_branchCount]) {
                            m_ArrayUseStack[m_CntUseStack] = m_checkPoints[i];
                            m_CntUseStack ++;
                            m_lastStackSearch = m_arrayCheckStack[m_CntStack];
                        }
                        else
                            break;
                    }
                }
            }
            return;
        }
        else
        {
            //I think to add some code to fix error.
            m_branchCount --;
            if (m_CntUseStack != 0) {
                
                BOOL foundFirstNumber = NO;
                for (int i = 0; i < m_checkCount; i++) {
                    if (m_checkPoints[i] != m_lastStackSearch && foundFirstNumber == NO) {
                        continue;
                    }
                    else
                    {
                        foundFirstNumber = YES;
                        if (m_checkPoints[i] != m_arrayBranchFirstPos[m_branchCount]) {
                            m_ArrayUseStack[m_CntUseStack] = m_checkPoints[i];
                            m_CntUseStack ++;
                            m_lastStackSearch = m_arrayCheckStack[m_CntStack];
                            //                NSLog(@"The last number is %d", m_lastStackSearch);
                        }
                        else
                            break;
                    }
                }
            }
            else
            {
                for (int i = 0; i < m_checkCount; i++) {
                    if (m_checkPoints[i] != m_arrayBranchFirstPos[m_branchCount]) {
                        m_ArrayUseStack[m_CntUseStack] = m_checkPoints[i];
                        m_CntUseStack ++;
                        m_lastStackSearch = m_arrayCheckStack[m_CntStack];
                        //                NSLog(@"The last number is %d", m_lastStackSearch);
                    }
                    else
                    {
                        break;
                    }
                }
                
            }
        }
        // detect error position.
        if ([self checkAdjancyPoint:nSearchPos LastPoint:nTouchId] == YES && [self compareIsinStack:nSearchPos] == NO) {
            if (m_checkCount > 4) {
                m_UseStackFound = YES;
                return;
            }
        }
        if ([self searchPoint:m_arrayCheckStack[m_CntStack]] == NO) {
            for (int i = 0; i < m_CntUseStack; i++) {
                if ([self checkAdjancyPoint:m_ArrayUseStack[i] LastPoint:m_arrayCheckStack[m_CntStack]] == YES) {
                    m_CntUseStack = i + 1;
                }
            }
            [self searchPath:m_arrayCheckStack[m_CntStack]];
        }
        else
        {
            m_CntStack --;
            m_lastStackSearch = m_arrayCheckStack[m_CntStack];
            [self searchPath:m_arrayCheckStack[m_CntStack]];
        }
    }
    else
    {
        int nStackCount = m_CntStack;
        m_CntStack = m_CntStack +  m_ConnectionCount - 1;
        BOOL branch = NO;
        
        for (int i = m_ConnectionCount - 1; i > 0; i--) {
            branch = YES;
            [self pushStack:m_PointsConnected[i] nCount:nStackCount];
            nStackCount ++;
        }
        if (branch == YES) {
            m_arrayBranchFirstPos[m_branchCount] = m_PointsConnected[0];
            m_branchCount ++;
        }
        if (m_UseStackFound == NO) {
            for (int i = 0; i < m_ConnectionCount; i++) {
                if (m_UseStackFound == NO) {
                    [self searchPath:m_PointsConnected[i]];
                }
                else
                    return;
            }
        }
    }
}



- (BOOL) haveOldPolygon:(int)nCount pathArray:(int*) array
{
    if (m_isRed == NO) {
        for (int i = 0; i < m_redPolygonCount; i++) {
            int nCntSame = 0;
            for (int j = 0; j < m_rPolygonLineCount[i]; j ++) {
                for (int k = 0; k < nCount; k ++) {
                    NSLog(@"firstPonter = %d secondPoint = %d", m_redDrawPoints[i][j], array[k]);
                    if (m_redDrawPoints[i][j] == array[k]) {
                        nCntSame ++;
                        break;
                    }
                }
            }
            if (nCntSame == m_rPolygonLineCount[i]) {
                return YES;
            }
        }
    }
    else
    {
        for (int i = 0; i < m_bluePolygonCount; i++) {
            int nCntSame = 0;
            for (int j = 0; j < m_bPolygonLineCount[i]; j ++) {
                for (int k = 0; k < nCount; k ++) {
                    if (m_blueDrawPoints[i][j] == array[k]) {
                        nCntSame ++;
                        break;
                    }
                }
            }
            if (nCntSame == m_bPolygonLineCount[i]) {
                return YES;
            }
        }

    }
    return NO;
}


- (void) pushStack:(int)nId  nCount:(int)count
{
    m_arrayCheckStack[count] = nId;
}

- (BOOL) checkConnectionTwo:(int) i
{
    int nRow, nCol;
    nRow = i / COL;
    nCol = i % COL;
    
    int nId;
    int m_ConnectionCount = 0;
    if (nCol - 1 > -1 && nRow + 1 < ROW) {// condition1
        nId = (nRow + 1) * COL + nCol - 1;
        if ([self checkSprite:nId] == YES) {
            m_ConnectionCount ++;
        }
    }
    if (nCol - 1 > - 1) { // conditin2
        nId = nRow * COL + nCol - 1;
        if ([self checkSprite:nId] == YES) {
            m_ConnectionCount ++;
        }
    }
    if (nCol - 1 > - 1 && nRow - 1 > -1) { // condition3
        nId = (nRow - 1) * COL + nCol - 1;
        if ([self checkSprite:nId] == YES) {
            m_ConnectionCount ++;
        }
    }
    if (nRow - 1 > - 1) {  //condition4
        nId = (nRow - 1) * COL + nCol;
        if ([self checkSprite:nId] == YES) {
            m_ConnectionCount ++;
        }
    }
    if (nCol + 1 < COL && nRow - 1 > -1) { // condition5
        nId = (nRow - 1) * COL + nCol + 1;
        if ([self checkSprite:nId] == YES) {
            m_ConnectionCount ++;
        }
    }
    if (nCol + 1 < COL) { // condition6
        nId = nRow * COL + nCol + 1;
        if ([self checkSprite:nId] == YES) {
            m_ConnectionCount ++;
        }
    }
    if (nCol + 1 < COL && nRow + 1 < ROW) { // condition7
        nId = (nRow + 1) * COL + nCol + 1;
        if ([self checkSprite:nId] == YES) {
            m_ConnectionCount ++;
        }
    }
    if (nRow + 1 < ROW) {  // condition8
        nId = (nRow + 1) * COL + nCol;
        if ([self checkSprite:nId] == YES) {
            m_ConnectionCount ++;
        }
    }
    if (m_ConnectionCount < 2) {
        return NO;
    }
    return YES;
}
- (void) isCheckValid:(int) nId
{
    if ([self checkSprite:nId] == YES) {
        if ([self searchPoint:nId] == NO && [self checkConnectionTwo:nId] == YES) {
            [self searchPath:nId];
        }
    }
    else
    {
        if (m_otherConnectPoint != -1) {
            for (int i = 0; i < m_checkCount; i++) {
                if (m_checkPoints[i] == m_otherConnectPoint) {
                    m_checkCount = i;
                    break;
                }
            }
        }
    }
}

- (BOOL) pointInPolygonCount:(int) nCount posArray:(int*) array testPoint:(int) nId
{
    int i, j = nCount - 1;
    BOOL oddNodes = NO;
    
    int xTestPoint = nId % COL;
    int yTestPoint = nId / COL;
    
    int nLastId = array[nCount - 1];
    int xLastPoint = nLastId % COL;
    int yLastPoint = nLastId / COL;
    
    for (i = 0, j = nCount - 1 ; i < nCount; j = i++) {
        int xPos = array[i] % COL;
        int yPos = array[i] / COL;
        
        if (i != 0) {
            nLastId = array[i - 1];
            xLastPoint = nLastId % COL;
            yLastPoint = nLastId / COL;
        }
        if (((yPos > yTestPoint) != (yLastPoint > yTestPoint))
             && (xTestPoint < (xLastPoint - xPos) * (yTestPoint - yPos)  / (yLastPoint - yPos) + xPos))
        {
            oddNodes = !oddNodes;
        }
    }
    return oddNodes;
}

- (BOOL) checkAdjancyPoint:(int) nFirstId LastPoint:(int) nLastId
{
    
    BOOL isConnection = NO;
    int xTouch, yTouch;
    int xLast, yLast;

    
    xTouch = nFirstId % COL;
    yTouch = nFirstId / COL;
    
    xLast = nLastId % COL;
    yLast = nLastId / COL;
    
    int nDistance = abs(xTouch - xLast) + abs(yTouch - yLast);
    if (nDistance == 1) {
        isConnection = YES;
    }
    else
    {
        int xDis = abs(xTouch - xLast);
        int yDis = abs(yTouch - yLast);
        if (xDis == 1 && yDis == 1) {
            isConnection = YES;
        }
    }
    return isConnection;
}

@end
