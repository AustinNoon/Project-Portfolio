#include "pch.h"
#include "TransactionWindow.h"


TransactionWindow::TransactionWindow(double initBalance) : balance(initBalance) {
	window.create(sf::VideoMode(400, 300), "Transaction");

	if (!font.loadFromFile("Fonts/MagnisaSans-Regular.ttf")) {
		std::cout << "error, could not load font from file" << std::endl;
	}

	instructionText.setFont(font);
	instructionText.setString("Choose an option: ");
	instructionText.setCharacterSize(20);
	instructionText.setFillColor(sf::Color::Black);
	instructionText.setPosition(10, 10);

	balanceText.setFont(font);
	balanceText.setCharacterSize(20);
	balanceText.setFillColor(sf::Color::Black);
	balanceText.setPosition(10, 275);

	depositButton.setSize(sf::Vector2f(150, 50));
	depositButton.setFillColor(sf::Color::White);
	depositButton.setPosition(50, 75);

	depositButtonText.setFont(font);
	depositButtonText.setString("Deposit");
	depositButtonText.setCharacterSize(20);
	depositButtonText.setFillColor(sf::Color::Black);
	depositButtonText.setPosition(95, 90);

	withdrawButton.setSize(sf::Vector2f(150, 50));
	withdrawButton.setFillColor(sf::Color::White);
	withdrawButton.setPosition(210, 75);

	withdrawButtonText.setFont(font);
	withdrawButtonText.setString("Withdraw");
	withdrawButtonText.setCharacterSize(20);
	withdrawButtonText.setFillColor(sf::Color::Black);
	withdrawButtonText.setPosition(250, 90);

	inputBox.setSize(sf::Vector2f(300, 40));
	inputBox.setFillColor(sf::Color::White);
	inputBox.setOutlineColor(sf::Color::Black);
	inputBox.setOutlineThickness(2);
	inputBox.setPosition(55, 180);

	inputText.setFont(font);
	inputText.setCharacterSize(20);
	inputText.setFillColor(sf::Color::Black);
	inputText.setPosition(200, 180);

	std::stringstream ss;
	ss << "Current Balance: $" << balance;
	balanceText.setString(ss.str());

}

std::string getCurrentDate() {
	auto now = std::chrono::system_clock::now();
	std::time_t now_c = std::chrono::system_clock::to_time_t(now);
	std::tm now_tm;
	LOCALTIME_S(&now_tm, &now_c);
	std::ostringstream oss;
	oss << std::put_time(&now_tm, "%Y-%m-%d");
	return oss.str();
}
void TransactionWindow::run() {
	loadTransactions("transactions.txt");

	while (window.isOpen()) {
		sf::Event event;
		while (window.pollEvent(event)) {
			if (event.type == sf::Event::Closed)
				window.close();

			if (event.type == sf::Event::MouseButtonPressed) {
				if (event.mouseButton.button == sf::Mouse::Left) {
					sf::Vector2i mousePosition = sf::Mouse::getPosition(window);

					if (isMouseOverButton(depositButton, mousePosition)) {
						try {
							double amount = std::stod(inputString);
							std::string currentDate = getCurrentDate();
							balance += amount;
							transactions.push_back({ "Deposit" , amount, currentDate, balance });
						}
						catch (const std::exception& e) {
							std::cerr << "Invalid input for deposit: " << e.what() << std::endl;
						}
					}
					else if (isMouseOverButton(withdrawButton, mousePosition)) {
						try {
							double amount = std::stod(inputString);
							std::string currentDate = getCurrentDate();
							balance -= amount;
							transactions.push_back({ "Withdrawal", amount, currentDate, balance });
						}
						catch (const std::exception& e) {
							std::cerr << "Invalid input for withdrawal: " << e.what() << std::endl;
						}
					}

					std::stringstream ss;
					ss << "Current Balance: $" << balance;
					balanceText.setString(ss.str());
					inputString.clear();
					inputText.setString(inputString);
				}
			}

			if (event.type == sf::Event::TextEntered) {
				handleTextInput(event);
			}
		}

		window.clear(sf::Color(211, 211, 211)); // Light Grey color
		draw();
		window.display();
	}
	saveTransactions("transactions.txt");
}

void TransactionWindow::draw() {
	window.draw(instructionText);
	window.draw(balanceText);
	window.draw(depositButton);
	window.draw(depositButtonText);
	window.draw(withdrawButton);
	window.draw(withdrawButtonText);
	window.draw(inputBox);
	window.draw(inputText);
}

void TransactionWindow::handleTextInput(sf::Event& event)
{
	if (event.text.unicode == '\b')
	{
		if (!inputString.empty()) {
			inputString.pop_back();
		}
	}
	else if (event.text.unicode < 128 && event.text.unicode != 13)
	{
		inputString += static_cast<char>(event.text.unicode);
	}
	inputText.setString(inputString);
}

bool TransactionWindow::isMouseOverButton(const sf::RectangleShape& button, const sf::Vector2i& mousePosition) {
	return button.getGlobalBounds().contains(static_cast<sf::Vector2f>(mousePosition));
}

const std::vector<Transaction>& TransactionWindow::getTransactions() const
{
	return transactions;
}

void TransactionWindow::saveTransactions(const std::string& filename)
{
	std::ofstream file(filename);
	if (file.is_open())
	{
		for (const auto& transaction : transactions) {
			file << transaction.type << "," << transaction.amount << "," << transaction.date << "," << transaction.balanceAfter << "\n";
		}
		file.close();
		std::cout << "Transactions saved successfully" << std::endl;
	}
	else
	{
		std::cerr << "Unable to open file for saving transactions." << std::endl;
	}
}

void TransactionWindow::loadTransactions(const std::string& filename)
{
	std::ifstream file(filename);
	if (file.is_open())
	{
		transactions.clear();
		std::string line;
		while (std::getline(file, line)) {
			std::stringstream ss(line);
			std::string type, date;
			double amount, balanceAfter;
			std::getline(ss, type, ',');
			ss >> amount;
			ss.ignore(1, ',');
			std::getline(ss, date, ',');
			ss >> balanceAfter;
			transactions.push_back({ type, amount, date, balanceAfter });
			balance = balanceAfter;
		}
		file.close();
		std::cout << "Transactions loaded successfully" << std::endl;
		//update balance text
		std::stringstream ss;
		ss << "Current Balance: $" << balance;
		balanceText.setString(ss.str());
	}
	else
	{
		std::cerr << "Unable to open file for loading transactions" << std::endl;
	}
}

void TransactionWindow::clearBalance()
{
	balance = 0.0;
	transactions.clear();
	std::stringstream ss;
	ss << "Current Balance: $" << balance;
	balanceText.setString(ss.str());
	saveTransactions("transactions.txt");
	loadTransactions("transactions.txt");
	std::cout << "Balance and transactions cleared." << std::endl;
}
