//
//  PauseLayer.h
//  kilopang
//
//  Created by Junxing Yang on 4/19/13.
//  Copyright (c) 2013 Stony Brook University. All rights reserved.
//

#ifndef kilopang_PauseLayer_h
#define kilopang_PauseLayer_h

#include "cocos2d.h"
#include "GameScene.h"
#include "HomeScene.h"
using namespace cocos2d;

class PauseLayer : public cocos2d::CCLayer
{
public:
	
	bool init();
	
	void menuCallBack(CCObject* );
	
	void onEnter();
	void onExit();
	bool ccTouchBegan(CCTouch* , CCEvent* );  
	void registerWithTouchDispatcher();
	
	CREATE_FUNC(PauseLayer);
};
#endif
