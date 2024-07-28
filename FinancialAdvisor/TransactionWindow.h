#pragma once
#include "pch.h"

struct Transaction
{
	std::string type;
	double amount;
	std::string date;
	double balanceAfter;
};

class TransactionWindow {
private:
	sf::RenderWindow window;
	sf::Font font;
	sf::Text instructionText;
	sf::Text balanceText;
	sf::Text depositButtonText;
	sf::Text withdrawButtonText;
	sf::Text inputText;
	sf::RectangleShape inputBox;
	sf::RectangleShape depositButton;
	sf::RectangleShape withdrawButton;
	double balance;
	std::string inputString;
	std::vector<Transaction> transactions;

public:
	TransactionWindow(double initBalance);
	void run();
	void draw();
	void handleTextInput(sf::Event& event);
	bool isMouseOverButton(const sf::RectangleShape& button, const sf::Vector2i& mousePosition);
	const std::vector<Transaction>& getTransactions() const;
	void saveTransactions(const std::string& filename);
	void loadTransactions(const std::string& filename);
	void clearBalance();
};

