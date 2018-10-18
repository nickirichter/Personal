#!/usr/bin/env python3
from PyQt5.QtGui import *
from PyQt5.QtWidgets import *
from PyQt5.QtCore import *
import sys

class App(QApplication):
	def __init__(self):
		QApplication.__init__(self, sys.argv)
		self.setApplicationName("Planner")
		self.mainWindow = MainWindow()
		self.mainWindow.show()

class MainWindow(QMainWindow):
	def __init__(self):
		QMainWindow.__init__(self)
		#self.setWindowTitle("Organize Yo Life")
		#self.setStyleSheet("QMainWindow {background-color: pink;}")
		self.menu=self.menuBar()
		self.file=self.menu.addMenu("File")
		save=QAction("Save", self)
		save.setShortcut("Ctrl+S")
		self.file.addAction(save)
		self.edit=self.menu.addMenu("Edit")
		#self.edit.addAction("Theme")
		self.mainWidget = MainWidget()
		self.setCentralWidget(self.mainWidget)

		self.color=QColor(125,120,0)
		self.dialog = self.edit.addAction("Theme")
		self.dialog2 = self.edit.addAction("Background")
		#self.dialog.setFixedSize(self.dialog.sizeHint())
		self.col=QColor(0,0,0)
		self.dialog.triggered.connect(self.showDialog)
		self.dialog2.triggered.connect(self.showBackground)
	
	def showDialog(self):
		self.col=QColorDialog.getColor()
		if(self.col.isValid()):
			self.mainWidget.reminderButton.setStyleSheet("background-color:%s" % self.col.name())
			self.mainWidget.deleteButton.setStyleSheet("background-color:%s" % self.col.name())
			self.mainWidget.listLabel.setStyleSheet("font: 12pt; color:%s" % self.col.name())
			self.mainWidget.weeklyAgenda.monLabel.setStyleSheet("font: 12pt; color:%s" % self.col.name())
			self.mainWidget.weeklyAgenda.tueLabel.setStyleSheet("font: 12pt; color:%s" % self.col.name())
			self.mainWidget.weeklyAgenda.wedLabel.setStyleSheet("font: 12pt; color:%s" % self.col.name())
			self.mainWidget.weeklyAgenda.thuLabel.setStyleSheet("font: 12pt; color:%s" % self.col.name())
			self.mainWidget.weeklyAgenda.friLabel.setStyleSheet("font: 12pt; color:%s" % self.col.name())
	def showBackground(self):
		self.col=QColorDialog.getColor()
		if(self.col.isValid()):
			self.setStyleSheet("QMainWindow{background-color: %s}" % self.col.name())
			self.menu.setStyleSheet("background-color: %s" % self.col.name())
			self.file.setStyleSheet("background-color: %s" % self.col.name())


class MainWidget(QWidget):
	def __init__(self):
		QWidget.__init__(self)

		self.outerLayout= QVBoxLayout(self)
		self.mainLayout = QHBoxLayout()
		self.todoButtonLayout = QHBoxLayout()
		self.listLayout = QVBoxLayout()
		self.calLayout = QHBoxLayout()
		#self.calLayout.addStretch(0)


		self.boldFont = QFont()
		self.boldFont.setBold(True)
		self.listLabel = QLabel("To Do List")
		self.listLabel.setStyleSheet("font: 12pt;")
		self.listLabel.setFont(self.boldFont)
		#self.listLabel.setStyleSheet("color: white;")

		#self.image = QLabel()
		#self.image.setStyleSheet("background-image: url(stars.jpeg);")
		#self.image.setScaledContents(True)
		
		#self.checklist = QTableWidget()
		#self.dialog = QPushButton("Change Button Colors")
		#self.dialog.setFixedSize(self.dialog.sizeHint())
		self.reminderButton = QPushButton("Add Task")
		self.reminderButton.setFont(self.boldFont)
		self.reminderButton.setFixedSize(self.reminderButton.sizeHint())
		#self.reminderButton.setStyleSheet("background: pink; color: black;")
		self.deleteButton = QPushButton("Remove Task")
		self.deleteButton.setFont(self.boldFont)

		self.deleteButton.setFixedSize(self.deleteButton.sizeHint())
		#self.deleteButton.setStyleSheet("background: pink; color: black;")


		self.checklist = ChecklistWidget()

		self.calWidget = RightDockWidget()


		self.weeklyAgenda = WeeklyAgenda()

		#self.imageWidget = BottomDockWidget()

		self.todoButtonLayout.addStretch(0)

		self.todoButtonLayout.addWidget(self.reminderButton, alignment=Qt.AlignRight)
		self.todoButtonLayout.addWidget(self.deleteButton, alignment=Qt.AlignRight)
		#self.todoButtonLayout.addWidget(self.dialog, alignment=Qt.AlignRight)

		self.listLayout.addWidget(self.listLabel, alignment=Qt.AlignCenter)
		self.listLayout.addWidget(self.checklist)
		#self.listLayout.addWidget(self.reminderButton, alignment=Qt.AlignRight)
		self.listLayout.addLayout(self.todoButtonLayout)
		#self.listLayout.addStretch(0)
		
		self.reminderButton.clicked.connect(self.addRow)
		self.deleteButton.clicked.connect(self.removeRow)

		self.calLayout.addWidget(self.calWidget)
		#self.calLayout.addWidget(self.buttonWidget)
		#self.calLayout.addWidget(self.imageWidget)

		#self.calLayout.addStretch(0)

	
		self.mainLayout.addLayout(self.listLayout)
		self.mainLayout.addLayout(self.calLayout)

		self.outerLayout.addLayout(self.mainLayout)
		self.outerLayout.addWidget(self.weeklyAgenda)



	def addRow(self):
		self.checklist.addEvent()

	def removeRow(self):
		self.checklist.removeEvent()
	'''
	def showDialog(self):
			self.col=QColorDialog.getColor()
			if(self.col.isValid()):
				self.deleteButton.setStyleSheet("background-color: %s" % self.col.name())
				self.reminderButton.setStyleSheet("background-color: %s" % self.col.name())
	'''

class RightDockWidget(QWidget):
	def __init__(self):
		QWidget.__init__(self)
		self.checkLayout = QHBoxLayout()
		self.table = QTableWidget(self)

		self.table.verticalHeader().setVisible(False)
		self.table.verticalHeader().setStretchLastSection(True)

		self.table.horizontalHeader().setVisible(False)
		self.table.horizontalHeader().setStretchLastSection(True)
		self.table.setShowGrid(False)
		#self.table.horizontalHeader().setSectionResizeMode(0, Qt.Widgets.QHeaderView.Stretch)

		nRows=8
		nCols=6
		self.table.setColumnCount(nCols)
		self.table.setRowCount(nRows)
		for col in range(nCols):
			for row in range(nRows):
				self.table.setCellWidget(row,col,QTextEdit())
		self.checkLayout.addWidget(self.table)
		#self.checkLayout.addStretch(0)

		self.setLayout(self.checkLayout)
		self.show()



		

class PlannerWidget(QWidget):
	def __init__(self):
		QWidget.__init__(self)
		self.plannerLayout = QHBoxLayout(self)
		self.priorityLayout = QHBoxLayout()

		self.checkBox = QCheckBox()
		self.reminder = QLineEdit()

		self.priority1 = QRadioButton("!")
		self.priority1.setChecked(False)

		self.priority1.setFixedSize(self.priority1.sizeHint())

		self.checkBox.setChecked(False)
		self.checkBox.stateChanged.connect(self.btnstate)

		self.plannerLayout.setContentsMargins(0,0,0,0)
		
		self.plannerLayout.addWidget(self.checkBox)

		self.plannerLayout.addWidget(self.reminder)
		self.plannerLayout.addWidget(self.priority1, alignment=Qt.AlignRight)


		self.priority1.toggled.connect(self.prioritize)

		self.setLayout(self.plannerLayout)

	
	def btnstate(self):
		if self.checkBox.isChecked()==True:
			self.f=self.reminder.font()
			self.f.setStrikeOut(True)
			self.reminder.setFont(self.f)
		else:
			self.f=self.reminder.font()
			self.f.setStrikeOut(False)
			self.reminder.setFont(self.f)
	
	def prioritize(self):
		if(self.priority1.isChecked()==True):
			self.reminder.setStyleSheet("color: rgb(255, 0, 0);")
		if(self.priority1.isChecked()==False):
			self.reminder.setStyleSheet("color: rgb(0,0,0)")
	

class ChecklistWidget(QWidget):
	def __init__(self):
		QWidget.__init__(self)
		self.checkLayout = QVBoxLayout()
		self.table = QTableWidget(self)

		self.table.verticalHeader().setVisible(False)
		self.table.horizontalHeader().setVisible(False)
		self.table.horizontalHeader().setStretchLastSection(True)
		self.table.setShowGrid(False)

		nRows=10
		self.table.setRowCount(nRows)
		self.table.setColumnCount(1)
		for row in range(nRows):
			self.table.setCellWidget(row,0,PlannerWidget())
		self.checkLayout.addWidget(self.table)
		#self.checkLayout.addStretch(0)

		self.setLayout(self.checkLayout)
		self.show()
	
	def addEvent(self):
		self.planner = PlannerWidget()
		self.table.insertRow(0)
		self.table.setCellWidget(0,0,self.planner)

	def removeEvent(self):
		currentRow=self.table.currentRow()
		self.table.removeRow(currentRow)

class WeeklyAgenda(QWidget):
	def __init__(self):
		QWidget.__init__(self)
		self.outerLayout = QVBoxLayout()
		self.weekLayout = QHBoxLayout()
		self.monLayout = QVBoxLayout()
		self.tueLayout = QVBoxLayout()
		self.wedLayout = QVBoxLayout()
		self.thuLayout = QVBoxLayout()
		self.friLayout = QVBoxLayout()


		self.mon = QTextEdit(self)
		self.tue = QTextEdit(self)
		self.wed = QTextEdit(self)
		self.thu = QTextEdit(self)
		self.fri = QTextEdit(self)

		self.monLabel = QLabel("Monday")
		self.monLabel.setStyleSheet("font: 12pt;")
		self.tueLabel = QLabel("Tuesday")
		self.tueLabel.setStyleSheet("font: 12pt;")
		self.wedLabel = QLabel("Wednesday")
		self.wedLabel.setStyleSheet("font: 12pt;")
		self.thuLabel = QLabel("Thursday")
		self.thuLabel.setStyleSheet("font: 12pt;")
		self.friLabel = QLabel("Friday")
		self.friLabel.setStyleSheet("font: 12pt;")



		self.monLayout.addWidget(self.monLabel, alignment=Qt.AlignLeft)
		self.monLayout.addWidget(self.mon)
		self.tueLayout.addWidget(self.tueLabel, alignment=Qt.AlignLeft)
		self.tueLayout.addWidget(self.tue)
		self.wedLayout.addWidget(self.wedLabel, alignment=Qt.AlignLeft)
		self.wedLayout.addWidget(self.wed)
		self.thuLayout.addWidget(self.thuLabel, alignment=Qt.AlignLeft)
		self.thuLayout.addWidget(self.thu)
		self.friLayout.addWidget(self.friLabel, alignment=Qt.AlignLeft)
		self.friLayout.addWidget(self.fri)

		self.weekLayout.addLayout(self.monLayout)
		self.weekLayout.addLayout(self.tueLayout)
		self.weekLayout.addLayout(self.wedLayout)
		self.weekLayout.addLayout(self.thuLayout)
		self.weekLayout.addLayout(self.friLayout)
		#self.weekLayout.addStretch(0)
		self.outerLayout.addLayout(self.weekLayout)
		#self.outerLayout.addWidget(self.dialog, alignment=Qt.AlignRight)


		self.setLayout(self.outerLayout)
		self.show()
	'''
	def showDialog(self):
			self.col=QColorDialog.getColor()
			if(self.col.isValid()):
				self.monLabel.setStyleSheet("font: 12pt; color: %s" % self.col.name())
				self.tueLabel.setStyleSheet("font: 12pt; color: %s" % self.col.name())
				self.wedLabel.setStyleSheet("font: 12pt; color: %s" % self.col.name())
				self.thuLabel.setStyleSheet("font: 12pt; color: %s" % self.col.name())
				self.friLabel.setStyleSheet("font: 12pt; color: %s" % self.col.name())
	'''



def main():
	app=App()
	sys.exit(app.exec_())

if __name__ == '__main__':
	main()