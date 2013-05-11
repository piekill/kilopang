//
//  Elf.cpp
//  kilopang
//
//  Created by Junxing Yang on 4/15/13.
//  Copyright (c) 2013 Stony Brook University. All rights reserved.
//

#include "Elf.h"

bool Elf::initInGame(GameScene* game, int i, int j)
{
	if (!CCNode::init())
		return NULL;
	this->game = game;
	game->addChild(this);
	
	CCSpriteBatchNode* elfSheet = (CCSpriteBatchNode*)game->getChildByTag(ELFSHEET);
	elfSprite = CCSprite::createWithTexture(elfSheet->getTexture());
	initElfSprite(i, j, -1, Normal, false);
	elfSheet->addChild(elfSprite);
	selected = false;
	return true;
}

void Elf::initElfSprite(int i, int j, int type, elfAttr elfattr, bool fromTop)
{
	elfType = type==-1?arc4random() % ELF_TYPES:type;
	attr = elfattr;
	elfSprite->setTextureRect(CCRectMake((elfType%3)*ELF_SIZE, elfType/3*ELF_SIZE,  ELF_SIZE-2, ELF_SIZE-2));
	elfSprite->setAnchorPoint(ccp(0,0));
	if (elfattr == Bigbang) {
		elfSprite->setScale(0.5);
	}
	else
		elfSprite->setScale(1.0);
	if (!fromTop)
		elfSprite->setPosition(ccp(ELF_SIZE*j + GRID_OFFSET.x,ELF_SIZE*(GRID_ROW-i-1)+GRID_OFFSET.y));
	else{
		elfSprite->setPosition(ccp(ELF_SIZE*j + GRID_OFFSET.x, ELF_SIZE*(GRID_ROW-i-1)+480));
	}
	col = j;
}

void Elf::elfAction(CCAction* action)
{
	elfSprite->runAction(action);
}

void Elf::select()
{
	selected = true;
}

void Elf::unselect()
{
	selected = false;
}

bool Elf::isSelected() const
{
	return selected;
}

int Elf::getType() const
{
	return elfType;
}

elfAttr Elf::getAttr() const
{
	return attr;
}

void Elf::setAttr(elfAttr attribute)
{
	attr = attribute;
}

void Elf::setElfPos(const CCPoint& pos)
{
	elfSprite->setPosition(pos);
}

const CCPoint& Elf::getElfPos()const
{
	return elfSprite->getPosition();
}

int Elf::getCol()const
{
	return col;
}