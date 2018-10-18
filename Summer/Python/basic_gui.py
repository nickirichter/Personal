import sys
from PyQt5.QtCore import *
from PyQt5.QtGui import *

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

        # Set the size of the main window (uncomment to play with the starting window size)
        # self.resize(320, 240)

        # Create a main widget object (the central widget)
        self.mainWidget = MainWidget()

        #  Set the main widget object as the central widget of the main window
        self.setCentralWidget(self.mainWidget)

       

class dockdemo(QMainWindow):
   def __init__(self, parent = None):
      super(dockdemo, self).__init__(parent)
		
      layout = QHBoxLayout()
      bar = self.menuBar()
      file = bar.addMenu("File")
      file.addAction("New")
      file.addAction("save")
      file.addAction("quit")
		
      self.items = QDockWidget("Dockable", self)
      self.listWidget = QListWidget()
      self.listWidget.addItem("item1")
      self.listWidget.addItem("item2")
      self.listWidget.addItem("item3")
		
      self.items.setWidget(self.listWidget)
      self.items.setFloating(False)
      self.setCentralWidget(QTextEdit())
      self.addDockWidget(Qt.RightDockWidgetArea, self.items)
      self.setLayout(layout)
      self.setWindowTitle("Dock demo")
		
def main():
   #app = QApplication(sys.argv)
   #sys.exit(app.exec_())
   ex = dockdemo()
   ex.show()
   sys.exit(app.exec_())
	
if __name__ == '__main__':
   main()