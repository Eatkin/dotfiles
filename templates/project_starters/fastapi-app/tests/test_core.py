# Example test client usage
import pytest
from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)

def test_health():
    """Simple GET /health endpoint"""
    response = client.get("/health")
    assert response.status_code == 200
    json_data = response.json()
    assert "status" in json_data
    assert json_data["status"] == "ok"

def test_placeholder():
    """GET /placeholder returns example model"""
    response = client.get("/placeholder")
    assert response.status_code == 200
    data = response.json()
    assert "id" in data
    assert "name" in data
    assert "description" in data

