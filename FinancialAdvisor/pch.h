#pragma once
#include <iostream>
//standard c++ includes
#include <iostream>
#include <sstream>
#include <string>
#include <vector>
#include <fstream>
#include <ctime>
#include <chrono>
#include <iomanip>
#include <limits>
#include <unordered_map>
#include <functional>
#include <filesystem>

//sfml includes
#include <SFML/Graphics.hpp>
#include <SFML/Audio.hpp>
#include <SFML/Network.hpp>
#include <SFML/System.hpp>
#include <SFML/Window.hpp>

#ifdef _WIN32
#define LOCALTIME_S(tm, time) localtime_s(tm, time) //windows systems

#else 
#define LOCALTIME_S(tm, time) localtime_r(time, tm) //safe for cross platforming for POSIX systems
#endif
