import csv

input_file  	= "Encuesta_E1721_2020B_3"
output_file 	= input_file+"_filtered"

column_names 	= []
students		= []

def load_file():
	with open('../includes/'+input_file+".csv", encoding="utf-8-sig") as csv_file:
		csv_reader = csv.reader(csv_file,delimiter=',')
		first = True
		for row in csv_reader:
			if first:
				for i in range(0,len(row)):
					column_names.append(row[i])
				first = False
			else:
				students.append([])
				for i in range(0,len(row)):
					students[-1].append(row[i])

def filter_columns(columns):
	
	if "¿EN QUÉ MUNICIPIO VIVES?" in columns:
		occurrences = [i for i, j in enumerate(column_names) if j == "¿EN QUÉ MUNICIPIO VIVES?"]
	
	indices = [column_names.index(c) for c in columns]
	filter_students = []
	
	
	for student in students:
		if len(student) != 0:
			municipio = {student[i] for i in occurrences}.difference({''})
			if len(municipio) == 0:
				municipio={''}
			student[column_names.index("¿EN QUÉ MUNICIPIO VIVES?")] = municipio.pop()
			flag = True
			for i in indices:
				if student[i] == '':
					flag = False
			if flag:
				filter_students.append([student[i] for i in indices])

	with open('../includes/'+output_file+'.csv','w',newline='',encoding="utf-8-sig") as csv_file:
		csv_writer = csv.writer(csv_file,delimiter=',')
		csv_writer.writerow(columns)
		for student in filter_students:
			#print(student)
			csv_writer.writerow([student[i] for i in range(len(student))])




if __name__ == '__main__':
	load_file()
	filter_columns([	"Codigo",
				"Centro",
				"¿EN QUÉ MUNICIPIO VIVES?",
				"¿CÓMO ACOSTUMBRAS A IR DE TU CASA A LA ESCUELA? ",
				" 	¿CUÁNTO TIEMPO HACES DE TU CASA A LA ESCUELA? "])
	print("column_names: {}".format(len(column_names)))
	print("students: {}".format(len(students)))