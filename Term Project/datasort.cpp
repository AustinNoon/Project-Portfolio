#include "datasort.h"
#include <iostream>
#include <fstream>
#include <sstream>
#include <cstdlib>
#include <ctime>
#include <chrono>
#include <iomanip>

std::vector<int> Sort::getData(const std::string& filename){
    std::vector<int> numbers;

    std::ifstream inputFile(filename);

    int num;
    while(inputFile >> num){
        numbers.push_back(num);
    }

    return numbers;
}

//insertion sort method
void Sort::insertionSort(std::vector<int>& list){

    //for loop to iterate through the list
    //start at the second number as index 1
    for(unsigned int i = 1; i < list.size(); i++){

        //initialize temporary variable to hold the value of the right number
        int temp = list[i];

        //initialize j to be the place of the number to the left of temp
        int j = i - 1;

        //while left number is greater than the right number,
        while(j >= 0 && list[j] > temp){

            //move left number to the right
            list[j + 1] = list[j];
            //decrement j to move left in the list
            j--;
        }

        //before for loop repeats, assign list[j + 1] to temp
        list[j + 1] = temp;
    }
}

void Sort::mergeSort(std::vector<int>& list){
    mergeHelper(list, 0, list.size() - 1);//calls mergeHelper
}

void Sort::mergeHelper(std::vector<int>& list, int left, int right){
    if(left < right){//checks if left is smaller than right and keeps halving till one element is left
        int mid = left + (right - left) / 2;//gets middle 

        mergeHelper(list, left, mid);//uses recursion to sort left
        mergeHelper(list, mid + 1, right);//uses recursion to sort right

        merge(list, left, mid, right);//once the two are sorted, it gets merged
    }
}

void Sort::merge(std::vector<int>& list, int left, int mid, int right){//functions to merge both sorted halves back together
    int x1 = mid - left + 1;//gets size of left
    int x2 = right - mid;//gets size of right

    std::vector<int> Left(x1);//temp vector for left
    std::vector<int> Right(x2);//temp vector for right

    for(int i = 0; i < x1; ++i){//gets values for left side
        Left[i] = list[left + i];
    }

    for(int j = 0; j < x2; ++j){//gets values on right side
        Right[j] = list[mid + 1 + j];
    }
    

    int i = 0, j = 0;
    int k = left;

    while(i < x1 && j < x2){//merge elements from left
        if(Left[i] <= Right[j]){
            list[k] = Left[i];
            i++;
        }else{//merges right
            list[k] = Right[j];
            j++;
        }
        k++;
    }

    while(i < x1){//gets values from left
        list[k] = Left[i];
        i++;
        k++;
    }

    while(j < x2){//gets values from right
        list[k] = Right[j];
        j++;
        k++;
    }
}

void Sort::quickSort(std::vector<int>& list){ // public method to initiate quickSort on a vector
    quickHelper(list, 0, list.size() - 1); //base parameters for initialization
}

void Sort::quickHelper(std::vector<int>& list, int low, int high){ //helper method for quicksort
    if(low < high){//recursive base case, if low index is less than high index
        int pivotIdx = partition(list, low, high); // find the pivot index through partitioning 
        //recursively sort the subu arrays before and after pivot
        quickHelper(list, low, pivotIdx - 1); // before
        quickHelper(list, pivotIdx + 1, high); // after
    }
}

int Sort::partition(std::vector<int>& list, int low, int high){//partition the vector and return the index of the pivot element 
    int pivot = list[high]; // choose the right most element as the pivot
    int i = low - 1; // initialize the index of the smaller element 
    for(int j = low; j <= high - 1; ++j){ //iterate through the elements from low to high - 1
        if(list[j] < pivot){ // if current element is smaller than the pivot
            i++; // increment index of smaller element
        std::swap(list[i], list[j]); // swap current element with element at smaller index 
        }
    }
    std::swap(list[i + 1],list[high]); // swap the pivot element with the element at the next index of the smaller element 
    return i + 1; // return the index of the pivot element
}

void Sort::runTime(void(*sortFunction)(std::vector<int>&), std::vector<int>& list){ // function to benchmark the runtime of the sorting algorithms
    auto start = std::chrono::high_resolution_clock::now(); //point to start the clock
    sortFunction(list); //call the sorting function to be measured 
    auto stop = std::chrono::high_resolution_clock::now(); // point to stop the clock

    auto duration = std::chrono::duration_cast<std::chrono::nanoseconds>(stop - start).count(); //finding the duration of algorithm by subtracting stop from start
    std::cout << "Time taken by: " << std::fixed << std::setprecision(6) << duration << " nanoseconds" << std::endl; //print the time taken to run function
}

void Sort::saveSortedToFile(const std::vector<int>& list, std::string outName){
    //save sorted list to a seperate file
    std::ofstream outFile(outName);

    //for loop to write sorted list to outFile
    for(int num : list){
        outFile << num << " ";
    }

    //close file
    outFile.close();
}

int Sort::findMin(std::vector<int>& list){
    if(list.empty())
    {
        return -1;
    }

    unsigned int min = list[0];
    for(unsigned int num = 0; num < list.size(); num++){
        while(num < min){
            min = num;
        }
    }
    return min;
}

int Sort::findMax(std::vector<int>& list){
    if(list.empty()){
        return -1;
    }

    unsigned int max = list[0];
    for(unsigned int num = 0; num <list.size(); num++){
        if(num > max){
            max = num;
        }
    }

    return max;
}

void Sort::bucketSort(std::vector<int>& list){
    int min = findMin(list);//gets min
    int max = findMax(list);//gets max

    int size = (max - min) / (list.size() - 1);
    
    std::vector<std::vector<int>> buckets(list.size());

    for(unsigned int val = 1; val < list.size(); val++){
        int index = (val - min) / size;
        buckets[index].push_back(val);
    }

    for(auto& bucket : buckets){
        insertionSort(bucket);
    }

    int temp = 0;
    for(const auto& bucket : buckets){
        for(int num : bucket){
            list[temp++] = num;
        }
    }
}

void Sort::printList(const std::vector<int>& list){
    for(int num : list){
        std::cout << num << " ";
    }
    std::cout << std::endl;
}
