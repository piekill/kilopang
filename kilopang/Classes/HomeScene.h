//
//  HomeScene.h
//  kilopang
//
//  Created by Junxing Yang on 4/15/13.
//  Copyright (c) 2013 Stony Brook University. All rights reserved.
//

#ifndef kilopang_HomeScene_h
#define kilopang_HomeScene_h

#include "cocos2d.h"
#include "GameScene.h"

class HomeScene : public cocos2d::CCLayer
{
public:
	
	bool init();
	
	static cocos2d::CCScene* scene();
	
	void menuCallBack(CCObject* );
	CREATE_FUNC(HomeScene);
};


#endif
