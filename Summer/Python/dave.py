#!/usr/bin/env python3

from PyQt5.QtGui import *
from PyQt5.QtWidgets import *
from PyQt5.QtCore import *
import sys


class App(QApplication):
    """This is a main application.
       
       Input:  command line arguments <list>
       Output: None
    """

    def __init__(self):
        # Initialize the parent widget
        QApplication.__init__(self, sys.argv)

        # Set the application name
        self.setApplicationName("Hello World GUI")

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
        self.setWindowTitle("Hello World GUI")

        # Set the size of the main window (uncomment to play with the starting window size)
        # self.resize(320, 240)

        # Create a main widget object (the central widget)
        self.mainWidget = MainWidget()

        #  Set the main widget object as the central widget of the main window
        self.setCentralWidget(self.mainWidget)


class MainWidget(QWidget):
    """This is the central widget.  It contains the buttons and layouts."""

    def __init__(self):
        QWidget.__init__(self)

        # Create the main layout and button layout
        self.mainLayout = QVBoxLayout(self)
        self.buttonLayout = QHBoxLayout()

        # Create a bold font
        self.boldFont = QFont()
        self.boldFont.setBold(True)

        # Create a label (just some text). This is one way we can add text to our widget.
        # The second line overwrites the default font with the one we have created above.
        self.textLabel = QLabel("I want to change the world, but they won't give me the source code.")
        self.textLabel.setFont(self.boldFont)

        # Create the push buttons
        self.onePushButton = QPushButton("One")
        self.twoPushButton = QPushButton("Two")
        self.threePushButton = QPushButton("Three")
        self.closePushButton = QPushButton("Close")

        # Add buttons one and two to the button layout
        self.buttonLayout.addWidget(self.onePushButton)
        self.buttonLayout.addWidget(self.twoPushButton)

        # Add the label, button layout, button three,
        # and the close button to the main layout.
        self.mainLayout.addWidget(self.textLabel, alignment=Qt.AlignCenter)
        self.mainLayout.addStretch(0)
        self.mainLayout.addLayout(self.buttonLayout)
        self.mainLayout.addWidget(self.threePushButton)
        self.mainLayout.addStretch(0)
        self.mainLayout.addWidget(self.closePushButton, alignment=Qt.AlignRight)


def main():
    """This is the main function. It runs when this script is called from the command line."""
    # Create the application
    app = App()

    # Start the application event loop
    sys.exit(app.exec_())


if (__name__ == "__main__"):
    main()
