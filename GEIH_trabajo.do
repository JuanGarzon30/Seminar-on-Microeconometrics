*preambulo
clear all
set more off
*traer archivo
*Traer el archivo
use Caracteristicaspersona
*Merge 1 a 1
merge 1:1 DIRECTORIO SECUENCIA_P ORDEN using Laboral
*Dejar solo las variables que hicieron match perfecto
keep if _merge==3.
*merge many to 1, borrando primero el merge anterior
drop _merge
*nuevo merge
merge m:1 DIRECTORIO SECUENCIA_P using HogarVivienda

*variables a usar
keep DIRECTORIO SECUENCIA_P ORDEN /*
*/ P6040 /* edad
*/ P6100 /* seguridad social
*/ P1906S6 /* condicion fisica
*/ P3043 /* educación
*/ P6240 P6250 P6260 P6270 P6280 P6320 P6330 P6340 P6351 /* ocupado
*/ P6050 /* jefehogar

*renombrando variables*/
rename P6040 edad
rename P6100 seguridad_social
rename P1906S6 condicion_fisica
rename P3043 educación
rename P6050 jefehogar


*creación variable ocupado
generate ocupado = 0
replace ocupado = 1 if P6240 == 1 | P6240 == 2 | P6250 == 1 | P6260 == 1 | P6270 == 1 | P6320 == 1 

*recode para la xdiseño
*buscando trabajo
generate buscando_trabajo = 0
replace buscando_trabajo = 1 if P6330==1 | P6340 == 1 | P6351 == 1 
*Es jefe de hogar
recode jefehogar (1=1)(2/13=0)
*seguridad social
recode seguridad_social (1/2=1) (3/4=0)
*educacion
recode educación (5/10=1) (1/4=0) (99=0)

*regresion OLS
regress ocupado buscando_trabajo jefehogar seguridad_social educación
estimates store ols_results
	margins, dydx(seguridad_social) /*Positivo*/
	margins, dydx(buscando_trabajo) /*Negativo*/
	margins, dydx(jefehogar) /*Positivo*/
	margins, dydx(educación) /*Positivo*/
*regresion Logit
logit ocupado buscando_trabajo jefehogar seguridad_social educación
estimates store logit_results
	margins, dydx(seguridad_social) /*Positivo*/
	margins, dydx(buscando_trabajo) /*Negativo*/
	margins, dydx(jefehogar) /*Positivo*/
	margins, dydx(educación) /*Positivo*/
	
logistic ocupado buscando_trabajo jefehogar seguridad_social educación


*estadistica descriptiva
graph twoway scatter ocupado buscando_trabajo jefehogar seguridad_social educación lfit lcolor(red) lwidth(5)





