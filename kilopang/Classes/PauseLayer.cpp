//
//  PauseLayer.cpp
//  kilopang
//
//  Created by Junxing Yang on 4/19/13.
//  Copyright (c) 2013 Stony Brook University. All rights reserved.
//

#include "PauseLayer.h"
using namespace cocos2d;

bool PauseLayer::init()
{
	if(!CCLayer::init())
		return false;
	CCSprite *background = CCSprite::create("pause.png");
	background->setAnchorPoint(ccp(0,0));
	this->addChild(background,0);
	
	CCMenuItemImage* resume_item = CCMenuItemImage::create("Icon.png", "Icon.png", this, menu_selector(PauseLayer::menuCallBack));
	resume_item->setPosition(ccp(200,300));
	resume_item->setTag(0);
	CCMenuItemImage* new_item = CCMenuItemImage::create("Icon-Small.png", "Icon-Small.png", this, menu_selector(PauseLayer::menuCallBack));
	new_item->setPosition(ccp(200,150));
	new_item->setTag(1);
	CCMenuItemImage* home_item = CCMenuItemImage::create("CloseNormal.png", "CloseSelected.png", this, menu_selector(PauseLayer::menuCallBack));
	home_item->setPosition(ccp(200,50));
	home_item->setTag(2);
	
	CCMenu* menu = CCMenu::create(resume_item,new_item,home_item,NULL);
	menu->setPosition(ccp(0,0));
	this->addChild(menu,1);
	
	setTouchEnabled(true);
	return true;
}

void PauseLayer::menuCallBack(CCObject* pSender)
{
	CCScene* next;
	CCMenuItemImage* item = (CCMenuItemImage*) pSender;
	switch (item->getTag()) {
		case 0:
			this->removeFromParentAndCleanup(true);
			break;
		case 1:
			next = GameScene::scene();
			CCDirector::sharedDirector()->replaceScene(next);
			break;
		case 2:
			next = HomeScene::scene();
			CCDirector::sharedDirector()->replaceScene(next);
			break;
		default:
			break;
	}
	CCDirector::sharedDirector()->resume();
}

void PauseLayer::onEnter()
{
	CCLayer::onEnter();
}

void PauseLayer::onExit()
{
	CCDirector::sharedDirector()->getTouchDispatcher()->removeDelegate(this);
	CCLayer::onExit();
}

bool PauseLayer::ccTouchBegan(CCTouch* , CCEvent* )
{
	return true;
}

void PauseLayer::registerWithTouchDispatcher()
{
	CCTouchDispatcher* dispatcher = CCDirector::sharedDirector()->getTouchDispatcher();
	dispatcher->addTargetedDelegate(this, kCCMenuHandlerPriority, true);
}

