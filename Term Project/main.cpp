#include "datasort.h"
#include <iostream>

int main(int argc, char* argv[]){

    //get filename of data from user
    std::string filename = argv[1];
    //append valuse from text file to data vector
    std::vector<int> data = Sort::getData(filename);

    //output original list in terminal
    std::cout << "Data: ";
    Sort::printList(data);
    std::cout << std::endl;

    //create new vector set to original list
    std::vector<int> insertionSortNumbers = data;
    //sort new data directly in the vector created
    Sort::insertionSort(insertionSortNumbers);

    //create file name for algorithm
    std::string outName = "InsertionSortedList.txt";
    //save sorted data to created file
    Sort::saveSortedToFile(insertionSortNumbers, outName);

    //output the runtime for the method in the terminal
    std::cout << "Insertion Sort: ";
    Sort::runTime(Sort::insertionSort, insertionSortNumbers);
    std::cout << std::endl;

    //create new vector set to original list
    std::vector<int> mergeData = Sort::getData(filename);
    //sort new data directly in the vector created
    Sort::mergeSort(mergeData);

    //change file name for algorithm
    outName = "MergeSortedList.txt";
    //save sorted data to created file
    Sort::saveSortedToFile(mergeData, outName);

    //output the runtime for the method in the terminal
    std::cout << "Merge Sort: ";
    Sort::runTime(Sort::mergeSort, mergeData);
    std::cout << std::endl;

    //create new vector set to original list
    std::vector<int> quickData = Sort::getData(filename);
    //sort new data directly in the vector created
    Sort::quickSort(quickData);

    //change file name for algorithm
    outName = "QuickSortedList.txt";
    //save sorted data to created file
    Sort::saveSortedToFile(quickData, outName);

    //output the runtime for the method in the terminal
    std::cout << "Quick Sort: ";
    Sort::runTime(Sort::quickSort, quickData);
    std::cout << std::endl;

    //create new vector set to original list
    std::vector<int> bucketData = Sort::getData(filename);
    //sort new data directly in the vector created
    Sort::bucketSort(bucketData);

    //change file name for algorithm
    outName = "BucketSortedList.txt";
    //save sorted data to created file
    Sort::saveSortedToFile(bucketData, outName);

    //output the runtime for the method in the terminal
    std::cout << "Bucket Sort: ";
    Sort::runTime(Sort::bucketSort, bucketData);
    std::cout << std::endl;


    return 0;
}
