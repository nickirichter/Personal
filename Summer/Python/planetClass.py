#!/usr/bin/env python3

#declare class 
class Planet(object):
	"""This is my planet class, where a planet is constructed with a name,
	distance to the sun in km, and orbital period measured in Earth days.
	This class also includes getters and setters for this information,
	and a function to return the name, distance, and orbital period.
	"""
	def __init__(self, name, distance, orbitalPeriod):
		"""Here is the constructor
		Input: name<str>
		distance<int> measured in km
		orbitalPeriod<float> measured in Earth days
		Output: none
		"""
		self.name=name
		self.distance=distance
		self.orbitalPeriod=orbitalPeriod

	def getDistance(self):
		"""Getter to get the distance of a planet from the sun
		Input: none
		Output: distance<int>
		"""
		return(self.distance)

	def getName(self):
		"""Getter to get name of planet
		Input: none
		Output: name<str>
		"""
		return(self.name)

	def getOrbitalPeriod(self):
		"""Getter to get the orbital period of planet
		Input: none
		Output: orbitalPeriod<float>
		"""
		return(self.orbitalPeriod)

	def info(self):
		"""Function to output the information of planet
		Input: none
		Output: name<str>
		distance<int>
		orbitalPeriod<float>
		"""
		print("The planet "+self.getName()+" is "+str(self.getDistance())+
			"km to the sun and takes "+str(self.getOrbitalPeriod())+ 
			" Earth days to orbit the sun.")

	def setDistancetoSun(self, distance):
		"""Sets the distance from getter to the distance of planet
		Input: distance<int>
		Output: none
		"""
		self.distance=distance

	def setName(self, name):
		"""Sets name from getter to the planet name
		Input: name<str>
		Output: none
		"""
		self.name=name
	
	def setOrbitalPeriod(self, orbitalPeriod):
		"""Sets orbital period from getter to planet's orbital period
		Input: orbitalPeriod<float>
		Output: none
		"""
		self.orbitalPeriod=orbitalPeriod