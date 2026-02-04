# Example Flask testing infrastructure
import pytest
from app import create_app

@pytest.fixture
def client():
    """Create a Flask test client"""
    app = create_app()
    app.config["TESTING"] = True
    with app.test_client() as client:
        yield client

def test_health(client):
    """Simple GET /health endpoint"""
    response = client.get("/health")
    assert response.status_code == 200
    json_data = response.get_json()
    assert "status" in json_data
    assert json_data["status"] == "ok"

def test_root(client):
    """GET / renders index.html"""
    response = client.get("/")
    assert response.status_code == 200
    # optional: check for some text in the template
    assert b"Flask app is running" in response.data

