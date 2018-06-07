#!iTochcrypt/bin/python
##Json Libraries
import json
from json import dumps
from random import randint

##For modular inverse matrix
from sympy import Matrix, pprint

import pymysql

MOD = 60772


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

class HCDictionary:

	def __init__(self, filename = "iTochcrypt/PositionValues.json"):
		self.filename = filename
		self.mainDictionary = self.loadDictionary();
		self.positionToUnicode = self.loadDictionaryPosValue(self.mainDictionary);
		self.UnicodeToPosition = self.loadDictionaryValuePos(self.positionToUnicode);

	##Funciones que cargan los diccionarios iniciales
	def loadDictionary(self):
		with open(self.filename) as data_file:
			data = json.load(data_file);
		return data;

	##Diccionario invertido
	def loadDictionaryValuePos(self, posValueDicc):
		myDict =  { str(posValue):int(key) for (key,posValue) in posValueDicc.items()};
		print("ValPos", len(myDict))
		return myDict;

	def loadDictionaryPosValue(self, posValueDicc):
		myDict =  { str(posValue):int(key) for (key,posValue) in posValueDicc.items()};
		print("PosVal",len(myDict))
		return myDict

class iTochcryptDB:
	db = pymysql.connect("localhost", "iTochcryptDev", "Tochpan", "iTochcrypt", 1305);
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
			queryStr = "INSERT INTO it_keys( size, keyString, modulus, initDate, endDate ) VALUES( %d, '%s', %d, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY));" % (myDictUser[ "keySize" ], myDictUser[ "key" ], modulus );

			##id de la llave insertada
			idKey = self.insertToDB(queryStr);

			##Guardar llave en el historial
			queryStr="INSERT INTO it_keyHistory( idKey, initDate, endDate ) VALUES( %d, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY) );" % (idKey)
			idHistKey = self.insertToDB(queryStr);

			##Actualizar llave para el usuario
			queryStr="UPDATE it_users SET currentKey = %d WHERE id = %d;" % ( idHistKey, id );
			self.insertToDB(queryStr);

		return myDictUser;

	def createKey(self, size, modulus):
		matrix = randomMatrixKey(size, modulus);
		return self.getStringKey(matrix, size );

	def closeDB():
		self.db.close()




class Options(iTochcryptDB):

	def getStatusString( self, status):
		if status:
			return "ACTIVE"
		else:
			return "INACTIVE";

	def listAllUsers( self ):
		allUsers=self.getSelect( "SELECT name, lastName, username, status, lastLogin FROM it_users;" )
		print("Name\tLast Name\tUsername\tStatus\tLast Connection")
		print( (len("Name\tLast Name\tUsername\tStatus\tLast Connection") * 2 ) * '-' )
		for i in allUsers:
			print("%s\t%s\t%s\t%s\t%s" % ( i[0], i[1], i[2], self.getStatusString(int(i[3])), i[4] ) )
		print("\n\n\n")

	def listAllMessages( self ):
		#it_messages
		#idHistKey, message, idUserSender, idUserReceiver, status, msgDate, seen
		allUsers=self.getSelect( "SELECT DISTINCT usrEmi.username Sender, usrReceptor.username Receiver, msj.msgDate Date, K.keyString Used_Key, msj.status Status,  IF ( msj.seen = 1, 'YES', 'NO') Seen, msj.message Message  FROM  it_messages msj, it_users usrEmi, it_users usrReceptor, it_keys K  WHERE msj.idUserSender = usrEmi.id AND msj.idUserReceiver = usrReceptor.id AND K.id = msj.idKey ORDER BY msj.msgDate DESC;" )
		print( "Sender\tReceiver\tDate\tUsed Key\tStatus\tSeen\tMesssage");
		print( (len("Sender\tReceiver\tDate\tUsed Key\tStatus\tSeen\tMesssage") * 2 ) * '-' )
		for i in allUsers:
			print("%s\t%s\t%s\t%s\t%s\t%s\t%s" % ( i[0], i[1], i[2], i[3], i[4], i[5], i[6] ) )
		print("\n\n\n")


	def listAllKeys( self ):
		allUsers=self.getSelect( "SELECT initDate, endDate, size, modulus, status, keyString FROM it_keys;" )
		print("Creation\tExpire\tSize\tModulus\tStatus\tKey")
		print( (len("Creation\tExpire\tSize\tModulus\tStatus\tKey") * 2 ) * '-' )
		for i in allUsers:
			print("%s\t%s\t%s\t%s\t%s\t%s" % ( i[0], i[1], i[2], i[3], i[4], i[5] ) )
		print("\n\n\n")



##Funciones de admin
def printMenu():
	print("Seleccione la opcion deseada:")
	print("\t[1]: List all user");
	print("\t[2]: Add new user");
	print("\t[3]: Deactivate user");
	print("\t[4]: List all messages");
	print("\t[5]: List all keys");
	print("\t[6]: Change key to user");
	print("\t[7]: Change all keys");
	print("\t[8]: Delete message");
	print("\t[0]: Exit");
	try:
		return int( raw_input("Please enter an option:>") );
	except ValueError:
		print("Just write numbers for the following options...")
		return -1


def doAction(option, cli):
	if option == 1:
		cli.listAllUsers();

	elif option == 2:
		username = raw_input('Enter the username:>')
		passwd = raw_input('New Password:>')
		name = raw_input('Name:>')
		lastName = raw_input('Last Name:>')
		try:
			keySize = int( raw_input("Key size:>") );
			cli.createFullUser( username, passwd, name, lastName, keySize, MOD )

		except ValueError:
			print("Format error! Try again...")
			return -1


	elif option == 4:
		cli.listAllMessages();
	elif option == 5:
		cli.listAllKeys();


####Main program, user will choose what to do:
hcDict = HCDictionary();

finish = False;
cli = Options();
while finish == False:

	##Print menu and get option
	option = printMenu()

	##Ver si la opcion es validad
	if option > 0:
		doAction(option, cli);
	else:

		##Si el usuario quiere salir del sistema
		if( option == 0):
			finish = True

		##Si fue una opcion invalida
		else:
			continue
