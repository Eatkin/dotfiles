import os

from flask import render_template

from app import create_app

app = create_app()

@app.get("/")
def root():
    return render_template("index.html")

if __name__ == "__main__":
    app.run(
        host="0.0.0.0",
        port=int(os.environ.get("PORT", 5000)),
        debug=True,
    )
