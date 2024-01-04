#pragma once
#ifndef DATASORT_H
#define DATASORT_H

#include <vector>
#include <string>

class Sort{
public:
    static std::vector<int> getData(const std::string& filename);
    static void printList(const std::vector<int>& list);
    static void saveSortedToFile(const std::vector<int>& list, std::string outName);
    static void insertionSort(std::vector<int>& list);
    static void quickSort(std::vector<int>& list);
    static void mergeSort(std::vector<int>& list);
    static void bucketSort(std::vector<int>& list);
    static int findMin(std::vector<int>& list);
    static int findMax(std::vector<int>& list);
    static void runTime(void(*sortFunction)(std::vector<int>&), std::vector<int>& list);

private:
    static void quickHelper(std::vector<int>& list, int low, int high);
    static int partition(std::vector<int>& list, int low, int high);
    static void merge(std::vector<int>& list, int left, int mid, int right);
    static void mergeHelper(std::vector<int>& list, int left, int right);
    
};

#endif
