#!/usr/bin/env python3
import sys
from decimal import Decimal
from createPlanets import *


class SolarSystem():
	"""This class instantiates the different planets from their respective
	class, which inherited from the planet class. This class also invokes
	a method with which to print the information that was created in the 
	planet class (name of planet, distance to sun in km, and orbital
	period in Earth days). This class also invokes another method which 
	calculates the number of times each planethas orbited the sun based 
	on input (in Earth days). 
	"""
	def __init__(self):
		#create instances of each planet in the solar system
		#can call methods to get information about these planets
		mercury=Mercury()
		venus=Venus()
		earth=Earth()
		mars=Mars()
		jupiter=Jupiter()
		saturn=Saturn()
		uranus=Uranus()
		neptune=Neptune()
		pluto=Pluto()
		
		#build a list of planets 
		self.planetList=[mercury, venus, earth, mars, jupiter, saturn, uranus, neptune, pluto]

	def printInfo(self):
		"""This method prints info about all of the planets 
		Inputs: none
		Outputs: Planet.name<str>
		Planet.distance<int>
		Planet.orbitalPeriod<float>
		"""
		#for every planet in the list of planets
		for planet in self.planetList:
			#get planet name, distance from sun, orbital period, spacecrafts visited, and moon list w/ this method
			planet.info()

	def calcOrbit(self, days): 
		"""This method calculates the orbital period given by user input (in earth days)
		Input: days<float>
		Output: orbitalPeriod<float> for each planet
		"""
		#converts any days inputted by user into a float
		days=float(days)
		#prints the number of days as a header
		print("In "+str(days)+" days:\n")
		#for every planet in the planet list declared in initializer
		for planet in self.planetList:
			#set variable orbit to each planet's orbital period, called from getOrbitalPeriod method in Planet class
			orbit=planet.getOrbitalPeriod()
			#calculates the number of orbits based on number of days inputted
			numOfOrbits=(days/(orbit))
			#simplify scientific notation OR 2 decimals if not tooooo small
			if(numOfOrbits<0.0001):
				#converts numOfOrbits to scientific notation
				numOfOrbits="{:.2E}".format(Decimal(numOfOrbits))
			else:
				#converts numOfOrbits to 2 decimal places
				numOfOrbits=float("{0:.2f}".format(numOfOrbits))
			#print the planet and the number of orbits for each planet given the input days
			print(planet.getName()+" has orbited the sun "+str(numOfOrbits)+" times.\n") 

def main():
	"""This is the main where the Solar System methods are called
	create an instance of SolarSystem class called daSystem lol
	"""
	daSystem=SolarSystem()
	#this function will print all data about each planet (name, distance from sun, orbital period, spacecraft visits, and names of moons)
	#daSystem.printInfo() 
	#this will calculate the number of orbits around the sun that each planet has done, based on user input of earth days
	daSystem.calcOrbit(sys.argv[1]) 

if __name__ == '__main__':
	main()