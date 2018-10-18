#!/usr/bin/env python3
from planetClass import Planet

#create classes for each planet, of type Planet
class Mercury(Planet):
	"""Create class for Mercury, inherits from Planet class to maintain
	data from Planet. Also includes methods for other data not in Planet
	class.
	"""
	def __init__(self):
		"""Constructor, also uses constructor from planet class to get/set
		aspects of planet from Planet class
		Input: Planet.name<str>
		Planet.distance<int>
		Planet.orbitalPeriod<float>
		spacecraftVisits<int>
		moonList[moonNames<str>]
		"""
		Planet.__init__(self, "Mercury", 47000000, 88.0)

		self.spacecraftVisits=2
		self.moonList=["None"]

	#add more information for Mercury class
	def getSpacecraftVisits(self):
		"""Getter to get the number of successful spacecraft visits
		This can include flybys; may not necessarily be landings
		Input: none
		Output: spacecraftVisits<float>
		"""
		return(self.spacecraftVisits)

	def getMoonList(self):
		"""Getter to get the number of moons planet has (if any). List includes
		only major moons, may not necessarily have all of the moons of a planet
		Input: none
		Output: moonList[moonName<str>]
		"""
		return('%s' %', '.join(map(str, self.moonList)))
	
	def info(self):
		print("The planet "+self.getName()+" is "+str(self.getDistance())+
			"km to the sun and takes "+str(self.getOrbitalPeriod())+ 
			" Earth days to orbit the sun. "+str(self.getSpacecraftVisits())+" spacecrafts have visited. "+
			"Mercury's list of moons: "+str(self.getMoonList())+"\n")

class Venus(Planet):
	"""Create class for Venus, inherits from Planet class to maintain
	data from Planet. Also includes methods for other data not in Planet
	class.
	"""
	def __init__(self):
		"""Constructor, also uses constructor from planet class to get/set
		aspects of planet from Planet class
		Input: Planet.name<str>
		Planet.distance<int>
		Planet.orbitalPeriod<float>
		spacecraftVisits<int>
		moonList[moonNames<str>]
		"""
		Planet.__init__(self, "Venus", 57909050, 224.7)

		self.spacecraftVisits=20
		self.moonList=["None"]
	
	def getSpacecraftVisits(self):
		"""Getter to get the number of successful spacecraft visits
		This can include flybys; may not necessarily be landings
		Input: none
		Output: spacecraftVisits<float>
		"""
		return(self.spacecraftVisits)
	
	def getMoonList(self):
		"""Getter to get the number of moons planet has (if any). List includes
		only major moons, may not necessarily have all of the moons of a planet
		Input: none
		Output: moonList[moonName<str>]
		"""
		return('%s' %', '.join(map(str, self.moonList)))

	def info(self):
		print("The planet "+self.getName()+" is "+str(self.getDistance())+
			"km to the sun and takes "+str(self.getOrbitalPeriod())+ 
			" Earth days to orbit the sun. "+str(self.getSpacecraftVisits())+" spacecrafts have visited. "+
			"Venus's list of moons: "+str(self.getMoonList())+"\n")

class Earth(Planet):
	"""Create class for Earth, inherits from Planet class to maintain
	data from Planet. Also includes methods for other data not in Planet
	class.
	"""
	def __init__(self):
		"""Constructor, also uses constructor from planet class to get/set
		aspects of planet from Planet class
		Input: Planet.name<str>
		Planet.distance<int>
		Planet.orbitalPeriod<float>
		oceanList[oceanName<str>]
		continentList[continentName<str>]
		"""
		Planet.__init__(self, "Earth", 150000, 365)
		
		self.spacecraftVisits=('inf')
		self.moonList=["Moon"]
	
	def getSpacecraftVisits(self):
		"""Getter to get the number of successful spacecraft visits
		This can include flybys; may not necessarily be landings
		Input: none
		Output: spacecraftVisits<float>
		"""
		return(self.spacecraftVisits)
	
	def getMoonList(self):
		"""Getter to get the number of moons planet has (if any). List includes
		only major moons, may not necessarily have all of the moons of a planet
		Input: none
		Output: moonList[moonName<str>]
		"""
		return('%s' %', '.join(map(str, self.moonList)))

	def info(self):
		print("The planet "+self.getName()+" is "+str(self.getDistance())+
			"km to the sun and takes "+str(self.getOrbitalPeriod())+ 
			" Earth days to orbit the sun. "+str(self.getSpacecraftVisits())+" spacecrafts have visited. "+
			"Earth's list of moons: "+str(self.getMoonList())+"\n")

class Mars(Planet):
	"""Create class for Mars, inherits from Planet class to maintain
	data from Planet. Also includes methods for other data not in Planet
	class.
	"""
	def __init__(self):
		"""Constructor, also uses constructor from planet class to get/set
		aspects of planet from Planet class
		Input: Planet.name<str>
		Planet.distance<int>
		Planet.orbitalPeriod<float>
		spacecraftVisits<int>
		moonList[moonNames<str>]
		"""
		Planet.__init__(self, "Mars", 228000000, 687)

		self.spacecraftVisits=18
		self.moonList=["Phobos", "Deimos"]
	
	def getSpacecraftVisits(self):
		"""Getter to get the number of successful spacecraft visits
		This can include flybys; may not necessarily be landings
		Input: none
		Output: spacecraftVisits<float>
		"""
		return(self.spacecraftVisits)
	
	def getMoonList(self):
		"""Getter to get the number of moons planet has (if any). List includes
		only major moons, may not necessarily have all of the moons of a planet
		Input: none
		Output: moonList[moonName<str>]
		"""
		return('%s' %', '.join(map(str, self.moonList)))

	def info(self):
		print("The planet "+self.getName()+" is "+str(self.getDistance())+
			"km to the sun and takes "+str(self.getOrbitalPeriod())+ 
			" Earth days to orbit the sun. "+str(self.getSpacecraftVisits())+" spacecrafts have visited. "+
			"Mars's list of moons: "+str(self.getMoonList())+"\n")

class Jupiter(Planet):
	"""Create class for Jupiter, inherits from Planet class to maintain
	data from Planet. Also includes methods for other data not in Planet
	class.
	"""
	def __init__(self):
		"""Constructor, also uses constructor from planet class to get/set
		aspects of planet from Planet class
		Input: Planet.name<str>
		Planet.distance<int>
		Planet.orbitalPeriod<float>
		spacecraftVisits<int>
		moonList[moonNames<str>]
		"""
		Planet.__init__(self, "Jupiter", 778547200, 10475.8)

		self.spacecraftVisits=4
		self.moonList=["Europa", "Ganymede", "Callisto", "Io"]
	
	def getSpacecraftVisits(self):
		"""Getter to get the number of successful spacecraft visits
		This can include flybys; may not necessarily be landings
		Input: none
		Output: spacecraftVisits<float>
		"""
		return(self.spacecraftVisits)
	
	def getMoonList(self):
		"""Getter to get the number of moons planet has (if any). List includes
		only major moons, may not necessarily have all of the moons of a planet
		Input: none
		Output: moonList[moonName<str>]
		"""
		return('%s' %', '.join(map(str, self.moonList)))

	def info(self):
		print("The planet "+self.getName()+" is "+str(self.getDistance())+
			"km to the sun and takes "+str(self.getOrbitalPeriod())+ 
			" Earth days to orbit the sun. "+str(self.getSpacecraftVisits())+" spacecrafts have visited. "+
			"Jupiter's list of moons: "+str(self.getMoonList())+"\n")

class Saturn(Planet):
	"""Create class for Saturn, inherits from Planet class to maintain
	data from Planet. Also includes methods for other data not in Planet
	class.
	"""
	def __init__(self):
		"""Constructor, also uses constructor from planet class to get/set
		aspects of planet from Planet class
		Input: Planet.name<str>
		Planet.distance<int>
		Planet.orbitalPeriod<float>
		spacecraftVisits<int>
		moonList[moonNames<str>]
		"""
		Planet.__init__(self, "Saturn", 1400000000, 10759)

		self.spacecraftVisits=4
		self.moonList=["Mimas", "Enceladus", "Tethys", "Dione", "Rhea", "Titan", "Iapetus"]
	
	def getSpacecraftVisits(self):
		"""Getter to get the number of successful spacecraft visits
		This can include flybys; may not necessarily be landings
		Input: none
		Output: spacecraftVisits<float>
		"""
		return(self.spacecraftVisits)
	
	def getMoonList(self):
		"""Getter to get the number of moons planet has (if any). List includes
		only major moons, may not necessarily have all of the moons of a planet
		Input: none
		Output: moonList[moonName<str>]
		"""
		return('%s' %', '.join(map(str, self.moonList)))

	def info(self):
		print("The planet "+self.getName()+" is "+str(self.getDistance())+
			"km to the sun and takes "+str(self.getOrbitalPeriod())+ 
			" Earth days to orbit the sun. "+str(self.getSpacecraftVisits())+" spacecrafts have visited. "+
			"Saturn's list of moons: "+str(self.getMoonList())+"\n")

class Uranus(Planet):
	"""Create class for Uranus, inherits from Planet class to maintain
	data from Planet. Also includes methods for other data not in Planet
	class.
	"""
	def __init__(self):
		"""Constructor, also uses constructor from planet class to get/set
		aspects of planet from Planet class
		Input: Planet.name<str>
		Planet.distance<int>
		Planet.orbitalPeriod<float>
		spacecraftVisits<int>
		moonList[moonNames<str>]
		"""
		Planet.__init__(self, "Uranus", 2876679032, 30687.15)

		self.spacecraftVisits=9
		self.moonList=["Puck", "Titania", "Rosalind", "Umbriel", "Oberon", "Ariel"]
	
	def getSpacecraftVisits(self):
		"""Getter to get the number of successful spacecraft visits
		This can include flybys; may not necessarily be landings
		Input: none
		Output: spacecraftVisits<float>
		"""
		return(self.spacecraftVisits)
	
	def getMoonList(self):
		"""Getter to get the number of moons planet has (if any). List includes
		only major moons, may not necessarily have all of the moons of a planet
		Input: none
		Output: moonList[moonName<str>]
		"""
		return('%s' %', '.join(map(str, self.moonList)))

	def info(self):
		print("The planet "+self.getName()+" is "+str(self.getDistance())+
			"km to the sun and takes "+str(self.getOrbitalPeriod())+ 
			" Earth days to orbit the sun. "+str(self.getSpacecraftVisits())+" spacecrafts have visited. "+
			"Uranus's list of moons: "+str(self.getMoonList())+"\n")

class Neptune(Planet):
	"""Create class for Neptune, inherits from Planet class to maintain
	data from Planet. Also includes methods for other data not in Planet
	class.
	"""
	def __init__(self):
		"""Constructor, also uses constructor from planet class to get/set
		aspects of planet from Planet class
		Input: Planet.name<str>
		Planet.distance<int>
		Planet.orbitalPeriod<float>
		spacecraftVisits<int>
		moonList[moonNames<str>]
		"""
		Planet.__init__(self, "Neptune", 4503443661, 60190.03 )

		self.spacecraftVisits=9
		self.moonList=["Proteus", "Larissa", "Triton"]
	
	def getSpacecraftVisits(self):
		"""Getter to get the number of successful spacecraft visits
		This can include flybys; may not necessarily be landings
		Input: none
		Output: spacecraftVisits<float>
		"""
		return(self.spacecraftVisits)
	
	def getMoonList(self):
		"""Getter to get the number of moons planet has (if any). List includes
		only major moons, may not necessarily have all of the moons of a planet
		Input: none
		Output: moonList[moonName<str>]
		"""
		return('%s' %', '.join(map(str, self.moonList)))

	def info(self):
		print("The planet "+self.getName()+" is "+str(self.getDistance())+
			"km to the sun and takes "+str(self.getOrbitalPeriod())+ 
			" Earth days to orbit the sun. "+str(self.getSpacecraftVisits())+" spacecrafts have visited. "+
			"Neptune's list of moons: "+str(self.getMoonList())+"\n")

class Pluto(Planet):
	"""Create class for Pluto, inherits from Planet class to maintain
	data from Planet. Also includes methods for other data not in Planet
	class.
	"""
	def __init__(self):
		"""Constructor, also uses constructor from planet class to get/set
		aspects of planet from Planet class
		Input: Planet.name<str>
		Planet.distance<int>
		Planet.orbitalPeriod<float>
		spacecraftVisits<int>
		moonList[moonNames<str>]
		"""
		Planet.__init__(self, "Pluto", 5906380000, 103660)

		self.spacecraftVisits=1
		self.moonList=["Charon"]
	
	def getSpacecraftVisits(self):
		"""Getter to get the number of successful spacecraft visits
		This can include flybys; may not necessarily be landings
		Input: none
		Output: spacecraftVisits<float>
		"""
		return(self.spacecraftVisits)
	
	def getMoonList(self):
		"""Getter to get the number of moons planet has (if any). List includes
		only major moons, may not necessarily have all of the moons of a planet
		Input: none
		Output: moonList[moonName<str>]
		"""
		return('%s' %', '.join(map(str, self.moonList)))

	def info(self):
			print("The planet "+self.getName()+" is "+str(self.getDistance())+
				"km to the sun and takes "+str(self.getOrbitalPeriod())+ 
				" Earth days to orbit the sun. "+str(self.getSpacecraftVisits())+" spacecrafts have visited. "+
				"Pluto's list of moons: "+str(self.getMoonList())+"\n")