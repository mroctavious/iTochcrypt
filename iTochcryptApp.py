#!iTochcrypt/bin/python
##Json Libraries
import json
from json import dumps

##For modular inverse matrix
from sympy import Matrix, pprint
from random import randint

##For REST server service
from flask import Flask, jsonify, request
from flask_restful import Resource, Api
from flask_httpauth import HTTPBasicAuth

##SQL libraries For MYSQL connection
import pymysql

#MOD = 61208
MOD = 60772

MASTERKEY = Matrix(3,3,[17, 17, 5, 21, 18, 21, 2, 2, 19])
##Get MCD function
def mcd(a, b):
	resto = 0
	while(b > 0):
		resto = b
		b = a % b
		a = resto
	return a


##Create a random square matrix compatible with HC
def randomMatrixKey( size, modulus ):
	key = [];
	for i in range(0, size*size ):
		key.append(randint(0, modulus-1));
	Key = Matrix( size, size, key );
	if mcd( Key.det(), modulus ) == 1:
		return Key;
	else:
		return randomMatrixKey( size, modulus );


##Funciones que cargan los diccionarios iniciales
def loadDictionaryPosVal():
	with open('iTochcrypt/PositionValues.json') as data_file:
		data = json.load(data_file);
	return data;

##Diccionario invertido
def loadDictionaryValPos(posValueDicc):
	myDict =  { str(posValue):int(key) for (key,posValue) in posValueDicc.items()};

##Iniciamos la aplicacion Flask, nos ayudara hacer un servidor REST
app = Flask(__name__)
api = Api(app)

##Para que puedan iniciar sesion
auth = HTTPBasicAuth()


##Cargar diccionario inicial
posVal=loadDictionaryPosVal();
valPos=loadDictionaryValPos(posVal);


##Contrasena maestra del servidor http
@auth.get_password
def getPassword( username ):
	if username == 'iTochcryptIOS':
		return 'masterPasswdUAQ';
	return None;


@auth.error_handler
def unauthorized():
	return jsonify({'error': 'Unauthorized access'});

##########################CLASES####################################
##Clase para conexion y ejecucion de queries
class iTochcryptDB:
	db = pymysql.connect("localhost", "iTochcryptDev", "Tochpan", "iTochcrypt", 1305, cursorclass=pymysql.cursors.DictCursor);
	def insertToDB(self, query):
		try:
			# Execute the SQL command
			cursor = self.db.cursor();
			cursor.execute(query)

			# Commit your changes in the database
			self.db.commit()

			# Return the inserted id
			return cursor.lastrowid;

		except:
			# Rollback in case there is any error
			self.db.rollback()
			return 0;

	def getSelect(self, query):
		cursor = self.db.cursor();
		cursor.execute(query)
		resultSet = cursor.fetchall()
		print( len(resultSet) )
		return resultSet;

	def createUser( self, username, passwd, name, lastName ):
		queryString = "INSERT INTO it_users( username, passwd, name, lastName, lastLogin ) VALUES ( '%s', MD5('%s'), '%s', '%s', NOW() ); " % (username, passwd, name, lastName);
		return self.insertToDB(queryString);

	def getStringKey( self, matrix, size ):
		string = "" + str(matrix[0]);
		for i in range(1, size ):
			string += "|"
			string += str(matrix[i])
		return string

	def createFullUser( self, username, passwd, name, lastName, keySize, modulus ):
		##Creamos usuario y conseguimos su id
		id = self.createUser( username, passwd, name, lastName );

		##Diccionario vacia que guardara los datos del usuario para regresar como json
		myDictUser = dict();
		if id > 0:
			##Returnable json
			myDictUser[ "id" ] = id
			myDictUser[ "username" ] = username
			myDictUser[ "keySize" ] = keySize*keySize
			myDictUser[ "key" ] = self.createKey( keySize*keySize, modulus);

			##Armamos el query, se agregara llave a la tabla
			queryStr = "INSERT INTO it_keys( size, keyString, modulus ) VALUES( %d, '%s', %d);" % (myDictUser[ "keySize" ], myDictUser[ "key" ], modulus );

			##id de la llave insertada
			idKey = self.insertToDB(queryStr);

			##Guardar llave en el historial
			queryStr="INSERT INTO it_keyHistory( idKey, initDate, endDate ) VALUES( %d, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY) );" % (idKey)
			idHistKey = self.insertToDB(queryStr);

			##Actualizar llave para el usuario
			queryStr="UPDATE it_users SET currentKey = %d WHERE id = %d;" % ( idHistKey, id );
			self.insertToDB(queryStr);

		return myDictUser;

	##Create random key
	def createKey(self, size, modulus):
		matrix = randomMatrixKey(size, modulus);
		return self.getStringKey(matrix, size );

	def closeDB():
		self.db.close()


##Clase HCText, ofrece los metodos para que se ingrese un string
##y lo regrese encriptado o decriptado
class HCText:

	def __init__(self, key, size = 3, modulus = 256):
		self.key = key;
		self.size = size;
		self.modulus = modulus;

	def getIntegerList( self, string ):
		fullMatrix=[];
		steps = 0;

		##Verificar si la division es exacta, y calcular pasos que se deben hacer
		if len(string) % self.size == 0:
			steps=len(string)/self.size;
		else:
			steps=(len(string)/self.size) + 1;

		##Recorremos todas las letras
		for i in range(0, steps):

			##Creamos matrix con espacios
			matrix = []
			##Agregamos espacios a la lista vacia
			for q in range(0, self.size):
				matrix.append(32);

			##Recorremos un cacho del string y guardamos su valor entero
			for s in range(0, self.size ):
				strIndex=(i*self.size)+s

				##En caso de que se salga del indice
				if( strIndex >= len(string) ):
					break;

				##De lo contrario almacenar entero
				matrix[s] = ord(string[strIndex]);

			##Agregamos a la matris principal
			fullMatrix.append(matrix);

		return fullMatrix;

	##Dada un arreglo de enteros, lo convierte en texto
	def intToChar(self, matrix):
		str="";
		for i in matrix:
			for j in i:
				str = str + chr(j)
		return str;

	##Aplicar llave a las palabras
	def applyKey(self, matrixWords, key=None):
		if key == None:
			key = self.key;
		##Funcion lambda que solo aplica modula a una matrix
		fMod = lambda x: x % self.modulus

		##Frase completa
		phrase = []

		##Recorremos todas las palabras de tamano de la llave
		for i in range(0, len(matrixWords)):
			sublist = []
			##Creamos Matrix para la multilplicacion a partir de de sub matrices
			word = Matrix(self.size, 1, matrixWords[i]);

			##Multiplicamos y aplicamos el modulo
			wordWithKey = (key * word).applyfunc(fMod);

			##Recorremos numeros y agregamos a la sublista,para poder agregarla a la lista final
			for i in range( 0, self.size ):
				sublist.append(wordWithKey[i])

			##Agregamos a la lista final
			phrase.append(sublist);
		return phrase;

	##Simplifica las funciones en esta clase, solo hay que llamarla con 1 string
	def encrypt(self, string):
		ints=self.getIntegerList(string);
		apl=self.applyKey(ints);
		return self.intToChar(apl);

	def decrypt(self, string):
		ints=self.getIntegerList(string);
		apl=self.applyKey(ints, key=self.key.inv_mod(self.modulus));
		return self.intToChar(apl);


##################Recursos flask####################

##Iniciamos conexion a la base de datos
tcDB=iTochcryptDB();

##Para conseguir diccionario Posicion:Valor
class dictionaryPosVal(Resource):
	@auth.login_required
	def get(self):
		return posVal;

##Para conseguir diccionario Valor:Posicion
class dictionaryValPos(Resource):
	@auth.login_required
	def get(self):
		return valPos;

class Users(Resource):
	@auth.login_required
	def get(self):
		return jsonify({'users':users })

class User(Resource):
	##Conseguir el diccionario que sea el mismo ID
	@auth.login_required
	def get( self, id ):
		##Se consigue toda la informacion del usuario y lo transformamos en un json
		result=tcDB.getSelect("SELECT * FROM it_users WHERE id = %d;" % (int(id)))

		##Limpiando el diccionario
		myDict =  { key:value for (key,value) in result[0].items()};
		return jsonify(myDict)

class getMessage(Resource):
	##Conseguir mensajes que sea el mismo ID
	@auth.login_required
	def get( self, id ):
		##Se consigue toda la informacion del usuario y lo transformamos en un json
		result=tcDB.getSelect("SELECT * FROM it_messages WHERE idUserSender = %d;" % (int(id)))

		##Limpiando el diccionario
		myDict =  { key:value for (key,value) in result[0].items()};
		return jsonify(myDict)


##Clase Mensaje, aqui se reciviran los mensaje enviados desde el cliente y los guarda en el servidor
class Message(Resource):

	@auth.login_required
	def post(self):
		##Instanceamos del objeto HC
		hcObject = HCText( key=randomMatrixKey(3, 256), modulus=256 );

		##Identificador del usuario emisor
		userId = request.json['id']

		##Indentificador del usuario destino
		userDest = request.json['idDest']

		##Indentificador de la llave
		keyId = request.json['idKey']

		##Mensaje
		message = request.json['message']

		##Encriptando el mensaje
		message = hcObject.encrypt(message);
		query = "INSERT INTO it_messages( idKey, message, idUserReceiver, idUserSender) VALUES( %d, '%s', %d, %d )" % (int(keyId), message, int(userId), int(userDest));

		##Agregar a la base de datos
		print(tcDB.insertToDB(query));


class getKey(Resource):
	##Consigue llave del usuario
	def get(self, id):

		##Se consigue toda la informacion del usuario y lo transformamos en un json
		result=tcDB.getSelect("SELECT size, modulus, keyString FROM it_keys WHERE id = (SELECT currentKey FROM it_users WHERE id=%d );" % (int(id)))

		##Limpiando el diccionario
		myDict =  { key:value for (key,value) in result[0].items()};
		return jsonify(myDict)

def getUsers():
	return jsonify({'users':users })

def index():
    return "Hello, World!"



##############################################################
##Anadimos ruta al servidor web
api.add_resource( Users, '/users/all' )
api.add_resource( dictionaryPosVal, '/config/posVal' )
api.add_resource( dictionaryValPos, '/config/valPos' )

##Informacion del usuario
api.add_resource( User, '/users/<id>' )
api.add_resource( Message, '/message' )
api.add_resource( getMessage, '/getmessage' )

##Obtener llave dependiendo del usuario
api.add_resource( getKey, '/keys/<id>' )

if __name__ == '__main__':
	app.run( port='8888', debug=True, host='0.0.0.0', threaded=True)


##Hay que actualizar los mensajes con la fecha
## 	SELECT * FROM messages WHERE date BETWEEN(LastConnection, Now() );
