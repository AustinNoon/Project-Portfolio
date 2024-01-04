#include "pch.h"
#include "Bullet.h"

//Constructors && Destructors 
Bullet::Bullet()
{

}

Bullet::Bullet(sf::Texture* texture, float pos_X, float pos_Y, float dir_X, float dir_Y, float movement_speed)
{
	//construct the bullet
	this->shape.setTexture(*texture);
	this->shape.setPosition(pos_X, pos_Y);
	this->direction.x = dir_X;
	this->direction.y = dir_Y;
	this->movementSpeed = movement_speed;
}

Bullet::~Bullet()
{

}

//Accessors
const sf::FloatRect Bullet::getBounds() const
{
	return this->shape.getGlobalBounds();
}

//Public Functions
void Bullet::update()
{
	//movement
	this->shape.move(this->movementSpeed * this->direction);
}

void Bullet::render(sf::RenderTarget* target)
{
	//render bullet onto screen
	target->draw(this->shape);
}
