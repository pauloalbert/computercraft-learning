from flask import Flask, request
from markupsafe import escape

app = Flask(__name__)

@app.route("/")
def hello_world():
    return "<p>Hello, World!</p>"

@app.post("/input")
def input_tps():
    return f"<p>{escape(request.form['pofi'])} </p>"