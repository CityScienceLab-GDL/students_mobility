/**
* Name: mobility
* Based on the internal empty template. 
* Author: Gamaliel Palomo
* Tags: mobility, safety and security, inequality, segregation.
* Este modelo tiene el objetivo de evaluar posibles intervenciones en el sistema de transporte público para mejorar la seguridad
* y reducir la percepción de inseguridad en los estudiantes de la Universidad de Guadalajara.
*/


model mobility

global{
	
	float  walkable_distance	parameter: "walkable distance" 	category: "Environment parameters" 	   <- 5#km min:0.1#km max:20#km;
	
	file municipalities_shp 			<- file("../includes/gis/municipalities.shp");
	file students_csv				 	<- csv_file("../includes/Encuesta_E1721_2020B_3_filtered_formatted.csv",","); 
	file campus_shp					<- file("../includes/gis/UdG_campus.shp");
	geometry shape <- envelope(municipalities_shp);
	init{
		create Municipality from:municipalities_shp with:[name::string(read("NOMBRE"))];
		create Campus from:campus_shp with:[name::string(read("Name"))];
		matrix data <- matrix(students_csv);
		list<string> allowed_campus <- ["CUCBA","CUAAD","CUCSH","CUCS","CUT","CUCEI","CUCEA"];
		list<string> allowed_municipalities <- ["ZAPOPAN","ACATLAN DE JUAREZ","EL SALTO","GUADALAJARA","IXTLAHUACAN DE LOS MEMBRILLOS","JUANACATLAN","TLAJOMULCO DE ZUNIGA","TLAQUEPAQUE","TONALA","ZAPOTLANEJO"];
		
		//loop on the matrix rows (skip the first header line)
		loop i from: 1 to: data.rows -1{
			//loop on the matrix columns
			create Student{
				codigo <- int(data[0,i]);
				campus_str <- string(data[1,i]);
				municipality_str <- string(data[2,i]);
				transportation_means <- string(data[3,i])+", "+string(data[4,i]);
				mobility_time <- string(data[5,i]);
				//location <- any_location_in(one_of(Municipality));
				campus <- first(Campus where(each.name=campus_str));
				municipality <- first(Municipality where(each.name=municipality_str));
				location <- any_location_in(municipality);
				if not(allowed_campus contains campus_str){
					do die;
				}
				else if not(allowed_municipalities contains municipality_str){
					do die;
				}
				
				distance_to_campus <- campus distance_to(self)#km;
			}
			
		}
		write ""+data.rows+" rows";
		write ""+length(Student)+" students";
	}
}

//Social entities

species People skills:[moving]{
	point home;
	float distance_to_campus;
	rgb agent_color;
	aspect default{
		
		draw circle(200) color:#yellow;
	}
}
species Student parent:People{
	int codigo;
	string campus_str;
	Campus campus;
	Municipality municipality;
	string municipality_str;
	string transportation_means;
	string mobility_time;
	aspect default{
		//draw circle(150) color:#yellow;
		draw circle(150) color:rgb(255*(distance_to_campus/walkable_distance),255*(1-distance_to_campus/walkable_distance),0);
	}
}
species Campus{
	string name;
	aspect default{
		draw shape color:#blue;
	}
}
species Municipality{
	string name;
	aspect default{
		draw shape color:rgb(100,100,100,0.5) border:#gray;
		//draw name color:#white font:font("Arial", 10, #plain);
	}
}
//Physical entities

species block{
	
}
species road{
	
}

experiment GUI type:gui{
	output{
		display visualization type:opengl background:#black{
			species Municipality aspect:default;
			species Campus aspect:default;
			species Student aspect:default;
		}
	}
}