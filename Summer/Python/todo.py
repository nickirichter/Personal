import sys
from PyQt5.QtCore import *
from PyQt5.QtGui import *
from PyQt5.QtWidgets import *

class App(QApplication):
    """This is a main application.
       
       Input:  command line arguments <list>
       Output: None
    """

    def __init__(self):
        # Initialize the parent widget
        QApplication.__init__(self, sys.argv)

        # Set the application name
        self.setApplicationName("Organize Yo Life")

        # Create the main window
        self.mainWindow = MainWindow()

        # Show the main window
        self.mainWindow.show()


class MainWindow(QMainWindow):
    """This is the main GUI window.  This is what contains all the QWidgets seen in the application."""

    def __init__(self):
        """Initialize the main window.
           
           Input:  None
           Output: None
        """
        # Initialize the parent widget
        QMainWindow.__init__(self)

        # Initialize this window
        self.setWindowTitle("Organize Yo Life")

        #self.bar=menuBar()

        # Set the size of the main window (uncomment to play with the starting window size)
        #self.resize(220, 240)

        # Create a main widget object (the central widget)
        self.mainWidget = QCalendarWidget()

        #  Set the main widget object as the central widget of the main window
        self.setCentralWidget(self.mainWidget)

        self.items = QDockWidget("To Do List")
        self.listWidget = QListWidget()
        
		
class MainWidget(QWidget):
   def __init__(self):
      QWidget.__init__(self)

      self.mainLayout = QHBoxLayout(self)
      #file = bar.addMenu("Calendar")

     # self.items = QDockWidget("To Do List")
      
      self.listWidget.addItem(input())
      self.listWidget.addItem(input())
      self.listWidget.addItem(input())

      
      self.items.setFloating(False)
      #self.setCentralWidget(QCalendarWidget())
      self.addDockWidget(Qt.RightDockWidgetArea, self.items)
      self.items.setWidget(self.listWidget)

def main():
   app = App()
   sys.exit(app.exec_())
   #ex = dockdemo()
   #ex.show()
   #sys.exit(app.exec_())
	
if __name__ == '__main__':
   main()