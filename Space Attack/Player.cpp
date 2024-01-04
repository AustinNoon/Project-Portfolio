#include "pch.h"
#include "Player.h"

//Private Functions
void Player::initVariables()
{
	//initialize movement speed
	this->movementSpeed = 2.f;
	//initalize attack cooldown max variable
	this->attackCDMax = 10.f;
	//initialize attack cooldown variable
	this->attackCD = this->attackCDMax;
	//initialize hpMax & hp
	this->hpMax = 100;
	this->hp = this->hpMax;

}

void Player::initTexture()
{
	//Load a texture from file
	if (!this->texture.loadFromFile("Textures/ship.png"))
	{
		std::cout << "ERROR::PLAYER::INITTEXTURE::Could not load texture file." << "\n";
	}

}

void Player::initSprite()
{
	//set texture to sprite
	this->sprite.setTexture(this->texture);

	//Resize the sprite
	this->sprite.scale(0.1f, 0.1f);
}

//Constructors && Destructors
Player::Player()
{
	this->initVariables();
	this->initTexture();
	this->initSprite();
}

Player::~Player()
{
	//nothing here
}

//Accessors
const sf::Vector2f& Player::getPos() const
{
	return this->sprite.getPosition();
}

const sf::FloatRect Player::getBounds() const
{
	return this->sprite.getGlobalBounds();
}

const int& Player::getHp() const
{
	return this->hp;
}

const int& Player::getHpMax() const
{
	return this->hpMax;
}

//Modifiers
void Player::setPosition(sf::Vector2f pos)
{
	this->sprite.setPosition(pos);
}

void Player::setPosition(const float x, const float y)
{
	this->sprite.setPosition(x, y);
}

void Player::setHp(const int hp)
{
	this->hp = hp;
}

void Player::loseHp(const int value)
{
	this->hp -= value;
	if (this->hp < 0)
	{
		this->hp = 0;
	}
}

//Public Functions 
void Player::move(const float dirX, const float dirY)
{
	//allow the sprite to move in 2D space (x and y directions)
	this->sprite.move(this->movementSpeed * dirX, this->movementSpeed * dirY);
}

const bool Player::canATK()
{
	/*
	Check if the player is able to attack
		-if the attack cooldown is greater than or equal to the attack cooldown max...
		-set attack cooldown equal to zero
		-return true so the player is able to attack
		-else return false, player cannot attack
	*/

	if (this->attackCD >= this->attackCDMax)
	{
		this->attackCD = 0.f;
		return true;
	}
	return false;
}

void Player::updateATKCD()
{
	/*
	Updating the attack cooldown for shooting bullets
		-if the attack cooldown is less than the attack cooldown max...
		-attack cooldown is attack cooldown + 0.5
	*/

	if (this->attackCD < this->attackCDMax)
	{
		this->attackCD += 0.5f;
	}

}

void Player::update()
{
	this->updateATKCD();
}

void Player::render(sf::RenderTarget& target)
{
	//draw the sprite onto the render target in the window
	target.draw(this->sprite);
}
