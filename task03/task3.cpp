#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <pthread.h>
#include <sstream>
#include <fstream>
#include <string>
#include <cmath>

using namespace std;

/// <summary>
/// ��������� ������ ��� �������
/// </summary>
struct Package {
	int* array;				// ��������� �� ������ ������� ���������
	unsigned int threadNum;	// ����� ������
	unsigned int i;			// ������ ������ ������������������
	unsigned int j;			// ������ ����� ������������������
	unsigned int maxSize = 1;	// ������������ ������ ������������������
};

void* func(void* param);

int threadCount = 1;	// ���������� �������(�� ��������� ��������� ������������)
int arraySize = 0;		// ������ ��������������� �������
int* A;					// ��������� �� ������ ��������������� �������


int main(int argc, char** argv) {
	if (argc != 4) {	// ��������� �������� �� ��� ������ ���������
		cout << "Incorrect input data" << endl;
		return 0;
	}

	string in_file = argv[1];	// ���� � �����, � �������� �������
	string out_file = argv[2];	// ���� � ��������� �����
	threadCount = stoi(string(argv[3]));

	ifstream fin;	// ����� ��� ������ � ������� ������
	fin.open(in_file);
	ofstream fout;	// ����� ��� ������ � �������� ������
	fout.open(out_file);
	if (!fin.is_open() || !fout.is_open()) {	// ��������� ��� �� ������ ��� �������� ������
		cout << "File input/output error" << endl;
		return 0;
	}


	fin >> arraySize; // ������ ������ ��������������� �������
	A = new int[arraySize];	// ������� ������ �������� �����
	unsigned int index = 0;
	int num;
	while (!fin.eof() && index < arraySize)	// ��������� ������
	{
		fin >> num;
		A[index] = num;
		index++;
	}
	fin.close();	// ��������� ����� �������� �����

	pthread_t* thread = new pthread_t[threadCount];	// ������ �������
	Package* pack = new Package[threadCount];		// ������ �������� ������ ��� ������ � ��������

	// ������� �������� ������
	for (int i = 0; i < threadCount; i++) {
		// ������� ��������� ��� �������� ������
		pack[i].array = A;
		pack[i].threadNum = i;
		pthread_create(&thread[i], nullptr, func, (void*)&pack[i]);
	}


	for (int i = 0; i < threadCount; i++) {    // �������� ���������� ������ �������� �������
		pthread_join(thread[i], nullptr);       // � ��������� ���������� �� ����������
	}

	int maxElem = -1;	// ������ ��������� � ������� ��������� ������������ �� ����� ������������������
	int max = 0;		// ������������ ����� ������������������
	for (int i = 0; i < threadCount; i++) {	// ������� ������ ��������� � ������������ �������������������
		if (max < pack[i].maxSize)
		{
			max = pack[i].maxSize;
			maxElem = i;
		}
	}

	// ���������� ��������� � �������� ����
	fout << "Maximum Count = " << pack[maxElem].maxSize << "\n";
	fout << "I = " << pack[maxElem].i << "\n";
	fout << "J = " << pack[maxElem].j << "\n";

	cout << "Main end..." << endl;
}


//��������� ������� ��� �������� �������
void* func(void* param) {
	Package* p = (Package*)param; // ��������������� ���������
	unsigned int shift = arraySize / threadCount; // �������� � ������ ��� ������ �������
	int startIndex = p->threadNum * shift;	// ��������� ������ ���������
	int endIndex = startIndex + shift;		// �������� ������ ���������

	int max = 0;
	int start = 0;
	int end = 0;
	int index = startIndex;
	while (true)
	{	// ���� ������������ ������������������ � ������
		start = index;
		int res = 1;
		while (A[index] < A[index+1] && index < arraySize)	// ���� ������������������ ����������, �������������� �����
		{
			index++;
			res++;
		}
		end = index;
		if (res > max)	// ���� ��������� ��������� ����� �����������, �� �������������� �����
		{
			max = res;
			p->i = start;
			p->j = end;
			p->maxSize = res;
		}
		if (index >= endIndex)	// ���� ����� �� ������� ������ ���������, ��������� ������ ������
		{
			break;
		}
		if (start == index)
		{
			index++;
		}
	}
	return nullptr;
}
