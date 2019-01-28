#!/usr/bin/env python3
# -*- coding: utf-8 -*-
from PyQt5.QtGui import *
from PyQt5.QtWidgets import *
from PyQt5.QtCore import *
from db import Database
from test import RecipeGenius
import sys
from multiprocessing import Process
from flask import Flask, render_template


class lilProcess(Process):
	def run(self):

		app = Flask(__name__)

		@app.route("/")
		@app.route("/index")
		def hello_world():
			self.webdb = Database(host="127.0.0.1", user="user", passwd="passpass", schema="project_test", port=3306)
			self.webdb.openDatabase()
			recipeMatches=self.webdb.matchRecipes()
			return render_template("website.html", recipeMatches=recipeMatches)
	
		@app.route("/match")
		def home():
			self.webdb = Database(host="127.0.0.1", user="user", passwd="passpass", schema="project_test", port=3306)
			self.webdb.openDatabase()
			matches=self.webdb.resultsTable()
			return render_template("dumb.html", matches=matches)
		
		@app.route("/fridge")
		def fridgeView():
			self.webdb = Database(host="127.0.0.1", user="user", passwd="passpass", schema="project_test", port=3306)
			self.webdb.openDatabase()
			fridgeStuff=self.webdb.showFridgeItems()
			return render_template("fridge.html", fridgeStuff=fridgeStuff)
		app.run(debug=False)
						
class App(QApplication):
	def __init__(self):
		QApplication.__init__(self, sys.argv)
		self.setApplicationName("Manager")
		self.mainWindow = MainWindow()
		self.mainWindow.show()

class MainWindow(QMainWindow):
	def __init__(self):
		QMainWindow.__init__(self)
		#self.setFixedSize(self.sizeHint())

		
		self.menu=self.menuBar()
		self.databaseMenu=self.menu.addMenu("Start")
		fill=QAction("Get recipes", self)
		#save.setShortcut("Ctrl+S")
		self.databaseMenu.addAction(fill)
		self.databaseMenu.triggered.connect(self.showConfirmationMsg)

		self.clear=self.menu.addMenu("Clear")
		clear=QAction("Clear Fridge", self)

		self.clear.addAction(clear)

		self.clear.triggered.connect(self.showMessage)


		self.mainWidget=MainWidget()

		self.setCentralWidget(self.mainWidget)

	def showMessage(self):
		self.reply=QMessageBox.question(self, 'Confirmation', "Are you sure you want to clear your fridge?", QMessageBox.Yes|QMessageBox.No, QMessageBox.No)
		if self.reply == QMessageBox.Yes:
			self.mainWidget.db.clearFridge()
		else:
			pass
	def showConfirmationMsg(self):
		self.confirm=QMessageBox.question(self, 'Confirmation', "Fill databases with recipes?", QMessageBox.Yes|QMessageBox.No, QMessageBox.No)
		if self.confirm == QMessageBox.Yes and self.mainWidget.db.checkEmpty==0:
			self.db.createFridgeTable()
			self.mainWidget.db.createGroceryList()
			self.db.createIngrTable()
			self.db.createRecipeIDTable()

			self.scraper.getInstructions(self.db)
			self.scraper.getIngredients(self.db)

			self.msg=QMessageBox()
			self.msg.setText("Database is ready!")
			self.msg.show()
		else:
			self.msg=QMessageBox()
			self.msg.setText("Database is ready!")
			self.msg.show()			



class MainWidget(QWidget):
	def __init__(self):
		QWidget.__init__(self)

		self.db = Database(host="127.0.0.1", user="user", passwd="passpass", schema="project_test", port=3306)
		self.db.openDatabase()
		#self.db.createFridgeTable()
		#self.db.createGroceryList()
		#self.db.createIngrTable()
		#self.db.createRecipeTable()
		#self.db.createInstrTable()
		#self.db.createRecipeIngrTable()
		#self.db.createRecipeTable()
		#self.db.createRecipeIDTable()
		self.scraper = RecipeGenius()
		#self.scraper.getInstructions(self.db)
		self.db.matchRecipes()

		#self.scraper.getIngredients(self.db)
		self.mainLayout=QVBoxLayout(self)
		
		self.fridgebtn = QPushButton("Add refrigerator item")
		self.fridgebtn.clicked.connect(self.getInput)
		
		self.grocerybtn = QPushButton("Add to grocery list")
		self.grocerybtn.clicked.connect(self.getGrocery)

		self.viewbtn = QPushButton("Find Your Recipe Matches")
		self.viewbtn.clicked.connect(self.openWeb)

		self.mainLayout.addWidget(self.fridgebtn)
		self.mainLayout.addWidget(self.grocerybtn)
		self.mainLayout.addWidget(self.viewbtn)
	
	def getInput(self):
		#self.db.createFridgeTable()
		self.item, okPressed=QInputDialog.getText(self, "Fridge", "Item name:", QLineEdit.Normal, "")
		#self.item=str(self.item)
		#print(type(self.item))
		#print(self.item)
		if okPressed and self.item!='':
			self.db.insertFridgeItems(self.item)

	def getGrocery(self):
		#self.db.createGroceryList()
		self.grocery, okPressed=QInputDialog.getText(self, "Grocery List", "Item name:", QLineEdit.Normal, "")
		if okPressed and self.grocery!='':
			self.db.insertGroceryItems(self.grocery)

	def openWeb(self):
		self.process = QProcess(self)
		self.process.startDetached("firefox http://127.0.0.1:5000/")

def main():
	#instance of process, which executes run method for opening and running the web server
	process=lilProcess()
	#spins up server for web
	process.start()
	#renders application gui
	app=App()
	#executes the app, opens web, return code is the exit code
	returnCode=app.exec_()
	#kill the web process when gui is closed
	process.terminate()
	#exit application with exit code
	sys.exit(returnCode)


if __name__ == '__main__':
	main()