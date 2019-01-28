#!/usr/bin/env python3
import pymysql

class Database(object):
	def __init__(self, host="some_db_server", user="", passwd="", schema="", port=3306):
		self.host = host
		self.schema = schema
		self.user = user
		self.passwd = passwd
		self.port = port
		
		#tables in database
		self.fridgeTable = "fridge_table"
		#self.recipeTable = "recipe_table"
		self.ingrIDTable = "ingredientID_table"
		self.groceryTable = "grocery_table"
		#self.recipes = "recipes"
		self.recipeIDTable = "recipeID_table"
		#self.recipeIngrTable="recipe_ingredient_table"

		#connection to database
		self.dbConnection = None

		#cursor for database connection
		self.cursor = None

	def openDatabase(self):
		self.dbConnection = pymysql.connect(self.host, self.user, self.passwd, self.schema, self.port)
		self.cursor=self.dbConnection.cursor()

	def executeStatement(self,sql,variables):
		if (self.dbConnection is not None and self.cursor is not None):
			try:
				#print("yes")
				self.cursor.execute(sql, variables)
				self.dbConnection.commit()
			except Exception as error:
				#print("nope")
				pass

	def checkEmpty(self):
		sql = "SELECT COUNT(*) FROM " + self.groceryTable 
		self.executeStatement(sql, variables=[])

	def createIngrTable(self):
		#sql to create a table
		sql = "CREATE TABLE IF NOT EXISTS ingredientID_table(itemID INT AUTO_INCREMENT, item VARCHAR(80) UNIQUE NOT NULL, PRIMARY KEY (itemID))"
		self.executeStatement(sql, variables=[])

	def insertIngredients(self, ingredient):
	 	sql = "INSERT INTO " + self.ingrIDTable + " (item) "
	 	sql += "VALUES (%s)"

	 	variables=[ingredient]
	 	self.executeStatement(sql, variables)

	def clearFridge(self):
		sql = "TRUNCATE TABLE fridge_table"
		variables = []
		self.executeStatement(sql, variables)


	def createFridgeTable(self):
		sql = "CREATE TABLE IF NOT EXISTS fridge_table(food VARCHAR(80) NOT NULL)"
		variables=[]
		self.executeStatement(sql, variables)


	def insertFridgeItems(self, fridgeItem):
		sql = "INSERT INTO " + self.fridgeTable + " (food) "
		sql+= "VALUES (%s)"

		variables = [fridgeItem]
		self.executeStatement(sql, variables)

	def showFridgeItems(self):
		sql = "SELECT * FROM fridge_table"
		self.executeStatement(sql, variables=[])
		fridgeStuff=self.cursor.fetchall()
		return(fridgeStuff)

	def createGroceryList(self):
		sql = "CREATE TABLE IF NOT EXISTS grocery_table (item VARCHAR (80) NOT NULL)"
		variables=[]
		self.executeStatement(sql, variables)

	def insertGroceryItems(self, groceryItem):
		sql = "INSERT INTO " + self.groceryTable + " (item) "
		sql += "VALUES (?)"

		variables = [groceryItem]
		self.executeStatement(sql, variables)

	#finds matched fridge items to ingredients in the ingredientID table
	def resultsTable(self):
		sql = "SELECT * FROM grocery_table"
		self.executeStatement(sql, variables=[])
		matches=self.cursor.fetchall()
		#print(matches)
		return(matches)
	
	def createRecipeIDTable(self):
		sql = "CREATE TABLE IF NOT EXISTS recipeID_table(recipeID INT AUTO_INCREMENT, instruction VARCHAR (500), PRIMARY KEY (recipeID))"
		self.executeStatement(sql, variables=[])


	def insertInstr(self, instr):
		sql = "INSERT INTO " + self.recipeIDTable + " (instruction) "
		sql+= "VALUES (%s)"
		variables = [instr]
		self.executeStatement(sql, variables)

	def matchRecipes(self):
		
		sql = "CREATE VIEW resultTable AS SELECT t1.itemID, t2. recipeID FROM ingredientID_table t1, recipeID_table t2 WHERE t2.instruction LIKE CONCAT ( '%', t1.itemID, '%') "
		sql += "CREATE VIEW matchIngredient AS SELECT item, itemID FROM ingredientID_table INNER JOIN fridge_table ON ingredientID_table.item=fridge_table.food"
		sql += "CREATE VIEW matchRecipe AS SELECT recipeID FROM resultTable INNER JOIN matchIngredient ON resultTable.itemID=matchIngredient.itemID"
		
		sql = "SELECT DISTINCT instruction FROM recipeID_table INNER JOIN matchRecipe ON recipeID_table.recipeID=matchRecipe.recipeID"
		self.executeStatement(sql, variables=[])
		recipeMatches=self.cursor.fetchall()
		return(recipeMatches)
	'''
	def createRecipeTable(self):
		sql= "CREATE TABLE IF NOT EXISTS recipes(ingredients VARCHAR(500) NOT NULL, instructions VARCHAR(500) NOT NULL)"
		self.executeStatement(sql, variables=[])
	
	def insertRecipeInfo(self, ingrs, instrs):
		sql = "INSERT INTO " + self.recipes + " (ingredients, instructions)"
		sql+= "VALUES (%s, %s)"
		variables = [ingrs, instrs]
		self.executeStatement(sql, variables)
	'''