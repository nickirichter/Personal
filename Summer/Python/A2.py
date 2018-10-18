#!/usr/bin/env python3
from itertools import permutations
import itertools
from multiprocessing import cpu_count, Array
from A2process import NumCountProcess
import sys
import argparse
import datetime


def permCounter():
	"""Calculate permutations for list to solve math puzzle using the itertools permutations in Python
	Input: none
	Output: permutationList[permutation<str>]
	"""
	#store list of permutations of values from 1-9 in list
	permList=list(permutations([1, 2, 3, 4, 5, 6, 7, 8, 9]))
	
	#create a counting variable
	comboCounter=0
	
	#loop through all numbers in the permutation list
	for i, num in enumerate(permList):
		
		#check each permutation list at the index, then get the number in that list
		#calculate the value doing math with the number found in the list, store it in value
		value=(permList[i][0]+(13*permList[i][1]/permList[i][2])+permList[i][3]+(12*permList[i][4])-permList[i][5]-11+(permList[i][6]*permList[i][7]/permList[i][8])-10)
		
		#check if the value equals 66
		if(value==66.0):
			
			#increase the counting variable to account for another combination of numbers that will sum 66
			comboCounter+=1
			
			#print the permutation list where the sum is 66
			print(permList[i])
	
	#print the number of permutation combinations that sum 66
	print(str(comboCounter)+" number combinations")

def getInput():
	"""Function to get user input at the command line
	Specifically, numbers to add to a list. Requires an integer, and 0 will exit
	Input: none
	Output: none
	"""
	try:
		value=int(input("Enter a value to add to list, enter 0 when done: "))
	except ValueError:
		value=int(input("You must enter a number: "))
	return value

def createList():
	"""Takes user input from getInput function, creates a list of the numbers entered
	Input: none
	Output: numberList[number<str>]
	"""
	coolList=[]
	
	value=getInput()
	
	while(value!=0):
	
		#adds the numbers inputted into the list
		coolList.append(str(value))
	
		#asks for input, which overwrites the previous value
		value=getInput()
	
	return(coolList)

def permuteDaList(littyList):
	"""This function makes permutations of a list of numbers
	Input: listOfNums[number<str>]
	Output: permutationList[number<str>]
	"""
	
	#find length of the list passed in
	lengthOfList=len(littyList)
	
	#if the length of the list is 0, then there is no list
	if(lengthOfList==0):
		return("no list")
	
	#if length of list is one, there is only one item in the list therefore only one combination
	if(lengthOfList==1):
		return(littyList)
	
	#set empty list to store the current permutation
	tempList=[]
	
	#loop through every number in the list
	for i in range(lengthOfList):
		
		#extracts the current index
		extractElement=littyList[i]
		
		#remainList is the list after extracting the current number
		remainList=littyList[:i]+littyList[i+1:]
		
		#generate all permutations where extracted element is the first element
		for currentElement in permuteDaList(remainList):
			
			#concatenates the elements and appends it to the list
			tempList.append(extractElement+currentElement)
	
	return(list(set(tempList)))

def mathIsFun():
	"""This will take a list of all digits 1-9 and test to solutions to the Vietnamese math problem by making permutations of the list
	Input: none
	Output: permutationList[singlePerm<int>]
	"""
	
	#store list of permutations of values from 1-9 in list
	permList=permuteDaList(["1", "2", "3", "4", "5", "6", "7", "8", "9"])

	#create a counting variable
	comboCounter=0
	
	#loop through all numbers in the permutation list
	for i, num in enumerate(permList):
		
		#check each permutation list at the index, then get the number in that list
		#calculate the value doing math with the number found in the list, store it in value
		value=(int(permList[i][0])+(13*int(permList[i][1])/int(permList[i][2]))+int(permList[i][3])+(12*int(permList[i][4]))-int(permList[i][5])-11+(int(permList[i][6])*int(permList[i][7])/int(permList[i][8]))-10)
		
		#check if the value equals 66
		if(value==66.0):
			
			#increase the counting variable to account for another combination of numbers that will sum 66
			comboCounter+=1
			
			#print the permutation list where the sum is 66
			print(permList[i])
	
	#print the number of permutation combinations that sum 66
	print(str(comboCounter)+" number combinations")

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
	
	#adds the build argument which takes user input at the command line in order to make a list of numbers
	parser.add_argument("-b", "--build", help="build a list of numbers", type=int)
	
	#adds the permutation argument which takes the user input for a list of numbers and calls my function for making permutations 
	#of the given list of numbers
	parser.add_argument("-p", "--permutations", help="make a list and permute", type=int)
	
	#adds the process_count argument which will have the user build a list, make permutations, and use multiprocessing to make these permutations of the list
	#the input is the number of CPUs to use in the processing
	parser.add_argument("-c", "--process-count", help="max number of processes to use", type=int, default=defaultProcessCount)
	
	#add argument which will test digits 1-9 to solve the math problem to find all solutions to the Vietnamese puzzle with permutations
	parser.add_argument("-m", "--math", help="solve the math puzzle")
	
	#stores args as a parser which will read the arguments from command line
	args=parser.parse_args()
	
	if(args.build):
		
		#builds the input from command line into a list of strings
		lilGuy=[str(x) for x in str(args.build)]
		
		#prints the string
		print(lilGuy)
		
		#effectively exits this aspect of the program
		exit(0)
	
	#if the chosen user argument is to make permutations of the list
	elif(args.permutations):
		
		#stores input as list of strings
		coolList=[str(x) for x in str(args.permutations)]
		
		#prints the permutations of the list of numbers with my permuting function
		print(str(permuteDaList(coolList))+"\n")
		print(str(len(permuteDaList(coolList)))+ " permutations of your list")
		
		#effectively exits this aspect of the program
		exit(0)
	
	#if the chosen user argument is to solve the math puzzle
	elif(args.math):
		print("Fill in the blanks to get 66!")
		
		print("[]+13*[]/[]+[]+12*[]-[]-11+[]*[]/[]-10=66")
		
		print("Here's all of the ways to solve the problem: ")
		
		mathIsFun()
		
		exit(0)
	
	#if the chosen user argument is to create permutations with multiprocessing
	else:
		
		#makes sure the user-input process count is greater than 0 but less than the max number of CPU on machine
		if(args.process_count>0 and args.process_count<9):
			
			#divides input list as evenly as possible into chunks
			#in this case, it will divide a list that the user creates, after it has been permuted
			#process_count is determined by the user, which decides the number of CPU to utilize
			dividedNumList=divide(permuteDaList(createList()), args.process_count)
			
			#keeps a list of the permutations
			permutationCountList=runPermutationCounter(dividedNumList)
			print('\n')
			
			#prints the processes that are starting, which are the permutations of the user's list
			for process in dividedNumList:				
				
				#prints each permutation of each process
				for perm in process:
					
					print(str(perm)+"\n")
			
			print('\n')
			
			#stores the stop time of the multiprocessing
			stop=datetime.datetime.now()
			
			print(str(len(permutationCountList))+ " permutations of your list\n")
			
			#prints the total time for program running
			print("Runtime: "+str(stop-start))
			
			#effectively exits the program
			exit(0)
		
		else:
			print("Please enter CPU count greater than 0 and less than 9")
			
			exit(-1)
	
	
if __name__ == '__main__':
	main()

	