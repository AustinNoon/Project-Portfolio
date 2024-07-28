#include "pch.h"
#include "TransactionWindowHistory.h"

TransactionWindowHistory::TransactionWindowHistory(const std::vector<Transaction>& transactions) : transactions(transactions)
{
	window.create(sf::VideoMode(450, 600), "Transaction History");

	if (!font.loadFromFile("Fonts/MagnisaSans-Regular.ttf")) {
		std::cerr << "Error loading font" << std::endl;
	}

	titleText.setFont(font);
	titleText.setString("Transaction History");
	titleText.setCharacterSize(24);
	titleText.setFillColor(sf::Color::Black);
	titleText.setPosition(10, 10);

	float yPosition = 50;
	for (const auto& transaction : transactions) {
		sf::Text text;
		text.setFont(font);
		text.setCharacterSize(20);
		text.setFillColor(sf::Color::Black);
		std::stringstream ss;
		ss << transaction.date << " - " << transaction.type << ": $" << transaction.amount << " (Balance: $" << transaction.balanceAfter << ")";
		text.setString(ss.str());
		text.setPosition(10, yPosition);
		transactionTexts.push_back(text);
		yPosition += 30;
	}
}

void TransactionWindowHistory::run()
{
	while (window.isOpen())
	{
		sf::Event event;
		while (window.pollEvent(event)) {
			if (event.type == sf::Event::Closed) {
				window.close()
					;
			}
		}

		window.clear(sf::Color(211, 211, 211));
		draw();
		window.display();
	}
}

void TransactionWindowHistory::draw()
{
	window.draw(titleText);
	for (const auto& text : transactionTexts) {
		window.draw(text);
	}
}
