#!/usr/bin/env python3
import requests
import os
import re
import glob
import itertools
import urllib.request
from glob import iglob
from pathlib import Path
from bs4 import BeautifulSoup

class RecipeGenius:
	def __init__(self):
		#self.db=Database()
		self.nonIngredientWords={r'\W+',"minced", "chopped", "recommended", "frozen", "large", "small", 
		"medium", "large", "diced", "grated", "divided", "cups", "cup", "melted",
		"tablespoons", "tbsp", "tsp", "teaspoon", "teaspoons", "tablespoon", "for", "separated", "frying", "1/8", "1/6", "1/4", "1/2", "1/3", "2/3", "3/4", "1", "2","oz", "16", "8","4","&", "10", "1.25", "12", "3", "6","pounds", "as", "needed", "processed", "topping", "pound", "ounces", "garnish", "cocktail", "fresh", "slices", "about", "shredded", "to", "40", "of", "cloves", "thick", "shot", "or", "per", "peeled", "deveined", "24", "freshly", "pinches", "pinch", "20", "and", "crusty", "recipe", "follows", "coarsely", "torn", "finely", "plus", "thin", "thinly", "finely", "juiced", "whole-wheat", "undrained", "drained", "can", "each", "14.5", "in", "each", "original", "pkg", "stalks", "bunch", "bunches", "coarse", "dry", "into", "cut", "bite", "sized", "trimmed", "well", "removed", "casings", "cracked", "away", "from", "5", "one", "preferably", "two", "unsalted", "these", "be", "bought", "markets", "ground", "dried", "roughly", "tablespoon-size", "intact", "etc", "container", "kosher", "halved", "clean", "wiped", "sliced", "all-purpose", "good-quality", "shaved", "washed", "spun", "good", "scrubbed", "light", "see", "below", "homemade", "store-bought", "pieces", "dice", "seeded", "canned", "bite-sized", "tender", "very", "ripe", "thickly", "lb", "strips", "optional", "36", "couple", "a", "the", "spoon", "shape", "cubes", "brewed", "room", "smoked", "80%", ""}
		self.rootdir="/home/niri0478/Desktop/Project/www.foodnetwork.com"

	def writeFile(filename, imageURL):
		with open(filename, mode="a") as WRITE_FILE:
			if imageURL=="https://food.fnr.sndimg.com/content/dam/images/food/editorial/homepage/fn-feature.jpg.rend.hgtvcom.616.347.suffix/1474463768097.jpeg":
				pass
			else:
				WRITE_FILE.write(imageURL+'\n')

	def getRecipeTitle(self, filename):
		#way to loop through all files with the html extension
		for file_name in glob.glob(os.path.join(self.rootdir, "*.html")):
			with open(file_name) as html_file:
				soup=BeautifulSoup(html_file, "lxml")
				head=soup.find(class_="o-AssetTitle__a-HeadlineText")
				title=head.text
				print(title)
		return(0)
	
	def getIngredients(self, database):
		recipeIngredientLists=[]
		#way to loop through all files with the html extension
		for file_name in glob.glob(os.path.join(self.rootdir, "*.html")):
			with open(file_name) as html_file:
				ingredientList=[]
				soup=BeautifulSoup(html_file, "lxml")
				for ingr in list(soup.find_all(class_="o-Ingredients__a-ListItemText")):
					item=ingr.text
					for word in item.split():
						word=word.lower().strip(":\"';(),*.#-")
						if word not in self.nonIngredientWords:
							ingredientList.append(word)
							database.insertIngredients(word)
		return(recipeIngredientLists)

	def getInstructions(self, database):
		instructionList=[]
		for file_name in glob.glob(os.path.join(self.rootdir, "*.html")):
			with open(file_name) as html_file:
				soup=BeautifulSoup(html_file, "lxml")
				instr=soup.find(class_= "o-Method__m-Body")
				if instr is not None:
					instruction=instr.text
					database.insertInstr(instruction)
				head=soup.find(class_="o-AssetTitle__a-HeadlineText")
				title=head.text
		return(0)

	def getRecipeImage(self, filename):
		for file_name in glob.glob(os.path.join(self.rootdir, "*.html")):
			with open(file_name) as html_file:
				soup=BeautifulSoup(html_file, "lxml")
				try:
					img_url=soup.find("meta", {"property":"og:image"})['content']
					writeFile(filename, img_url)
				except TypeError:
					pass



		
