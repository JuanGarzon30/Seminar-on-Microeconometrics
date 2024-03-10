**# Preambulo
clear all	

pwd

cd "C:\Users\Juan Garzón\OneDrive\Documentos\Sexto Semestre\Seminario Microeconometría\Icfes_def"
** log close

log using log2022.smcl, replace


**# Importación de datos
*Resultados 2022
import delimited "C:\Users\Juan Garzón\OneDrive\Documentos\Sexto Semestre\Seminario Microeconometría\Icfes_def\df_2022.csv"

**# Limpieza
* Eliminar variables irrelevantes 

** Relacionadas con identificadores internos del ICFES y DANE
drop periodo estu_tipodocumento estu_consecutivo cole_cod_dane_establecimiento cole_cod_dane_sede cole_cod_depto_ubicacion cole_cod_mcpio_ubicacion cole_codigo_icfes cole_nombre_establecimiento cole_nombre_sede cole_sede_principal estu_cod_depto_presentacion estu_cod_reside_depto estu_estadoinvestigacion estu_estudiante 

** Variables relacionadas con municipio dado que el nivel de desagregación del estudio es departamental y regional
drop estu_cod_mcpio_presentacion estu_cod_reside_mcpio estu_mcpio_presentacion estu_mcpio_reside cole_mcpio_ubicacion 

drop fami_personashogar fami_cuartoshogar cole_depto_ubicacion estu_depto_presentacion fami_tieneautomovil fami_tienelavadora

** Variables recogidas dentro de puntaje global que es la variable dependiente
drop desemp_ingles punt_ingles punt_matematicas punt_sociales_ciudadanas punt_c_naturales punt_lectura_critica 

* Eliminar variable país residencia porque tiene la misma información de nacionalidad
gen igual = 4
replace igual = 1 if estu_pais_reside == estu_nacionalidad
replace igual = 0 if estu_pais_reside != estu_nacionalidad
tab(igual)
** En la tabla de frecuencia se puede ver que para todos los estudiantes el país de nacimiento es igual al país de residencia

drop estu_pais_reside
drop igual

* Eliminar datos faltantes
drop if missing(cole_area_ubicacion) | missing(cole_bilingue) | missing(cole_calendario) | missing(cole_caracter) |  missing(cole_genero) | missing(cole_jornada) | missing(cole_naturaleza) |missing(estu_depto_reside) | missing(estu_fechanacimiento) | missing(estu_genero) | missing(estu_nacionalidad) | missing(estu_privado_libertad) | missing(fami_educacionmadre) | missing(fami_educacionpadre) | missing(fami_estratovivienda) | missing(fami_tienecomputador) | missing(fami_tieneinternet) | missing(punt_global) | fami_estratovivienda == "Sin Estrato"

**# Creación de variables sintéticas
* Generar variable sintética de último nivel educativo alcanzado para padre y madre

** Madre
drop if fami_educacionmadre == "No sabe"| fami_educacionmadre == "No Aplica"
gen educ_madre = 8

replace educ_madre = 5 if fami_educacionmadre == "Postgrado"
replace educ_madre = 4 if fami_educacionmadre == "Educación profesional completa"
replace educ_madre = 3 if fami_educacionmadre == "Técnica o tecnológica completa"
replace educ_madre = 2 if (fami_educacionmadre == "Educación profesional incompleta") | (fami_educacionmadre == "Técnica o tecnológica incompleta") | (fami_educacionmadre == "Secundaria (Bachillerato) completa")
replace educ_madre = 1 if (fami_educacionmadre == "Primaria completa") | (fami_educacionmadre == "Secundaria (Bachillerato) incompleta")
replace educ_madre = 0 if (fami_educacionmadre == "Ninguno") | (fami_educacionmadre == "Primaria incompleta")


drop fami_educacionmadre

** Padre
drop if fami_educacionpadre == "No sabe"| fami_educacionpadre == "No Aplica"
gen educ_padre = 8

replace educ_padre = 5 if fami_educacionpadre == "Postgrado"
replace educ_padre = 4 if fami_educacionpadre == "Educación profesional completa"
replace educ_padre = 3 if fami_educacionpadre == "Técnica o tecnológica completa"
replace educ_padre = 2 if (fami_educacionpadre == "Educación profesional incompleta") | (fami_educacionpadre == "Técnica o tecnológica incompleta") | (fami_educacionpadre == "Secundaria (Bachillerato) completa")
replace educ_padre = 1 if (fami_educacionpadre == "Primaria completa") | (fami_educacionpadre == "Secundaria (Bachillerato) incompleta")
replace educ_padre = 0 if (fami_educacionpadre == "Ninguno") | (fami_educacionpadre == "Primaria incompleta")

drop fami_educacionpadre

* Generar la variable edad a partir de la diferencia entre la fecha de nacimiento y la fecha de presentación
gen fecha_presentacion = "03/09/2022"
replace fecha_presentacion = "27/03/2022" if cole_calendario == "B"

gen estu_fechanacimiento_num = date(estu_fechanacimiento, "DMY")
gen fecha_presentacion_num = date(fecha_presentacion, "DMY")	

gen edad = floor((fecha_presentacion_num - estu_fechanacimiento_num)/365.25) 

* Eliminar los typos en edad
drop if edad > 100 | edad < 14

drop fecha_presentacion
drop fecha_presentacion_num
drop estu_fechanacimiento
drop estu_fechanacimiento_num

* Generar la variable estrato para que sea númerica

gen estrato = .

replace estrato = 1 if fami_estratovivienda == "Estrato 1"
replace estrato = 2 if fami_estratovivienda == "Estrato 2"
replace estrato = 3 if fami_estratovivienda == "Estrato 3"
replace estrato = 4 if fami_estratovivienda == "Estrato 4"
replace estrato = 5 if fami_estratovivienda == "Estrato 5"
replace estrato = 6 if fami_estratovivienda == "Estrato 6"

drop fami_estratovivienda
drop if estrato == 0

** Generar la variable extranjero
gen estu_extranjero = 0
replace estu_extranjero = 1 if estu_nacionalidad == "COLOMBIA"
tab(estu_extranjero)

* Generar dummies
** Dummy calendario
drop if cole_calendario == "OTRO"
gen cole_calendario_ = 0
replace cole_calendario_ = 1 if cole_calendario == "B"
drop cole_calendario

** Dummy colegio rural
gen cole_rural = 1
replace cole_rural = 0 if cole_area_ubicacion == "URBANO"
drop cole_area_ubicacion

** Dummy colegio bilingue
gen cole_bilingue_ = 4
replace cole_bilingue_ = 1 if cole_bilingue == "S"
replace cole_bilingue_ = 0 if cole_bilingue == "N"
drop cole_bilingue 

** Dummy colegio técnico
gen cole_tecnico = 0
replace cole_tecnico = 1 if (cole_caracter == "TÉCNICO") | (cole_caracter == "TÉCNICO/ACADÉMICO")
drop cole_caracter

** Dummy colegio femenino o masculino
gen cole_genero_ = 4
replace cole_genero_ = 0 if cole_genero == "MIXTO"
replace cole_genero_ = 1 if cole_genero == "MASCULINO"
replace cole_genero_ = 2 if cole_genero == "FEMENINO"
drop cole_genero

** Dummy jornada colegio
gen cole_jornada_ = 6
replace cole_jornada_ = 1 if cole_jornada == "MAÑANA"
replace cole_jornada_ = 2 if cole_jornada == "TARDE"
replace cole_jornada_ = 3 if cole_jornada == "NOCHE"
replace cole_jornada_ = 4 if cole_jornada == "SABATINA"
replace cole_jornada_ = 5 if cole_jornada == "UNICA"
replace cole_jornada_ = 0 if cole_jornada == "COMPLETA"
drop cole_jornada

** Dummy naturaleza colegio
gen cole_oficial = 1
replace cole_oficial = 0 if cole_naturaleza == "NO OFICIAL" 
drop cole_naturaleza

** Dummy género estudiante
gen estu_mujer = 1
replace estu_mujer = 0 if estu_genero == "M"
drop estu_genero

** Dummy estudiante privado de la libertad
gen estu_privado_libertad_ = 1
replace estu_privado_libertad_ = 0 if estu_privado_libertad == "N" 
drop estu_privado_libertad 

** Dummy computador
gen fami_computador = 1
replace fami_computador = 0 if fami_tienecomputador == "No"
drop fami_tienecomputador
	
** Dummy internet
gen fami_internet = 1
replace fami_internet = 0 if fami_tieneinternet == "No"
drop fami_tieneinternet

**# Creación Variable sintética por IPM departamental

gen quintil = 0

replace quintil = 1 if (estu_depto_reside == "BOGOTÁ") | (estu_depto_reside == "SAN ANDRES") | (estu_depto_reside ==  "BOYACA") | (estu_depto_reside == "VALLE") | (estu_depto_reside == "CUNDINAMARCA")

replace quintil = 2 if  (estu_depto_reside == "QUINDIO") | (estu_depto_reside ==  "RISARALDA")| (estu_depto_reside == "ATLANTICO") | (estu_depto_reside == "SANTANDER") | (estu_depto_reside == "CALDAS") | (estu_depto_reside == "ANTIOQUIA") | (estu_depto_reside == "TOLIMA") | (estu_depto_reside == "META")

replace quintil = 3 if (estu_depto_reside == "HUILA") | (estu_depto_reside == "CASANARE")| (estu_depto_reside == "NARIÑO") | (estu_depto_reside == "CESAR") | (estu_depto_reside == "CAUCA") | (estu_depto_reside == "NORTE SANTANDER") | (estu_depto_reside == "BOLIVAR")

replace quintil = 4 if (estu_depto_reside == "PUTUMAYO") | (estu_depto_reside == "ARAUCA")| (estu_depto_reside == "CAQUETA") | (estu_depto_reside == "GUAVIARE") | (estu_depto_reside == "MAGDALENA")| (estu_depto_reside == "SUCRE") | (estu_depto_reside == "CORDOBA")

replace quintil = 5 if  (estu_depto_reside == "AMAZONAS") | (estu_depto_reside == "CHOCO")| (estu_depto_reside == "LA GUAJIRA") | (estu_depto_reside == "VAUPES")| (estu_depto_reside == "GUAINIA") | (estu_depto_reside == "VICHADA")

drop estu_depto_reside
drop if quintil == 0

**# Estadística descriptiva
summarize punt_global i.cole_calendario_ i.cole_rural i.cole_bilingue_ i.cole_tecnico  i.cole_oficial i.cole_genero_ i.cole_jornada_  i.estu_extranjero i.estu_mujer i.estu_privado_libertad_ edad  i.fami_internet i.fami_computador i.fami_internet##fami_computador i.educ_madre i.educ_padre i.estrato  i.quintil

* Gráficos
histogram punt_global, bin(100) fcolor(mint%50) lcolor(navy) ytitle(Densidad) xtitle(Puntaje global) title(Distribución puntajes globales prueba ICFES 2015)

histogram estrato, bin(5) fcolor(mint%50) lcolor(navy) ytitle(Densidad) xtitle(Puntaje global) title(Distribución por estratos prueba ICFES 2015)

**# Pre-test heterocedasticidad
regress punt_global i.cole_calendario_ i.cole_rural i.cole_bilingue_ i.cole_tecnico  i.cole_oficial i.cole_genero_ i.cole_jornada_  i.estu_extranjero i.estu_mujer i.estu_privado_libertad_ edad  i.fami_internet i.fami_computador i.fami_internet##fami_computador i.educ_madre i.educ_padre i.estrato  i.quintil

estimates store OLS

predict resid, residuals
sktest resid

hettest i.cole_calendario_ i.cole_rural i.cole_bilingue_ i.cole_tecnico  i.cole_oficial i.cole_genero_ i.cole_jornada_  i.estu_extranjero i.estu_mujer i.estu_privado_libertad_ edad  i.fami_internet i.fami_computador i.fami_internet##fami_computador i.educ_madre i.educ_padre i.estrato  i.quintil


* Gráfica de cuantiles para variable dependiente
quantile punt_global, recast(line) lcolor(mint) lwidth(1.5) rlopts(lcolor(blue) lpattern(dash)) ytitle(Cuantiles del puntaje global) xtitle(Probabilidad acumulada) title(Cuantiles de la variable dependiente)


**# Regresión cuantílica
qreg punt_global /*Características del colegio*/ i.cole_calendario_ i.cole_rural i.cole_bilingue_ i.cole_tecnico  i.cole_oficial i.cole_genero_ i.cole_jornada_ /* Características del estudiante */ i.estu_extranjero i.estu_mujer i.estu_privado_libertad_ edad /* Características del hogar */ i.fami_internet i.fami_computador i.fami_internet##fami_computador i.educ_madre i.educ_padre i.estrato /* Quintil de IPM departamento de residencia */ i.quintil, q(0.25) iter(1000)
estimates store qreg25

qreg punt_global /*Características del colegio*/ i.cole_calendario_ i.cole_rural i.cole_bilingue_ i.cole_tecnico  i.cole_oficial i.cole_genero_ i.cole_jornada_ /* Características del estudiante */ i.estu_extranjero i.estu_mujer i.estu_privado_libertad_ edad /* Características del hogar */ i.fami_internet i.fami_computador i.fami_internet##fami_computador i.educ_madre i.educ_padre i.estrato /* Quintil de IPM departamento de residencia */ i.quintil, q(0.50) iter(1000)
estimates store qreg50

qreg punt_global /*Características del colegio*/ i.cole_calendario_ i.cole_rural i.cole_bilingue_ i.cole_tecnico  i.cole_oficial i.cole_genero_ i.cole_jornada_ /* Características del estudiante */ i.estu_extranjero i.estu_mujer i.estu_privado_libertad_ edad /* Características del hogar */ i.fami_internet i.fami_computador i.fami_internet##fami_computador i.educ_madre i.educ_padre i.estrato /* Quintil de IPM departamento de residencia */ i.quintil, q(0.75) iter(1000)
estimates store qreg75

estimates table OLS qreg25 qreg50 qreg75, b(%7.3f) se p

**# Bookmark #3
* Comparación de tablas