::Pequeño script para descargar de grupots
::Para que funcione hay que cambiar lo siguiente:
:: 1) 	poner en usuario y password los tuyos
:: 2) 	poner en el fichero listaseries.txt el enlace a la serie que sea
:: 		p.ej. http://www.tusseries.com/index.php?showtopic=20762 
:: 3)	Este script asume que usas emule.exe en la carpeta "C:\Program Files\Emule\Emule.exe"
::		si no es así, cambialo
:: 


@echo off
IF NOT EXIST listatotal.txt (
type NUL > listatotal.txt
)
IF NOT EXIST listaseries.txt (
	echo "Me hace falta el fichero listaseries.txt, creálo y mete dentro los enlaces a las páginas de tusseries"
	exit
)
cls
type NUL > listaenlacestmp.txt
rem Poner aqui el usuario de tusseries
set usuario=USUARIOCAMBIAR
rem Poner aqui la contraseña de tus
set password=PASSWORDCAMBIAR
rem Primero nos autenticamos
curl -b newcookie.txt -c newcookie.txt -d "auth_key=880ea6a14ea49e853634fbdc5015a024&ips_username=%usuario%&ips_password=%password%&rememberMe=1" "http://grupots.net/index.php?app=core&module=global&section=login&do=process"
curl -o inicio.html -b newcookie.txt -c newcookie.txt http://grupots.net/
rem Comprobamos si estamos autenticados  
FINDSTR %usuario% inicio.html
if %errorlevel% == 0 (
Echo AUTENTICADO
) else (
del /q inicio.html
echo ERROR EN USUARIO O CONTRASEÑA
exit)
del /q inicio.html
rem Ahora procesamos cada serie
cls
for /f "eol= tokens=* delims= usebackq" %%i in ("listaseries.txt") do ( 
echo DESCARGANDO:%%i
curl -o serie.html -b newcookie.txt -c newcookie.txt --referer http://www.grupots.net --user-agent "Mozilla/4.0 (compatible; MSIE 5.01; Windows NT 5.0)" %%i
cls
grep -o ed2k://[^^^"""]* serie.html | cut -d " " -f 1 >> listaenlacestmp.txt
)
del /q serie.html
for /f "eol= tokens=* delims= usebackq" %%G in ("listaenlacestmp.txt") do (
echo "%%G" | cut.exe -d "|" -f 5 > hash.txt
findstr /G:hash.txt listatotal.txt
IF ERRORLEVEL == 1 (
echo %%G >> listatotal.txt
tasklist /fi "imagename eq emule.exe" /fi "status eq running"|Findstr /I "emule"
	if ERRORLEVEL == 0 (
		echo "A€adiendo al emule:" %%G
		start "" ""%%G"") else (
		"C:\Program Files\Emule\Emule.exe" ""%%G"")
 )
) 
del /q listaenlacestmp.txt
del /q hash.txt
