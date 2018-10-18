#!/usr/bin/env python3
from multiprocessing import Process, Value

class NumCountProcess(Process):
	def __init__(self, index, numList, permutationCountArray):
		Process.__init__(self)

		#starting index of the permutationCountArray
		self.index=index

		#list of numbers to process
		self.numList=numList

		#Keep track of the numbers processsed using a shared memory object called Value
		self.count=Value('L')

		#save counts for each number to shared memory Array
		self.count.value=index

		self.permutationCountArray=permutationCountArray
	def run(self):
		"""Executed when process is started
		"""
		#Go through each number in the list
		for number in self.numList:
			#record the count for this number
			self.permutationCountArray[self.count.value]=len(number)
			#increment total of numbers processed by this process
			self.count.value+=1

