#!/usr/bin/env python3
from flask import Flask, render_template
#from dbconnect import connection

app = Flask(__name__)

@app.route("/")
@app.route("/index")
def hello_world():
	return render_template("test.html")

if __name__ == '__main__':
	app.run(debug=True)