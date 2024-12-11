from flask import Flask, render_template
from flask_socketio import SocketIO
import json

app = Flask(__name__)
socketio = SocketIO(app)

@app.route('/localizacao')
def show_location():
    try:
        with open('last_location.json', 'r') as json_file:
            data = json.load(json_file)
            latitude = data.get('latitude', 'N/A')
            longitude = data.get('longitude', 'N/A')
            data_str = data.get('data', 'N/A')
            hora_str = data.get('hora', 'N/A')
    except Exception as e:
        return f"Erro ao ler o arquivo JSON: {str(e)}", 500

    return render_template('location.html', latitude=latitude, longitude=longitude, data=data_str, hora=hora_str)

@socketio.on('connect')
def handle_connect():
    print('Cliente conectado')

@socketio.on('disconnect')
def handle_disconnect():
    print('Cliente desconectado')

if __name__ == "__main__":
    socketio.run(app, host='0.0.0.0', port=80, debug=True)
