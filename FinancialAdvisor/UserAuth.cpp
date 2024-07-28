#include "pch.h"
#include "UserAuth.h"

std::string UserAuth::hashPassword(const std::string& password)
{
	std::hash<std::string> hash_fn;
	return std::to_string(hash_fn(password));
}

void UserAuth::loadUser()
{
	std::ifstream file("user.dat");
	if (file.is_open()) {
		file >> username >> passwordHash;
		file.close();
	}
	else
	{
		std::cerr << "Error loading user data" << std::endl;
	}
}

UserAuth::UserAuth()
{
	loadUser();
}

bool UserAuth::authenticate(const std::string& inputUsername, const std::string& inputPassword)
{
	return inputUsername == username && hashPassword(inputPassword) == passwordHash;
}

void UserAuth::saveUser(const std::string& newUsername, const std::string& newPassword)
{
	username = newUsername;
	passwordHash = hashPassword(newPassword);
	std::ofstream file("user.dat");
	if (file.is_open()) {
		file << username << std::endl << passwordHash;
		file.close();
	}
	else
	{
		std::cerr << "Error saving user data" << std::endl;
	}
}

bool UserAuth::userExists()
{
	return !username.empty() && !passwordHash.empty();
}
