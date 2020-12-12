function BdE_be02(ruta::String, from::Date) 

    cd(ruta)
    pwd()
    #Descarga de ficheros desde la página del Banco de España
    file = HTTP.get("https://www.bde.es/webbde/es/estadis/infoest/series/be02.zip").body

    r = ZipFile.Reader(IOBuffer(file));

    for f in r.files
        println("Filename: $(f.name)")
        io = open("be02/"*f.name,"w") #Creación de fichero con nombre igual al del ZIP
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

    #Lectura datos ficheros BdE. La carpeta debe estar en una carpeta llamada "be02"
    for file in readdir("be02")

        #Lectura fichero transformando Latin1 a UTF8      
        tempdf = CSV.File(open("be02/"*file, enc"Latin1"), header=4, datarow=7, footerskip=2, delim=',',quotechar='"',missingstring="_") |> DataFrame
        
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