#include "pch.h"
#include "Enemy.h"

//Private Functions
void Enemy::initVariables()
{
	this->pointCount = 6;
	this->type = 0;
	this->speed = static_cast<float>(this->pointCount / 3);
	this->hpMax = static_cast<int>(this->pointCount);
	this->hp = this->hpMax;
	this->damage = 15;
	this->points = this->pointCount;
}

void Enemy::initTexture()
{
	if (!this->enemyTexture.loadFromFile("Textures/enemy.png"))
	{
		std::cout << "ERROR::ENEMY::INITTEXTURE::COULD NOT LOAD FROM FILE" << "\n";
	}

	this->enemyTexture.setSmooth(true);
	this->enemyTexture.setRepeated(false);
}

void Enemy::initEnemySprite()
{
	this->enemySprite.setTexture(this->enemyTexture);
	this->enemySprite.setScale(0.1f, 0.1f);

}


//Constructors && Destructors
Enemy::Enemy()
{

}

Enemy::Enemy(float pos_x, float pos_y)
{
	this->initVariables();
	this->initTexture();
	this->initEnemySprite();
	this->enemySprite.setPosition(pos_x, pos_y);
}

Enemy::~Enemy()
{

}

//Accessors
const sf::FloatRect Enemy::getBounds() const
{
	return this->enemySprite.getGlobalBounds();
}

const int& Enemy::getPoints() const
{
	return this->points;
}

const int& Enemy::getDamage() const
{
	return this->damage;
}

//Public Functions
void Enemy::update()
{
	this->enemySprite.move(0.f, this->speed);
}

void Enemy::render(sf::RenderTarget* target)
{
	//render enemy onto screen
	target->draw(this->enemySprite);
}
