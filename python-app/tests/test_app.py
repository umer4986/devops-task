import pytest
from flask import Flask
from app import app as flask_app

@pytest.fixture
def client():
    """Set up Flask test client and reset items list for each test."""
    flask_app.config['TESTING'] = True
    with flask_app.test_client() as client:
        # Reset the global items list before each test
        flask_app.items = []
        yield client

def test_index_empty(client):
    """Test the index route with no items."""
    response = client.get('/')
    assert response.status_code == 200
    assert b'No items' in response.data  # Assumes index.html shows 'No items' when empty

def test_index_with_items(client):
    """Test the index route with items."""
    flask_app.items = [{'id': 1, 'name': 'Item 1'}]
    response = client.get('/')
    assert response.status_code == 200
    assert b'Item 1' in response.data  # Assumes index.html renders item names

def test_add_item(client):
    """Test adding an item via POST."""
    response = client.post('/add', data={'name': 'Test Item'})
    assert response.status_code == 302  # Redirect to index
    assert len(flask_app.items) == 1
    assert flask_app.items[0] == {'id': 1, 'name': 'Test Item'}

def test_add_item_empty_name(client):
    """Test adding an item with empty name."""
    response = client.post('/add', data={'name': ''})
    assert response.status_code == 302  # Redirect to index
    assert len(flask_app.items) == 0  # No item added

def test_edit_item_get(client):
    """Test GET request to edit an item."""
    flask_app.items = [{'id': 1, 'name': 'Item 1'}]
    response = client.get('/edit/1')
    assert response.status_code == 200
    assert b'Item 1' in response.data  # Assumes edit.html renders item name

def test_edit_item_get_not_found(client):
    """Test GET request to edit a non-existent item."""
    response = client.get('/edit/1')
    assert response.status_code == 302  # Redirect to index
    assert len(flask_app.items) == 0

def test_edit_item_post(client):
    """Test POST request to update an item."""
    flask_app.items = [{'id': 1, 'name': 'Item 1'}]
    response = client.post('/edit/1', data={'name': 'Updated Item'})
    assert response.status_code == 302  # Redirect to index
    assert flask_app.items[0]['name'] == 'Updated Item'

def test_edit_item_post_empty_name(client):
    """Test POST request to edit with empty name."""
    flask_app.items = [{'id': 1, 'name': 'Item 1'}]
    response = client.post('/edit/1', data={'name': ''})
    assert response.status_code == 302  # Redirect to index
    assert flask_app.items[0]['name'] == 'Item 1'  # Name unchanged

def test_delete_item(client):
    """Test deleting an item."""
    flask_app.items = [{'id': 1, 'name': 'Item 1'}, {'id': 2, 'name': 'Item 2'}]
    response = client.get('/delete/1')
    assert response.status_code == 302  # Redirect to index
    assert len(flask_app.items) == 1
    assert flask_app.items[0] == {'id': 1, 'name': 'Item 2'}  # IDs reassigned

def test_delete_item_not_found(client):
    """Test deleting a non-existent item."""
    flask_app.items = [{'id': 1, 'name': 'Item 1'}]
    response = client.get('/delete/2')
    assert response.status_code == 302  # Redirect to index
    assert len(flask_app.items) == 1