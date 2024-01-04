#include "pch.h"
#include "game.h"

//Constructors && Destructors
Game::Game()
{
	this->initWindow();
	this->initTextures();
	this->initGUI();
	this->initWorld();
	this->initSystems();
	this->initPlayer();
	this->initEnemies();

}

Game::~Game()
{
	//delete window & player
	delete this->window;
	delete this->player;

	//delete textures
	for (auto& i : this->textures)
	{
		delete i.second;
	}

	//delete bullets
	for (auto* i : this->bullets)
	{
		delete i;
	}

	//delete enemies
	for (auto* i : this->enemies)
	{
		delete i;
	}
}

//Public Functions
void Game::run()
{
	/*
	While loop to run game
		-while the window is open...
		-update window
		-render window
	*/

	while (this->window->isOpen())
	{
		this->updatePollEvents();

		if (this->player->getHp() > 0)
			this->update();
		this->render();
	}

}

void Game::updatePollEvents()
{
	sf::Event ev;

	/*
	While loop to control the window
		-while ev is polled in the window...
		-if the event is closed...
		-close the window
		-if the escape key is pressed...
		-close the window
	*/

	while (this->window->pollEvent(ev))
	{
		if (ev.Event::type == sf::Event::Closed)
			this->window->close();
		if (ev.Event::KeyPressed && ev.Event::key.code == sf::Keyboard::Escape)
			this->window->close();
	}

}

void Game::updateInput()
{
	//Move player
	/*
		if A is pressed...
			move player to the left
		if D is pressed...
			move player to the right
		if W is pressed...
			move player up
		if S is pressed...
			move player down
	*/
	if (sf::Keyboard::isKeyPressed(sf::Keyboard::A))
		this->player->move(-1.f, 0.f);
	if (sf::Keyboard::isKeyPressed(sf::Keyboard::D))
		this->player->move(1.f, 0.f);
	if (sf::Keyboard::isKeyPressed(sf::Keyboard::W))
		this->player->move(0.f, -1.f);
	if (sf::Keyboard::isKeyPressed(sf::Keyboard::S))
		this->player->move(0.f, 1.f);

	//Create Bullets
	/*
	if the left mouse button is pressed and the player can attack...
		-push a new bullet into the bullets vector
		-bullet takes following parameters:
		-the designated bullet texture
		-player's position on x and y planes
		-players x and y directions
		-player's movement speed
	*/

	if (sf::Mouse::isButtonPressed(sf::Mouse::Left) && this->player->canATK())
	{
		this->bullets.push_back(
			new Bullet(
				this->textures["BULLET"],
				this->player->getPos().x + this->player->getBounds().width / 2.f,
				this->player->getPos().y,
				0.f,
				-1.f,
				5.f
			)
		);
	}
}

void Game::updateGUI()
{
	std::stringstream ss;
	ss << "Points: " << this->points;
	this->pointText.setString(ss.str());

	//update player GUI
	float hpPercent = static_cast<float>(this->player->getHp()) / this->player->getHpMax();
	this->playerHpBar.setSize(sf::Vector2f(300.f * hpPercent, this->playerHpBar.getSize().y));
}

void Game::updateWorld()
{

}

void Game::updateCollision()
{
	/*
	Function to update player collision with bounds of window
		-Left
			-if the players left bounds are less than the left most point of the window...
			-set the players position to 0 on the y and the top of the players bounds
			-prevents player from moving left outside of the screen
		-Right
			-else if the players left bounds plus the players width is greater than or equal to the windows size in the x axis...
			-set the players position to the size of the window in the x axis minus the players width, and the players top bound
			-prevents the player from moving right outside the window
		-Top
			-if the players top bounds are less than the top most point of the window...
			-set the players position to the left bounds of the player in the y direction, 0 in the x
			-prevents the player from moving through the top of the window
		-Bottom
			-else if the players top bounds plus the players height is greater than or equal to the size of the window in the y axis...
			-set the players position to the players left bound, and the size of the window in the y axis minus the players height
	*/

	//Left
	if (this->player->getBounds().left < 0.f)
	{
		this->player->setPosition(0.f, this->player->getBounds().top);
	}
	//Right
	else if (this->player->getBounds().left + this->player->getBounds().width >= this->window->getSize().x)
	{
		this->player->setPosition(this->window->getSize().x - this->player->getBounds().width, this->player->getBounds().top);
	}
	//Top
	if (this->player->getBounds().top < 0.f)
	{
		this->player->setPosition(this->player->getBounds().left, 0.f);
	}
	//Bottom
	else if (this->player->getBounds().top + this->player->getBounds().height >= this->window->getSize().y)
	{
		this->player->setPosition(this->player->getBounds().left, this->window->getSize().y - this->player->getBounds().height);
	}
}

void Game::updateBullets()
{
	//initialize counter 
	unsigned counter = 0;

	/*
	for the pointer bullet through the vector of bullets...
		-call update function
		-if the top + height of the bullet is less than 0...
		-delete the bullets at the value of the counter
		-erase the bullets in the vector from the beginning value + the counter
		-increment counter
	*/

	for (auto* bullet : this->bullets)
	{
		bullet->update();

		//Bullet culling (top of screen)
		if (bullet->getBounds().top + bullet->getBounds().height < 0.f)
		{
			//Delete bullet
			delete this->bullets.at(counter);
			this->bullets.erase(this->bullets.begin() + counter);
		}
		++counter;
	}
}


void Game::updateEnemies()
{
	//spawning enemies
	this->spawnTimer += 0.5f;
	if (this->spawnTimer >= this->spawnTimerMax)
	{
		this->enemies.push_back(new Enemy(rand() % this->window->getSize().x - 20.f, -100.f));

		this->spawnTimer = 0.f;

	}
	//update
	//initialize counter 
	unsigned counter = 0;

	/*
	for the pointer enemy through the vector of enemies...
		-call update function
		-if the top of the enemies is greater than the height of the window...
		-delete the enemies at the value of the counter
		-erase the enemies in the vector from the beginning value + the counter
		-increment counter
	*/

	for (auto* enemy : this->enemies)
	{
		enemy->update();

		//enemy culling (bottom of screen)
		if (enemy->getBounds().top > this->window->getSize().y)
		{
			//Delete enemy
			delete this->enemies.at(counter);
			this->enemies.erase(this->enemies.begin() + counter);
		}

		/*
		Else if the enemy touches the player...
			-player takes damage
			-delete the enemy
		*/

		else if (enemy->getBounds().intersects(this->player->getBounds()))
		{
			this->player->loseHp(this->enemies.at(counter)->getDamage());
			delete this->enemies.at(counter);
			this->enemies.erase(this->enemies.begin() + counter);

		}
		++counter;
	}
}




void Game::updateCombat()
{
	for (int i = 0; i < this->enemies.size(); ++i)
	{
		bool enemy_deleted = false;
		for (size_t k = 0; k < this->bullets.size() && enemy_deleted == false; k++)
		{
			if (this->enemies[i]->getBounds().intersects(this->bullets[k]->getBounds()))
			{

				this->points += this->enemies[i]->getPoints();

				delete this->enemies[i];
				this->enemies.erase(this->enemies.begin() + i);

				delete this->bullets[k];
				this->bullets.erase(this->bullets.begin() + k);

				enemy_deleted = true;
			}
		}
	}
}

void Game::update()
{
	this->updateInput();

	this->player->update();

	this->updateCollision();

	this->updateBullets();

	this->updateEnemies();

	this->updateCombat();

	this->updateGUI();

	this->updateWorld();
}

void Game::renderGUI()
{
	this->window->draw(this->pointText);
	this->window->draw(this->playerHpBarBack);
	this->window->draw(this->playerHpBar);
}

void Game::renderWorld()
{
	this->window->draw(this->worldBackground);
}

void Game::render()
{
	//each frame must clear the old frame
	this->window->clear();

	//draw stuff here 
	/*
	-draw world stuff
	-draw player in window
	-render bullets in window
	-render enemies in window
	*/

	this->renderWorld();

	this->player->render(*this->window);

	//bullets
	for (auto* bullet : this->bullets)
	{
		bullet->render(this->window);
	}

	//enemies
	for (auto* enemy : this->enemies)
	{
		enemy->render(this->window);
	}

	//render GUI
	this->renderGUI();

	//game over screen
	if (this->player->getHp() <= 0)
		this->window->draw(this->gameOverText);

	//display in the window
	this->window->display();
}

//Private Functions
void Game::initWindow()
{
	/*
	Create the window
	-800 x 600 pixels
	-title is "Space Game"
	-using sf::Style to display a title bar and a close button
	*/
	this->window = new sf::RenderWindow(sf::VideoMode(800, 600), "Space Game", sf::Style::Close | sf::Style::Titlebar);

	/*
	set the frame rate limit to 144
		-locks frame rate in game to 144
	*/
	this->window->setFramerateLimit(144);

	//set v-sync to false
	this->window->setVerticalSyncEnabled(false);
}

void Game::initTextures()
{
	this->textures["BULLET"] = new sf::Texture();
	this->textures["BULLET"]->loadFromFile("Textures/bullet.png");
}

void Game::initGUI()
{
	//Load font
	if (!this->font.loadFromFile("Fonts/PixellettersFull.ttf"))
	{
		std::cout << "ERROR::GAME::FAILED TO LOAD FONT" << "\n";
	}

	//init point text
	this->pointText.setPosition(650.f, 25.f);
	this->pointText.setFont(this->font);
	this->pointText.setCharacterSize(36);
	this->pointText.setFillColor(sf::Color::White);
	this->pointText.setString("test");

	//init game over text
	this->gameOverText.setFont(this->font);
	this->gameOverText.setCharacterSize(60);
	this->gameOverText.setFillColor(sf::Color::Red);
	this->gameOverText.setString("YOU ARE DEAD. GAME OVER!");
	this->gameOverText.setOutlineColor(sf::Color::White);
	this->gameOverText.setOutlineThickness(3.f);
	this->gameOverText.setPosition(
		this->window->getSize().x / 2.f - this->gameOverText.getGlobalBounds().width / 2.f,
		this->window->getSize().y / 2.f - this->gameOverText.getGlobalBounds().height / 2.f);

	//init player GUI
	this->playerHpBar.setSize(sf::Vector2f(300.f, 25.f));
	this->playerHpBar.setFillColor(sf::Color::Red);
	this->playerHpBar.setPosition(sf::Vector2f(20.f, 20.f));
	//this->playerHpBar.setOutlineColor(sf::Color::Black);
	this->playerHpBarBack = this->playerHpBar;
	this->playerHpBarBack.setFillColor(sf::Color(25, 25, 25, 200));
}

void Game::initWorld()
{
	if (!this->worldBackgroundTex.loadFromFile("Textures/background2.jpg"))
	{
		std::cout << "ERROR::GAME::INITWORLD::COULD NOT LOAD BACKGROUND TEXTURE" << "\n";
	}

	this->worldBackground.setTexture(this->worldBackgroundTex);

	this->worldBackground.setScale(1.5f, 1.5f);
}

void Game::initSystems()
{
	this->points = 0;
}

void Game::initPlayer()
{
	//initialize a new player
	this->player = new Player();
}

void Game::initEnemies()
{
	this->spawnTimerMax = 50.f;
	this->spawnTimer = this->spawnTimerMax;

}

