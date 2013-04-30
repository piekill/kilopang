//
//  HomeScene.cpp
//  kilopang
//
//  Created by Junxing Yang on 4/15/13.
//  Copyright (c) 2013 Stony Brook University. All rights reserved.
//

#include "HomeScene.h"
#include "GCHelper.h"

using namespace cocos2d;

CCScene* HomeScene::scene()
{
	CCScene *scene = CCScene::create();
	
	HomeScene *home = HomeScene::create();
	
	scene->addChild(home);
	
	return scene;
}

bool HomeScene::init()
{
	if(!CCLayer::init())
		return false;
	
	CCSize size = CCDirector::sharedDirector()->getWinSize();
	
	CCSprite* pSprite = CCSprite::create("Default.png");
	
    // position the sprite on the center of the screen
    pSprite->setPosition( ccp(size.width/2, size.height/2) );
	
    // add the sprite as a child to this layer
    this->addChild(pSprite, 0);
	
	// create menu, it's an autorelease object
	CCArray* items;
	CCMenuItemSprite* menu_item;
	CCSprite* item_selected;
	CCSprite* item_normal;
	
	items = CCArray::create();
	const char* menu_pic = "menu.png";
	
	for(int i=0;i<4;i++)
	{
		item_normal = CCSprite::create(menu_pic,CCRectMake(0,42*i*2,125,42));
		item_selected = CCSprite::create(menu_pic,CCRectMake(0,42*(i*2+1),125,42));
		
		menu_item = CCMenuItemSprite::create(item_normal, item_selected, this, menu_selector(HomeScene::menuCallBack));
		
		menu_item->setPosition(ccp(size.width/2, size.height-200-i*50));
		
		menu_item->setTag(i);
		
		items->addObject(menu_item);
		
	}
	
	CCMenu* menu = CCMenu::create();
	menu->initWithArray(items);
	menu->setPosition(ccp(0,0));
	
	this->addChild(menu,1);
	
	
	return true;
}

void HomeScene::menuCallBack(CCObject* pSender)
{
	//CCTransitionScene * reScene = NULL;
	//const float t = 1.2f;
	CCScene* nextScene = NULL;
	CCMenuItemSprite* item = (CCMenuItemSprite*) pSender;
	switch (item->getTag()) {
		case 0:
			nextScene = GameScene::scene();
			break;
		case 1:
			[[GCHelper sharedInstance] showLeaderboard];
			break;
		case 2:
			nextScene = ScoreScene::scene(-1);
			break;
		case 3:
			CCDirector::sharedDirector()->end();
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
			exit(0);
#endif
			break;
		default:
			break;
	}
	if (nextScene) {
		//reScene  =CCTransitionSlideInB::create(t, nextScene);
		CCDirector::sharedDirector()->replaceScene(nextScene);
	}
	
}