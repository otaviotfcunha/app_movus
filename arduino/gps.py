import serial
import time
import pynmea2
import json
from datetime import datetime
import paho.mqtt.client as mqtt
import requests
import threading

# Configurações do servidor MQTT
MQTT_BROKER = "ankxklskxx2pm-ats.iot.us-east-2.amazonaws.com"
MQTT_PORT = 8883
MQTT_TOPIC = "onibus/localizacao"
MQTT_USERNAME = "movus"
MQTT_PASSWORD = "Movus@123"

# Configurações do Back4App
BACK4APP_APP_ID = '7i4omezzaD5fA2eaRtqy3VZKWKiXt93HKay9peBF'
BACK4APP_REST_API_KEY = 'byUxPUFdhua43SEHYRk2HlqSY8SsEvIGvOrm5AqK'
BACK4APP_API_ENDPOINT = 'https://parseapi.back4app.com/classes/Onibus'

# Configuração do cliente MQTT
mqtt_client = mqtt.Client()
mqtt_client.username_pw_set(MQTT_USERNAME, MQTT_PASSWORD)

# Função para conectar ao servidor MQTT
def connect_mqtt():
    try:
        mqtt_client.connect(MQTT_BROKER, MQTT_PORT, keepalive=60)
        print("Conectado ao servidor MQTT")
    except Exception as e:
        print(f"Erro ao conectar ao servidor MQTT: {e}")
        exit()

# Função para publicar dados no MQTT
def publish_to_mqtt(latitude, longitude, data, hora):
    payload = {
        'latitude': latitude,
        'longitude': longitude,
        'data': data,
        'hora': hora
    }
    try:
        mqtt_client.publish(MQTT_TOPIC, json.dumps(payload))
        print(f"Dados publicados no MQTT: {payload}")
    except Exception as e:
        print(f"Erro ao publicar no MQTT: {e}")

# Função para enviar dados para o Back4App
def send_data_to_back4app(latitude, longitude, data, hora):
    headers = {
        'X-Parse-Application-Id': BACK4APP_APP_ID,
        'X-Parse-REST-API-Key': BACK4APP_REST_API_KEY,
        'Content-Type': 'application/json'
    }
    data_payload = {
        'latitude': str(latitude),
        'longitude': str(longitude),
        'data': str(data),
        'hora': str(hora)
    }

    try:
        response = requests.post(BACK4APP_API_ENDPOINT, headers=headers, json=data_payload)
        response.raise_for_status()
        print("Dados enviados com sucesso para o Back4App!")
    except requests.exceptions.RequestException as e:
        print(f"Erro ao enviar para o Back4App: {e}")

# Função para processar os dados de um sensor
def process_sensor(port):
    ser = serial.Serial(port, baudrate=9600, timeout=0.5)
    dataout = pynmea2.NMEAStreamReader()

    while True:
        try:
            newdata = ser.readline().decode('utf-8')

            if newdata[0:6] == "$GPRMC":
                newmsg = pynmea2.parse(newdata)
                lat = newmsg.latitude
                lng = newmsg.longitude
                current_datetime = datetime.utcnow()
                date_str = current_datetime.strftime("%Y-%m-%d")
                time_str = current_datetime.strftime("%H:%M:%S")
                
                gps = f"Latitude={lat}, Longitude={lng}, Data={date_str}, Hora={time_str}"
                print(gps)
                
                # Enviar dados para o MQTT e Back4App
                publish_to_mqtt(lat, lng, date_str, time_str)
                send_data_to_back4app(lat, lng, date_str, time_str)
                
            time.sleep(1)
        except UnicodeDecodeError as e:
            print(f"Erro de decodificação: {e}")
            time.sleep(1)
            continue

# Função principal para gerenciar múltiplos sensores
def main():
    connect_mqtt()  # Conecta ao broker MQTT

    # Configuração de múltiplos sensores (adicionar portas conforme necessário)
    sensor_ports = ["/dev/ttyAMA0", "/dev/ttyAMA1"]  # Exemplo com duas portas

    # Criar threads para cada sensor
    threads = []
    for port in sensor_ports:
        thread = threading.Thread(target=process_sensor, args=(port,))
        threads.append(thread)
        thread.start()

    # Aguardar a conclusão das threads
    for thread in threads:
        thread.join()

if __name__ == "__main__":
    main()
