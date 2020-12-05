#include <iostream>
#include <stdio.h>
#include <sstream>
#include <string>
#include <omp.h>
#include <fstream>
#include <vector>
#include <algorithm>

using namespace std;

int threadCount = 1;	// Количество потоков (по умолчанию программа однопоточавая)
int arraySize = -1;		
int* A;					// Исходный числовой ряд
int* lenghts;			// Длина неубывающего ряда до конкретного элемента
int maxCount = -1;		// Максимальная длина ряда
int I = -1;
int J = -1;

int main(int argc, char* argv[])
{
	if (argc != 4) {	// Проверяем правильность входных аргументов
		cout << "Incorrect input data" << endl;
		return 0;
	}

	string in_file = argv[1];	// Путь до файла с входными данными
	string out_file = argv[2];	// Путь до выходного файла
	threadCount = stoi(string(argv[3]));

	ifstream fin;	// Поток чтения из файла
	fin.open(in_file);
	ofstream fout;	// Поток записи в авходной файл
	fout.open(out_file);
	if (!fin.is_open() || !fout.is_open()) {
		cout << "File input/output error" << endl;
		return 0;
	}


	fin >> arraySize;		// Получаем длину ряда
	A = new int[arraySize];
	lenghts = new int[arraySize];
	for (size_t i = 0; i < arraySize; i++)
	{
		lenghts[i] = 1;
	}
	unsigned int index = 0;
	int num;
	while (!fin.eof() && index < arraySize)	// Заполняем массив чисел
	{
		fin >> num;
		A[index] = num;
		index++;
	}
	fin.close();	// Закрываем поток чтения


	
#pragma omp parallel num_threads(threadCount) // Создаем параллельную область выполнения
	{
# pragma omp for // Распараллеливаем цикл
		for (int i = 0; i < arraySize; i++)
		{	// Ищем длину неубывающего ряда для каждого элемента
			for (int j = 0; j < i; j++)
			{
				if (A[j] < A[j+1] && j < arraySize)
				{
					lenghts[i] = lenghts[i] + 1;
				}
				else {
					lenghts[i] = 1;
				}
			}
		}
	}


	for (int i = 0; i < arraySize; i++)
	{	// Ищем максимальную длину ряда
		if (lenghts[i] > maxCount)
		{
			maxCount = lenghts[i];
			J = i;
			I = J - maxCount + 1;
		}
	}

	// Выводим информацию в файл
	fout << "Maximum Count = " << maxCount << "\n";
	fout << "I = " << I << "\n";
	fout << "J = " << J << "\n";

	cout << "Main end..." << endl;
}
