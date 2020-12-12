function BdE_be04(ruta::String, from::Date) 

    cd(ruta)
    pwd()
    #Descarga de ficheros desde la página del Banco de España
    file = HTTP.get("https://www.bde.es/webbde/es/estadis/infoest/series/be04.zip").body

    r = ZipFile.Reader(IOBuffer(file));

    for f in r.files
        println("Filename: $(f.name)")
        io = open("be04/"*f.name,"w") #Creación de fichero con nombre igual al del ZIP
        write(io,read(f))
        close(io)
    end
    close(r)
 
    #Definición de formato de fechas utilizado por Banco de España en su boletín estadístico
    bde_months = ["ENERO", "FEBRERO", "MARZO", "ABIRL", "MAYO", "JUNIO", "JULIO", "AGOSTO", "SEPTIEMBRE", "OCTUBRE", "NOVIEMBRE", "DICIEMBRE"]
    bde_monts_abbrev = ["ENE","FEB","MAR","ABR","MAY","JUN", "JUL","AGO","SEP","OCT","NOV","DIC"]

    Dates.LOCALES["BdE"] = Dates.DateLocale(bde_months,bde_monts_abbrev, [""],[""],)

    BdE_Format = DateFormat("uuu yyyy", "BdE") #Definición del formato de fechas utilizado por BdE
   
    File_Dict = Dict{String,DataFrame}() #Inicializo el Diccionario con los datos

    #Lectura datos ficheros BdE. La carpeta debe estar en una carpeta llamada "be04"
    for file in readdir("be04")

        #Lectura fichero transformando Latin1 a UTF8      
        tempdf = CSV.File(open("be04/"*file, enc"Latin1"), header=4, datarow=7, footerskip=2, delim=',',quotechar='"',missingstring="_") |> DataFrame
        
        #Conversión de datos (distinguiendo cuando hay mes y año o sólo año)        
        if typeof(tempdf[1,1])==String 
            tempdf[!,1] = lastdayofmonth.(Date.(tempdf[:,1],BdE_Format))

        elseif typeof(tempdf[1,1])== Int 
            tempdf[!,1] = Date.(tempdf[:,1],12,31)
        end     
        
        #Filtrado por fecha según from
        tempdf = tempdf[(tempdf[:,1]).>=from,:]
           
        #Creación de Dict para guardar cada dataframe asociado al nombre del fichero según Banco de España
        filename = file[1:length(file)-4]
        push!(File_Dict,filename => tempdf)

    end #for

    File_Dict

end #function

function combinaciones(BdE_Files::Dict)

    #Cuenta de Resultados del Sector. Ojo! Incluye Sucursales en extranjero. Pensar si utilizar 4.41 que no las incluye
    PyG_Trim = copy(BdE_Files["be0436"]) #Orden de mayor a menor por primera columna (fecha)
    PyG_Trim = hcat(PyG_Trim[:,1:4],BdE_Files["be0439"][:,[9]],BdE_Files["be0440"][:,3:15],PyG_Trim[:,5:17])
   
    PyG_Acum = copy(PyG_Trim)
    PyG_Acum[!,1] = year.(PyG_Acum[:,1])
    PyG_Acum = aggregate(PyG_Acum,1,cumsum)
    PyG_Acum[!,1] = PyG_Trim[:,1]

    sort!(PyG_Trim,1,rev=true)
    sort!(PyG_Acum,1,rev=true)

    #TODO 1: hay que pensar cómo trasponer los datos de forma más elegante!!!!

    writeCSVTransposed(PyG_Acum,"PyG_Sector")

    #Balance del Sector

    Balance_Sector = hcat(BdE_Files["be0401"],BdE_Files["be0402"][:,Not(1,2,9)],BdE_Files["be0407"][:,Not(1)])
    
    sort!(Balance_Sector,1,rev=true)

    writeCSVTransposed(Balance_Sector,"Balance_Sector")

    CreditoPasivo_OSR = hcat(BdE_Files["be0403"],BdE_Files["be0405"][:,Not(1)])

    sort!(CreditoPasivo_OSR,1,rev=true)

    writeCSVTransposed(CreditoPasivo_OSR,"CreditoPasivo_OSR")

    #Ratios

    #Sobre PyG. Eficiencia, resultados s/MB

    Ratios_PyG = DataFrame()

    #No se puede operar elemento a elemento dos columnas de un DataFrame por eso hay que poner [:,1] cuyo resultado es un Array
    Ratios_PyG.Fecha = PyG_Acum[:,1]
    Ratios_PyG.Eficiencia = PyG_Acum[:,r"Gastos de explotación_cumsum"][:,1]./PyG_Acum[:,r"Margen bruto"][:,1]*100
    Ratios_PyG.EficienciasinROF= PyG_Acum[:,r"Gastos de explotación_cumsum"][:,1]./(PyG_Acum[:,r"Margen bruto"][:,1].-PyG_Acum[:,r"Otras operaciones financieras"][:,1])*100
    Ratios_PyG.MdI_MB = PyG_Acum[:,r"Margen de intereses"][:,1]./PyG_Acum[:,r"Margen bruto"][:,1]*100
    Ratios_PyG.Comisiones_MB = PyG_Acum[:,r"Comisiones, neto"][:,1]./PyG_Acum[:,r"Margen bruto"][:,1]*100
    Ratios_PyG.ROF_MB = PyG_Acum[:,r"Otras operaciones financieras"][:,1]./PyG_Acum[:,r"Margen bruto"][:,1]*100

    writeCSVTransposed(Ratios_PyG,"Ratios_PyG")

    #=TODO
    Ratios s/ Balance -> Ingresos sobre préstamos, Costes sobre recursos, Coste Morosidad s/crédito, Otras Dotaciones s/crédito,
                        Margen Financiero s/ ATMs, Comisiones s/ATMs
    Ratios_Balance = DataFrame()

    Balance_Trim = Balance_Sector[(@. month(Balance_Sector[:,1])%3==0),:] #Los datos de Balance son mensuales y de PyG Trimestrales
    =#

    #Capacidad [Entidades y Oficinas]

    Capacidad_Sector = hcat(BdE_Files["be0445"],BdE_Files["be0447"][:,Not(1)])

    sort!(Capacidad_Sector,1,rev=true)

    writeCSVTransposed(Capacidad_Sector,"Capacidad_Sector")
end #function