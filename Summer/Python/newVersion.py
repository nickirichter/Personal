from math import factorial
from multiprocessing import cpu_count, Array
from A2process import NumCountProcess
import argparse
import itertools
import sys
import datetime

def divide(inputList, processCount):
    """Given a list of values and the number of processes, divide the
       input list up into even (as even as possible) chunks.

       Input:  input list [value <object>]
               process count <int>
       Output: list of sub-lists [sub-list [<object>]]
    """
    # Calculate the index step size. Make sure the step is at least 1.
    step = max(1, len(inputList) // processCount)

    # If there are too many processes, reduce the number of processes to the number of input values
    processCount = min(processCount, len(inputList))

    # A list of sub-lists from the input list
    outputList = []

    # Go through each process number
    for number in range(processCount):
        # Calculate the "first" index for this process
        fIndex = number * step

        # Calculate the last index. If it's the last process, set the last index to the length of the input list.
        lIndex = (number + 1) * step if (number < processCount - 1) else len(inputList)

        # Append the chunk to the output list
        outputList.append(inputList[fIndex:lIndex])

    return (outputList)

def makePerms(numString):
	"""Brute force version of calculating permutations, storing them in a list
	Input: numString <str>
	Output: permutationList[singlePerm[numbers<str>]]
	"""
	#variable to count the number of permutations
	count=0
	#list to hold the permutations of the given string
	perms=[]
	#length of the string of numbers inputted
	length=len(numString)
	#loop through all the numbers between the factorial of the length
	for x in range(factorial(length)):
		#creates a list of numbers in the string to use for the permutation
		available=list(numString)
		#stores single permutation in a list
		newPerms=[]
		#loop through starting at the length of the numString, down to 0, decrementing by 1
		#this creates the single permutation
		for value in range(length, 0, -1):
			#
			placeVal=factorial(value-1)
			
			index=int(x/placeVal)
			
			newPerms.append(available.pop(index))

			x-=index*placeVal
		perms.append(newPerms)
		count+=1
	print(str(count)+" possible permutations")
	return(perms)

def runPermutationCounter(dividedNumList):
	"""Given a list of numbers which are divided into separated processes
	create a separate list of each process's permutation list
	Input: divided number/permutation list[[number<str>]]
	Output: none
	"""
	#shared memory array for each process to write to at different index
	permutationCountList=Array('B', len(list(itertools.chain(*dividedNumList))))
	#create process list to store which process is happening
	processList=[]
	#index of the starting array
	index=0
	#go through each division of perumted numbers
	for number, value in enumerate(dividedNumList):
		#process caluclates dividing the number lists
		process=NumCountProcess(index, value, permutationCountList)
		#add this process to the process list
		processList.append(process)
		#start the process
		process.start()
		print("Process", number, "started")
		#calculates starting index for the next process
		index+=len(value)
	#wait for all processes to finish
	for process in processList:
		process.join()
		#returns a list of the counts of each number in the permuted sub-list
	return(list(permutationCountList))

def main():
	"""This will test the functionality of my program. I utilize command line arguments to improve functionality 
	for my program. I test a function for building the list, permuting a list, and multiprocessing of a list.
	I also record the time for how long the processing takes with the datetime import.
	"""
	#sets the clock start time
	start=datetime.datetime.now()
	#this description is for the command line arguments, specifically the functionality of my program
	description="This script creates permutations of a list of numbers"
	#stores variable parser which will show the description when running the program 
	parser = argparse.ArgumentParser(description=description, formatter_class=argparse.RawTextHelpFormatter)
	#set the default processCount to be the amount of CPU my machine has (8)
	defaultProcessCount=cpu_count()
	
	#adds the process_count argument which will have the user build a list, make permutations, and use multiprocessing to make these permutations of the list
	#the input is the number of CPUs to use in the processing
	parser.add_argument("-c", "--process-count", help="max number of processes to use", type=int, default=defaultProcessCount)
	
	#stores args as a parser which will read the arguments from command line
	args=parser.parse_args()
	
	#divides input list as evenly as possible into chunks
	#in this case, it will divide a list that the user creates, after it has been permuted
	#process_count is determined by the user, which decides the number of CPU to utilize
	dividedNumList=divide(makePerms("123456789"), args.process_count)
	#keeps a list of the permutations
	permutationCountList=runPermutationCounter(dividedNumList)
	#prints the processes that are starting
	for process in dividedNumList:
		print(process)
	#stores the stop time of the multiprocessing
	stop=datetime.datetime.now()
	print(str(len(permutationCountList))+ " permutations of your list\n")
	#prints the total time for program running
	print(stop-start)
	#effectively exits the program
	exit(0)

	
if __name__ == '__main__':
	main()