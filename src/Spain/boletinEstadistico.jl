"""
    downloadchapter(chapter, dir)

Downloads and unzips a complete chapter from Boletin Estadístico of Bank of Spain

Creates a subfolder with the name of the chapter if it does not exists already

# Example

    downloadchapter(2, "C:\\Users\\Weyland\\Documents\\") 
"""

function downloadchapter(capitulo::Int, directory::String) 

    n = lpad(capitulo,2,"0")

    #TODO: sustituir por Downloads en base con 1.6 
    #Descarga de ficheros desde la página del Banco de España. Cambiar por 
    file = HTTP.get("https://www.bde.es/webbde/es/estadis/infoest/series/be"*n*".zip").body

    r = ZipFile.Reader(IOBuffer(file));

    isdir(joinpath(directory,"be"*n)) || mkdir(joinpath(directory,"be"*n)) # Si no hay directorio lo creamos

    for f in r.files
        println("Filename: $(f.name)")
        io = open(joinpath(directory,"be"*n,f.name),"w") #Creación de fichero con nombre igual al del ZIP
        write(io,read(f))
        close(io)
    end
    close(r)

end #function

"""
downloadchapter(f, chapter, dir)

Downloads and unzips a complete chapter from Boletin Estadístico of Bank of Spain. 
Then applies a function that acts on the files on the same directory

# Example

    downloadchapter(CSVtoDataFrame, 2, "C:\\Users\\Weyland\\Documents\\") 

"""
function downloadchapter(f::Function, capitulo::Int, directory::String) 

    downloadchapter(capitulo::Int, directory::String) 
    
    f(joinpath(directory,"be"*lpad(capitulo,2,"0")))
    
end #function


"""
    CSVtoDataFrame(directory::String)

Read all the Boletin Estadístico files in a directory, tranform them into a DataFrame. 
Return a Dictionary with pairs (filename, dataframe)

"""
function CSVtoDataFrame(directory::String,from::Date=Date(1900))

    #Definición de formato de fechas utilizado por Banco de España en su boletín estadístico
    bde_months = ["ENERO", "FEBRERO", "MARZO", "ABIRL", "MAYO", "JUNIO", "JULIO", "AGOSTO", "SEPTIEMBRE", "OCTUBRE", "NOVIEMBRE", "DICIEMBRE"]
    bde_monts_abbrev = ["ENE","FEB","MAR","ABR","MAY","JUN", "JUL","AGO","SEP","OCT","NOV","DIC"]

    Dates.LOCALES["BdE"] = Dates.DateLocale(bde_months,bde_monts_abbrev, [""],[""],)

    BdE_Format = DateFormat("uuu yyyy", "BdE") #Definición del formato de fechas utilizado por BdE
   
    File_Dict = Dict{String,DataFrame}() #Inicializo el Diccionario con los datos

    #Lectura datos ficheros BdE. La carpeta debe estar en una carpeta llamada "be04"
    for file in readdir(directory)

        #Lectura fichero transformando Latin1 a UTF8      
        tempdf = CSV.File(open(read,joinpath(directory,file), enc"Latin1"), header=4, datarow=7, footerskip=2, delim=',',quotechar='"',missingstring="_") |> DataFrame
        
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

end