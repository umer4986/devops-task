from flask import Flask, render_template, request, redirect, url_for

app = Flask(__name__)

# Simple in-memory "database" of items :
items = []


@app.route('/')
def index():
    return render_template('index.html', items=items)


@app.route('/add', methods=['POST'])
def add_item():
    name = request.form.get('name')
    if name:
        items.append({'id': len(items) + 1, 'name': name})
    return redirect(url_for('index'))


@app.route('/edit/<int:item_id>', methods=['GET', 'POST'])
def edit_item(item_id):
    item = next((item for item in items if item['id'] == item_id), None)
    if not item:
        return redirect(url_for('index'))

    if request.method == 'POST':
        name = request.form.get('name')
        if name:
            item['name'] = name
        return redirect(url_for('index'))

    return render_template('edit.html', item=item)


@app.route('/delete/<int:item_id>')
def delete_item(item_id):
    global items
    items = [item for item in items if item['id'] != item_id]
    # Reassign IDs
    for idx, item in enumerate(items):
        item['id'] = idx + 1
    return redirect(url_for('index'))


if __name__ == '__main__':
    app.run(host='0.0.0.0', debug=True)
