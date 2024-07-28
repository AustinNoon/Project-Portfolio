#include "pch.h"
#include "BudgetWindow.h"

// Constructor
BudgetWindow::BudgetWindow(double initialBudget, double initialSpent) : budget(initialBudget), spent(initialSpent) {
    window.create(sf::VideoMode(400, 400), "Budget Calculator");

    if (!font.loadFromFile("Fonts/MagnisaSans-Regular.ttf")) {
        std::cerr << "Error loading font" << std::endl;
        exit(-1);
    }

    titleText.setFont(font);
    titleText.setString("Set Your Monthly Budget:");
    titleText.setCharacterSize(24);
    titleText.setFillColor(sf::Color::Black);
    titleText.setPosition(10, 10);

    budgetText.setFont(font);
    budgetText.setCharacterSize(20);
    budgetText.setFillColor(sf::Color::Black);
    budgetText.setPosition(10, 50);

    spentText.setFont(font);
    spentText.setCharacterSize(20);
    spentText.setFillColor(sf::Color::Black);
    spentText.setPosition(10, 80);

    remainingText.setFont(font);
    remainingText.setCharacterSize(20);
    remainingText.setFillColor(sf::Color::Black);
    remainingText.setPosition(10, 110);

    inputBox.setSize(sf::Vector2f(300, 40));
    inputBox.setFillColor(sf::Color::White);
    inputBox.setOutlineColor(sf::Color::Black);
    inputBox.setOutlineThickness(1);
    inputBox.setPosition(50, 180);

    inputText.setFont(font);
    inputText.setCharacterSize(20);
    inputText.setFillColor(sf::Color::Black);
    inputText.setPosition(60, 190);

    spentInputBox.setSize(sf::Vector2f(300, 40));
    spentInputBox.setFillColor(sf::Color::White);
    spentInputBox.setOutlineColor(sf::Color::Black);
    spentInputBox.setOutlineThickness(1);
    spentInputBox.setPosition(50, 280);

    spentInputText.setFont(font);
    spentInputText.setCharacterSize(20);
    spentInputText.setFillColor(sf::Color::Black);
    spentInputText.setPosition(60, 290);

    setButton.setSize(sf::Vector2f(150, 50));
    setButton.setFillColor(sf::Color::White);
    setButton.setOutlineColor(sf::Color::Black);
    setButton.setOutlineThickness(1);
    setButton.setPosition(125, 225);

    setButtonText.setFont(font);
    setButtonText.setString("Set Budget");
    setButtonText.setCharacterSize(20);
    setButtonText.setFillColor(sf::Color::Black);
    setButtonText.setPosition(155, 235);

    spendButton.setSize(sf::Vector2f(150, 50));
    spendButton.setFillColor(sf::Color::White);
    spendButton.setOutlineColor(sf::Color::Black);
    spendButton.setOutlineThickness(1);
    spendButton.setPosition(125, 325);

    spendButtonText.setFont(font);
    spendButtonText.setString("Add Spent");
    spendButtonText.setCharacterSize(20);
    spendButtonText.setFillColor(sf::Color::Black);
    spendButtonText.setPosition(160, 335);

    clearButton.setSize(sf::Vector2f(100, 35));
    clearButton.setFillColor(sf::Color::White);
    clearButton.setOutlineColor(sf::Color::Black);
    clearButton.setOutlineThickness(1);
    clearButton.setPosition(270, 10);

    clearButtonText.setFont(font);
    clearButtonText.setFillColor(sf::Color::Black);
    clearButtonText.setCharacterSize(20);
    clearButtonText.setString("Clear");
    clearButtonText.setPosition(300, 15);


    cursor.setSize(sf::Vector2f(1, 25));
    cursor.setFillColor(sf::Color::Black);
    updateTexts();
}

void BudgetWindow::run() {
    // Run the window and handle events
    while (window.isOpen()) {
        sf::Event event;
        while (window.pollEvent(event)) {
            //close window
            if (event.type == sf::Event::Closed)
                window.close();
            
            //if left mouse button pressed get the position of the mouse
            if (event.type == sf::Event::MouseButtonPressed) {
                if (event.mouseButton.button == sf::Mouse::Left) {
                    sf::Vector2i mousePosition = sf::Mouse::getPosition(window);

                    if (isMouseOverButton(inputBox, mousePosition)) {
                        focusedInputBox = FocusedInputBox::Budget;
                        blinkClock.restart();
                        updateCursor();
                    }
                    else if (isMouseOverButton(spentInputBox, mousePosition)) {
                        focusedInputBox = FocusedInputBox::Spent;
                        blinkClock.restart();
                        updateCursor();
                    }
                    else if (isMouseOverButton(setButton, mousePosition)) {
                        try {
                            budget = std::stod(inputString);
                            updateTexts();
                            inputString.clear();
                            inputText.setString(inputString);
                        }
                        catch (const std::exception& e) {
                            std::cerr << "Invalid input for budget: " << e.what() << std::endl;
                        }
                    }
                    else if (isMouseOverButton(spendButton, mousePosition)) {
                        try {
                            double spentAmount = std::stod(spentInputString);
                            spent += spentAmount;
                            updateTexts();
                            spentInputString.clear();
                            spentInputText.setString(spentInputString);
                        }
                        catch (const std::exception& e) {
                            std::cerr << "Invalid input for spent amount: " << e.what() << std::endl;
                        }
                    }
                    else if (isMouseOverButton(clearButton, mousePosition)) {
                        clearBudget();
                    }
                }
            }

            if (event.type == sf::Event::TextEntered) {
                if (focusedInputBox == FocusedInputBox::Budget)
                {
                    handleTextInput(event);
                }
                else if (focusedInputBox == FocusedInputBox::Spent)
                {
                    handleSpentInput(event);
                }
                updateCursor();
            }
        }

        window.clear(sf::Color(211, 211, 211)); // Light Grey color
        draw();
        window.display();
    }
}

void BudgetWindow::draw() {
    window.draw(titleText);
    window.draw(budgetText);
    window.draw(spentText);
    window.draw(remainingText);
    window.draw(inputBox);
    window.draw(inputText);
    window.draw(spentInputBox);
    window.draw(spentInputText);
    window.draw(setButton);
    window.draw(setButtonText);
    window.draw(spendButton);
    window.draw(spendButtonText);
    window.draw(clearButton);
    window.draw(clearButtonText);

    //draw cursor
    if (focusedInputBox == FocusedInputBox::Budget && blinkClock.getElapsedTime().asSeconds() < 0.5f || focusedInputBox == FocusedInputBox::Spent && blinkClock.getElapsedTime().asSeconds() < 0.5f) {
        window.draw(cursor);
    }

    //reset clock
    if (blinkClock.getElapsedTime().asSeconds() >= 1.0f) {
        blinkClock.restart();
    }
}

void BudgetWindow::handleTextInput(sf::Event& event) {
    if (event.text.unicode == '\b') { // Handle backspace
        if (!inputString.empty()) {
            inputString.pop_back();
        }
    }
    else if (event.text.unicode < 128 && event.text.unicode != 13) { // Handle ASCII characters, ignore Enter key
        inputString += static_cast<char>(event.text.unicode);
    }
    inputText.setString(inputString);
}

void BudgetWindow::handleSpentInput(sf::Event& event) {
    if (event.text.unicode == '\b') { // Handle backspace
        if (!spentInputString.empty()) {
            spentInputString.pop_back();
        }
    }
    else if (event.text.unicode < 128 && event.text.unicode != 13) { // Handle ASCII characters, ignore Enter key
        spentInputString += static_cast<char>(event.text.unicode);
    }
    spentInputText.setString(spentInputString);
}

bool BudgetWindow::isMouseOverButton(const sf::RectangleShape& button, const sf::Vector2i& mousePosition) {
    return button.getGlobalBounds().contains(static_cast<sf::Vector2f>(mousePosition));
}

void BudgetWindow::updateTexts() {
    std::stringstream ss;
    ss << "Current Budget: $" << budget;
    budgetText.setString(ss.str());

    std::stringstream ssSpent;
    ssSpent << "Spent: $" << spent;
    spentText.setString(ssSpent.str());

    std::stringstream ssRemaining;
    ssRemaining << "Remaining: $" << budget - spent;
    remainingText.setString(ssRemaining.str());
}

void BudgetWindow::updateCursor()
{
    if (focusedInputBox == FocusedInputBox::Budget) {
        cursor.setPosition(inputText.getGlobalBounds().left + inputText.getGlobalBounds().width + 5, inputText.getPosition().y);
    }
    else if (focusedInputBox == FocusedInputBox::Spent) {
        cursor.setPosition(spentInputText.getGlobalBounds().left + spentInputText.getGlobalBounds().width + 5, spentInputText.getPosition().y);
    }
}

void BudgetWindow::clearBudget()
{
    budget = 0.0;
    spent = 0.0;
    updateTexts();
    inputString.clear();
    inputText.setString(inputString);
    spentInputString.clear();
    spentInputText.setString(spentInputString);
}

double BudgetWindow::getBudget() const {
    return budget; //get budget
}

double BudgetWindow::getSpent() const {
    return spent; //get spent
}
